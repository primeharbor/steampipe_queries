
-- This query won't work until this issue is resolved:
-- https://github.com/turbot/steampipe-plugin-aws/issues/1373

-- The hosted zone_id is a global identitfer, and so each connection is attempting to query the join. 403's get returned

with zones as (
	select id
	from
		aws_route53_zone
	where private_zone=false OR private_zone is null  
)
select
  name,
  type,
  records,
  alias_target
FROM
  zones
LEFT JOIN aws_route53_record ON aws_route53_record.zone_id=zones.id