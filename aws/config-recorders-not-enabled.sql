
-- This query returns a list of all account/regions where config is not enabled
-- Remove AND r.name IS NULL to see a full report

SELECT r.name, a.region, r.status_recording, a.account_id, 
	r.recording_group ->> 'AllSupported' as AllSupported,
	r.recording_group ->> 'IncludeGlobalResourceTypes' as GlobalTypes
FROM aws_region AS a
FULL OUTER JOIN aws_config_configuration_recorder AS r 
	ON (r.account_id = a.account_id AND a.region = r.region)
WHERE a.opt_in_status != 'not-opted-in' 
	AND r.name IS NULL
ORDER BY a.region