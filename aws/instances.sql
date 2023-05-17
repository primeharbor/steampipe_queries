SELECT ec2.instance_id, ec2.instance_type, ec2.instance_state, ec2.image_id, ec2.region,
	ec2.launch_time,
	ec2.private_ip_address,
	ec2.public_ip_address,
	ec2.tags ->> 'Name' as instance_name,
	org.name as account_name,
	org.id as account_id
FROM aws_ec2_instance as ec2,
	aws_payer.aws_organizations_account as org
WHERE org.id = ec2.account_id;
