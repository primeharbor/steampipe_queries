select name, region,
	_ctx ->> 'connection_name' as account_name,
	creation_date, bucket_policy_is_public
from aws_s3_bucket
order by account_name;