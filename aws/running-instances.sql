SELECT
  ec2.instance_id,
  ec2.instance_type,
  ec2.tags ->> 'Name' AS instance_name,
  ec2._ctx ->> 'connection_name' AS account_name,
  ec2.instance_state,
  ec2.region,
  ec2.launch_time,
  ec2.private_ip_address,
  ec2.public_ip_address
FROM
  aws_ec2_instance AS ec2
WHERE
  ec2.instance_state = 'running';