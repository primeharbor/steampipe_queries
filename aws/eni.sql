SELECT
	eni.network_interface_id,
	eni.private_ip_address,
	eni.vpc_id AS vpc_id,
	eni.region,
	eni.status,
	eni.interface_type,
	eni.association_public_ip AS public_ip,
	CASE
		WHEN eni.attached_instance_id IS NOT null
			THEN eni.attached_instance_id
		ELSE eni.description
	END AS attached_resource,
	vpc.tags ->> 'Name' AS vpc_name,
	eni._ctx ->> 'connection_name' AS account_name
FROM
	aws_ec2_network_interface AS eni,
	aws_vpc AS vpc
WHERE vpc.vpc_id = eni.vpc_id
AND eni.attached_instance_id is not Null
AND eni.association_public_ip is not Null