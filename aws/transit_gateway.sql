select
  _ctx ->> 'connection_name' as Account,
  transit_gateway_attachment_id,
  transit_gateway_id,
  resource_id,
  region,
  association_state
from
  aws_ec2_transit_gateway_vpc_attachment;