select
  id,
  _ctx ->> 'connection_name' as account_name,
  tags ->> 'Name' as peer_name,
  accepter_owner_id,
  accepter_region,
  accepter_vpc_id,
  expiration_time,
  requester_owner_id,
  requester_region,
  requester_vpc_id
from
  aws_vpc_peering_connection
