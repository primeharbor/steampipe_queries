WITH instances AS (
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
)
SELECT DISTINCT
  aws_ec2_ami_shared.image_id as image_id,
  aws_ec2_ami_shared.owner_id as image_owner_id,
  aws_ec2_ami_shared.image_owner_alias as image_owner_name,
  instances.instance_name,
  instances.account_name,
  instances.region,
  aws_ec2_ami_shared.name as image_name
FROM
  instances
LEFT JOIN aws_ec2_ami_shared ON aws_ec2_ami_shared.image_id=instances.image_id
