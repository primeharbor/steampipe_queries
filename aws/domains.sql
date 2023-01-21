select
  domain_name,
  auto_renew,
  expiration_date,
  _ctx ->> 'connection_name' as domain_account_name
from
  aws_route53_domain