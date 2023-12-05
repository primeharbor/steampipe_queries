select
_ctx ->> 'connection_name' as account_name,
backup_vault_name,resource_type, count(distinct(resource_arn))
from aws_backup_recovery_point
where backup_vault_name like 'BCPVault%'
group by account_name, backup_vault_name, resource_type