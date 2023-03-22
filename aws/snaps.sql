SELECT
  snapshot_id,
  volume_size,
  tags ->> 'Name' AS snapshot_name,
  state,
  region,
  _ctx ->> 'connection_name' AS account_name
FROM
  aws_ebs_snapshot
ORDER BY account_name