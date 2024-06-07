SELECT
    arn, url,
    _ctx ->> 'connection_name' as account_name
FROM aws_iam_open_id_connect_provider;