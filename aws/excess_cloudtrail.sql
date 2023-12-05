select
  distinct(arn),
  name,
  _ctx ->> 'connection_name' as account_name,
  home_region,
  is_multi_region_trail,
  is_logging,
  log_group_arn,
  event_selectors
from
  aws_cloudtrail_trail
where is_organization_trail is not True
  and is_logging is True
order by name