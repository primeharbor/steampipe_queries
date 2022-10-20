SELECT
	vpc.vpc_id AS vpc_id,
	vpc.tags ->> 'Name' as VPC_Name,
	vpc.account_id AS account_id,
	org.name AS account_name,
	vpc.cidr_block AS vpc_cidr_block,
	vpc.is_default AS default,
	vpc.region AS region
FROM
	aws_vpc AS vpc,
	aws_payer.aws_organizations_account AS org
WHERE
	org.id = vpc.account_id
