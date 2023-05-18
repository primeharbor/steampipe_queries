select
    f.title,
    f.id,
    r ->> 'Type' as resource_type,
    r ->> 'Id' as resource_arn,
    (regexp_match(f.id, ':([0-9]+):')) [ 1 ] AS source_account,
    f.account_id,
    f.region
from 
    REPLACE_WITH_SECURITY_ACCOUNT.aws_securityhub_finding as f,
    jsonb_array_elements(f.resources) AS r
where f.compliance ->> 'Status' = 'FAILED'
  and f.severity ->> 'Label' = 'CRITICAL'
  and f.record_state = 'ACTIVE'
  and f.generator_id LIKE 'security-control%'