select arn, url, _ctx ->> 'connection_name' 
from aws_iam_open_id_connect_provider;