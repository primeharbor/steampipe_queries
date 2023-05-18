WITH org_accounts AS (
  SELECT
    id
  FROM
    seccdc.aws_organizations_account
), instances AS (
  SELECT
    instance_id,
    instance_type,
    account_id,
    tags ->> 'Name' AS instance_name,
    _ctx ->> 'connection_name' AS account_name,
    instance_state,
    region,
    image_id
  FROM
    aws_ec2_instance
), used_ami_owners AS (
  SELECT
    instances.instance_name,
    instances.account_name,
    instances.region,
    aws_ec2_ami_shared.region as ami_region,
    aws_ec2_ami_shared.name,
    aws_ec2_ami_shared.image_id,
    aws_ec2_ami_shared.owner_id as owner_id
  FROM
    instances
  JOIN aws_ec2_ami_shared ON aws_ec2_ami_shared.image_id=instances.image_id
  WHERE
    aws_ec2_ami_shared.account_id=instances.account_id
)
SELECT
  used_ami_owners.instance_name,
  used_ami_owners.account_name,
  used_ami_owners.region,
  used_ami_owners.image_id,
  used_ami_owners.owner_id
FROM
  used_ami_owners
  LEFT JOIN org_accounts ON org_accounts.id = used_ami_owners.owner_id
WHERE
  org_accounts.id IS NULL
