select
  _ctx ->> 'connection_name' as account_name,
  case
    when association_public_ip is null then 'None'
    else host(association_public_ip)
  end as public_ip,
  description, attachment_status, attached_instance_id
from
  aws_ec2_network_interface 
where association_public_ip is not null;