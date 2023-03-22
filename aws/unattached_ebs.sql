SELECT
  title,
  volume_id,
  volume_type,
  tags ->> 'Name' AS volume_name,
  size,
  state,
  region,
  _ctx ->> 'connection_name' AS account_name
FROM
  aws_ebs_volume
WHERE
  jsonb_array_length(attachments) = 0
ORDER BY account_name;