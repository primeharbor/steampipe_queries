select account_id, _ctx ->> 'connection_name' as account_name, title, region, status, last_updated_time
from aws_cloudformation_stack
where title NOT LIKE 'StackSet-%'
order by account_name, title