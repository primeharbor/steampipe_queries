with domains as (
select
  domain_name,
  auto_renew,
  expiration_date,
  _ctx ->> 'connection_name' as domain_account_name
from
  aws_route53_domain
)
select
  case
    when z.name is null then d.domain_name
    else z.name
  end as name,
  z.id,
  z.resource_record_set_count,
  d.domain_account_name,
  z._ctx ->> 'connection_name' as zone_account_name
from
  aws_route53_zone as z
  FULL  join domains as d on z.name = CONCAT(d.domain_name, '.')
where private_zone=false OR private_zone is null