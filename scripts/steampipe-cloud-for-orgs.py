#!/usr/bin/env python3

import sys, argparse, os
import boto3
from botocore.exceptions import ClientError
import json
import urllib3
import random
import string

def main(args):

    try:
        STEAMPIPE_CLOUD_TOKEN=os.environ['STEAMPIPE_CLOUD_TOKEN']
    except KeyError:
        print("STEAMPIPE_CLOUD_TOKEN not set. Aborting....")
        exit(1)

    http = urllib3.PoolManager()

    # Get my Steampipe Org Identifier based on my org name
    r = http.request('GET', f"https://{args.spc_endpoint}/api/v0/org/{args.org_name}",
        headers={'Authorization': f"Bearer {STEAMPIPE_CLOUD_TOKEN}"}
    )
    if r.status == 200:
        results = json.loads(r.data.decode('utf-8'))
        sp_org_id = results['id']
    else:
        print(f"FATAL ERROR ({r.status}): unable to get the steampipe org id for {args.org_name}. Does it exist?: {r.data.decode('utf-8')}")
        exit(1)

    regions = args.regions
    payer_account_id = get_my_acount_id()

    accounts = list_accounts()
    for a in accounts:
        sp_account_name = a['Name'].replace('-', '_').replace('.', '_').lower()
        external_id = f"{sp_org_id}:{get_random_str()}"
        sp_role_arn = f"arn:aws:iam::{a['Id']}:role/{args.rolename}"
        org_role_arn = f"arn:aws:iam::{a['Id']}:role/{args.org_role}"


        print(f"Processing connection {sp_account_name} for {a['Name']}({a['Id']}) in org_id {sp_org_id} for {regions}")
        # continue

        # 1. Assume the Role
        if a['Id'] != payer_account_id:
            account_creds = get_creds(org_role_arn, args.role_session_name)
            if account_creds is None:
                continue
            iam_client = get_client(account_creds, 'iam')
        else:
            iam_client = boto3.client('iam')

        # 2. Create the Role and Attach Policy
        try:
            assume_role_policy_document = {
                "Version": "2012-10-17",
                "Statement": [{
                        "Effect": "Allow",
                        "Principal": {"AWS": [f"arn:aws:iam::{args.spc_account_id}:root"] },
                        "Action": ["sts:AssumeRole"],
                        "Condition": {"StringEquals": {"sts:ExternalId": external_id} }
            } ] }
            response = iam_client.create_role(
                RoleName=args.rolename,
                AssumeRolePolicyDocument=json.dumps(assume_role_policy_document),
                Description=f"Steampipe Cloud Role for {args.org_name}",
                MaxSessionDuration=43200
            )
        except ClientError as e:
            if e.response['Error']['Code'] == "EntityAlreadyExists":
                # oh the role exists, lets get the external id and use that.
                response = iam_client.get_role(RoleName=args.rolename)
                external_id = response['Role']['AssumeRolePolicyDocument']['Statement'][0]['Condition']['StringEquals']['sts:ExternalId']
                print(f"Role {args.rolename} already exists in account {a['Id']} with external_id of {external_id}")
            else:
                raise

        response = iam_client.attach_role_policy(RoleName=args.rolename, PolicyArn='arn:aws:iam::aws:policy/ReadOnlyAccess')

        # 3. Create Connection in SP Cloud
        create_payload = {
            "handle": sp_account_name,
            "plugin": "aws",
            "config": {
                "regions": regions,
                "role_arn": sp_role_arn,
                "external_id": external_id
            }
        }
        r = http.request('POST', f"https://{args.spc_endpoint}/api/v0/org/{args.org_name}/conn",
            body=json.dumps(create_payload),
            headers={'Authorization': f"Bearer {STEAMPIPE_CLOUD_TOKEN}"}
        )
        if r.status == 409:
            print(f"A connection called {sp_account_name} already exists in {args.org_name}({sp_org_id}). Updating....")
            r = http.request('PATCH', f"https://{args.spc_endpoint}/api/v0/org/{args.org_name}/conn/{sp_account_name}",
                body=json.dumps(create_payload),
                headers={'Authorization': f"Bearer {STEAMPIPE_CLOUD_TOKEN}"}
            )
        elif r.status != 201:
            print(f"STatus: {r.status}")
            print(r.data.decode('utf-8'))
            raise NotImplementedError

        # 4. Add to SP Cloud Workspace
        r = http.request('POST', f"https://{args.spc_endpoint}/api/v0/org/{args.org_name}/workspace/{args.workspace}/conn",
            body=json.dumps({"connection_handle": sp_account_name}),
            headers={'Authorization': f"Bearer {STEAMPIPE_CLOUD_TOKEN}"}
        )
        if r.status == 409:
            print(f"Connection {sp_account_name} is already a member of workspace {args.org_name}/{args.workspace}")
        elif r.status != 201:
            # We need to update???
            print(f"ERROR: unable to add {sp_account_name} to workspace {args.workspace} in {args.org_name}: Status: {r.status} - {r.data.decode('utf-8')}")

        print("")


def get_my_acount_id():
    client = boto3.client('sts')
    response = client.get_caller_identity()
    return(response['Account'])


def get_random_str():
    random_string = ''.join(random.choices(string.ascii_lowercase, k=8))
    # print(f"Got {random_string} as the random_string")
    return(random_string)


#
# Cross Account Role Assumption Methods
#
def get_creds(role_arn, session_name=None):
    """
    Request temporary credentials for the account. Returns a dict in the form of
    {
        creds['AccessKeyId'],
        creds['SecretAccessKey'],
        creds['SessionToken']
    }
    Which can be passed to a new boto3 client or resource.
    Takes an optional session_name which can be used by CloudTrail and IAM
    Raises AntiopeAssumeRoleError() if the role is not found or cannot be assumed.
    """
    client = boto3.client('sts')
    try:
        session = client.assume_role(RoleArn=role_arn, RoleSessionName=session_name)
        return(session['Credentials'])
    except ClientError as e:
        print(f"Failed to assume role {role_arn}: {e}")
        return(None)


def get_client(creds, type, region='us-east-1'):
    """
    Returns a boto3 client for the service "type" with credentials in the target account.
    Optionally you can specify the region for the client and the session_name for the AssumeRole.
    """
    client = boto3.client(type,
        aws_access_key_id = creds['AccessKeyId'],
        aws_secret_access_key = creds['SecretAccessKey'],
        aws_session_token = creds['SessionToken'],
        region_name = region)
    return(client)


def list_accounts():
    try:
        org_client = boto3.client('organizations')
        output = []
        response = org_client.list_accounts(MaxResults=20)
        while 'NextToken' in response:
            output = output + response['Accounts']
            response = org_client.list_accounts(MaxResults=20, NextToken=response['NextToken'])

        output = output + response['Accounts']
        return(output)
    except ClientError as e:
        if e.response['Error']['Code'] == 'AWSOrganizationsNotInUseException':
            print("AWS Organiations is not in use or this is not a payer account")
            return(None)
        else:
            raise ClientError(e)


def do_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--debug", help="print debugging info", action='store_true')
    parser.add_argument("--rolename", help="Role Name to Assume", default="steampipe-cloud")
    parser.add_argument("--role-session-name", help="Role Session Name to use during setup", default="steampipe")
    parser.add_argument("--org-role", help="Role to assume from the management account", default="OrganizationAccountAccessRole")
    parser.add_argument("--spc-endpoint", help="Steampipe Cloud Endpoint", default="cloud.steampipe.io")
    parser.add_argument("--spc-account-id", help="Steampipe Cloud Account ID to trust", default="316881668097")
    parser.add_argument("--regions", nargs='+', help="REGION1, REGION2 Configure Steampipe Cloud to only use these regions", default=["*"])

    parser.add_argument("--org-name", help="Org Name to add connections to", required=True)
    parser.add_argument("--workspace", help="Workspace to add connections to", required=True)
    args = parser.parse_args()
    return(args)

if __name__ == '__main__':
    try:
        args = do_args()
        main(args)
        exit(0)
    except KeyboardInterrupt:
        exit(1)