SELECT
  name,
  _ctx ->> 'connection_name' as account_name,
  image_id,
  public
FROM aws_ec2_ami
WHERE public;