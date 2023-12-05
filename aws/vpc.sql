SELECT
	vpc.vpc_id AS vpc_id,
	vpc.tags ->> 'Name' as VPC_Name,
	vpc.account_id AS account_id,
	vpc.cidr_block AS vpc_cidr_block,
	vpc.is_default AS default,
	vpc.region AS region,
	vpc._ctx ->> 'connection_name' AS account_name
FROM
	aws_vpc AS vpc;
