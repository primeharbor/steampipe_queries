select
  DISTINCT jsonb_object_keys(tags) as tag_key
from
  aws_tagging_resource