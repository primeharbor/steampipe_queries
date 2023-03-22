SELECT
  name,
  account_id,
  _ctx ->> 'connection_name' AS account_name,
  create_date,
  attached_policy_arns,
  login_profile  ->> 'CreateDate' AS password_creation_date,
  mfa_enabled
FROM
  aws_iam_user;