
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
order by name