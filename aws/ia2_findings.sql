WITH findings as (
	select 
	jsonb_array_elements(findings) as finding
	from aws_playon_security.aws_accessanalyzer_analyzer
)
select 
finding ->> 'ResourceType' as type,
finding ->> 'ResourceOwnerAccount' as account_id,
finding ->> 'Resource' as arn,
finding ->> 'Status' as status
from findings
where findings.finding ->> 'IsPublic' LIKE 'true'
order by type