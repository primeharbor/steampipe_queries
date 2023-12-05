select
  i.instance_id as "Instance ID",
  i._ctx ->> 'connection_name' as "Account Name",
  i.tags ->> 'Name' as "Name",
  now() :: date - i.launch_time :: date as "Age in Days",
  i.launch_time as "Launch Time",
  i.instance_type as "Instance Type",
  i.instance_state as "State",
  i.public_ip_address as "Public IP",
  i.image_id as "AMI",
  i.account_id as "Account ID",
  i.region as "Region"
from
  aws_ec2_instance as i
order by
  i.launch_time,
  i.instance_id;  


