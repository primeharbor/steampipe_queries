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
  AND org.id = eni.account_id;
