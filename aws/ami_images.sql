select
  name,
  image_id,
  state,
  image_location,
  _ctx ->> 'connection_name' as account,
  creation_date,
  public
from
  aws_ec2_ami
order by creation_date;