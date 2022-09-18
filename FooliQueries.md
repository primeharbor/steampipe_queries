# Fooli Steampipe Queries

## Organization Accounts with Tags
Pull a CSV report of all accounts in the organization with three specific tags
Because other accounts in the org are delegated admin, the Steampipe aggregate will return duplicate results, so this is run only in the Fooli Payer

```sql
SELECT id, name, status,
  tags ->> 'ExecutiveOwner' as Executive_Owner,
  tags ->> 'TechnicalContact' as Technical_Contact,
  tags ->> 'DataClassification' as Data_Classification
FROM aws_fooli_payer.aws_organizations_account
```

## ENI Information

Pull all the ENI information. Merge the `description` or `attached_instance` id into a single column
Cross reference against the payer's `aws_organizations_account` table to get the AWS account _name_ in addition to the account id. Also cross-reference in the VPC's name from the `aws_vpc` table.

```sql
SELECT
	eni.network_interface_id,
	eni.private_ip_address,
	eni.vpc_id as vpc_id,
	eni.region,
	eni.status,
	eni.interface_type,
  eni.association_public_ip as public_ip,
  CASE
    WHEN eni.attached_instance_id is not null THEN eni.attached_instance_id
    ELSE eni.description
  end as attached_resource,
  vpc.tags ->> 'Name' as vpc_name,
  org.name as account_name

FROM
	aws_ec2_network_interface as eni,
	aws_vpc as vpc,
	aws_fooli_payer.aws_organizations_account as org
WHERE vpc.vpc_id = eni.vpc_id
  AND org.id = eni.account_id

```

## Instances

Download a report of all EC2 Instances in the organization. Cross reference it with the `aws_organizations_account` to get the AWS account _name_ in addition to the `account_id`.

```sql
SELECT ec2.instance_id, ec2.instance_type, ec2.instance_state, ec2.image_id,
	ec2.launch_time,
	ec2.private_ip_address,
	ec2.public_ip_address,
	jsonb_array_elements(ec2.security_groups) ->> 'GroupName' as security_group_name,
	org.name as account_name,
	org.id as account_id
FROM aws_ec2_instance as ec2,
	aws_fooli_payer.aws_organizations_account as org
WHERE org.id = ec2.account_id
```