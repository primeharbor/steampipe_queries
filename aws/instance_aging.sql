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
  i.region as "Region",
  i.metadata_options ->> 'HttpTokens' as "IMDSv2"
from
  aws_ec2_instance as i
where i.instance_state = 'running'
  and i.launch_time >= '2024-01-01T00:00:00-00:00'
order by
  i.launch_time,
  i.instance_id;


