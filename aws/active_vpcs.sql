WITH eni_counts AS (
  SELECT vpc_id, count(*) as eni_count
  FROM aws_ec2_network_interface
  GROUP BY vpc_id

)
SELECT
	vpc.vpc_id AS vpc_id,
	vpc.tags ->> 'Name' as VPC_Name,
	vpc._ctx ->> 'connection_name' as account_name,
	vpc.account_id AS account_id,
	vpc.cidr_block AS vpc_cidr_block,
	vpc.is_default AS default,
	vpc.region AS region,
	eni.eni_count as eni_count
FROM
	aws_vpc AS vpc,
	eni_counts AS eni
WHERE
	eni.vpc_id = vpc.vpc_id
ORDER BY eni_count DESC