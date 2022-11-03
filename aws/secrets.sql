select
  name,
  description,
  region, 
  _ctx ->> 'connection_name' as account_name,
  account_id,
  last_accessed_date
from
  aws_secretsmanager_secret
order by last_accessed_date DESC;