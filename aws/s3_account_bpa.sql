select
  _ctx ->> 'connection_name',
  account_id,
  block_public_acls,
  block_public_policy,
  ignore_public_acls,
  restrict_public_buckets
from
  aws_s3_account_settings;