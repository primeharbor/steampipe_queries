SELECT name, _ctx ->> 'connection_name' as account_name,
account_id, create_date as user_create_date, mfa_enabled,
login_profile ->> 'CreateDate' as login_profile_create_date
FROM aws_iam_user where login_profile is not Null