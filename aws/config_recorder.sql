select
  recording_group,
  status_recording,
  region,
  _ctx ->> 'connection_name' as account_name
from
  aws_config_configuration_recorder;