SELECT
  name,
  arn,
  _ctx ->> 'connection_name' as account_name,
  url_config ->> 'FunctionURL' as function_url,
  url_config ->> 'AuthType' as auth
FROM
  aws_lambda_function
WHERE url_config IS NOT null;