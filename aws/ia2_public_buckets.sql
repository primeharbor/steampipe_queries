SELECT status, region, resource, resource_owner_account, created_at, updated_at
FROM aws_security_tools.aws_accessanalyzer_finding
WHERE is_public = true
  AND resource_type = 'AWS::S3::Bucket'
  AND status = 'ACTIVE'