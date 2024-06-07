SELECT
	name,
	region, account_id,
	_ctx ->> 'connection_name' as account_name,
	creation_date,
	bucket_policy_is_public,
	block_public_acls,
	block_public_policy,
	ignore_public_acls,
	restrict_public_buckets,
	object_ownership_controls
FROM aws_s3_bucket
ORDER BY account_name;