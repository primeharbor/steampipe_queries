SELECT
  name,
  image_id,
  state,
  region,
  _ctx ->> 'connection_name' AS account,
  creation_date,
  public
FROM
  aws_ec2_ami
ORDER BY
  creation_date DESC;