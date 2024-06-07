SELECT
  snapshot_id,
  arn,
  volume_id,
  _ctx ->> 'connection_name' as account_name,
  perm ->> 'UserId' as userid,
  perm ->> 'Group' as group
FROM
  aws_ebs_snapshot
  CROSS JOIN jsonb_array_elements(create_volume_permissions) as perm
WHERE perm ->> 'Group' = 'all';