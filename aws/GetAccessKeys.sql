select 
	account_id,
	_ctx ->> 'connection_name' as connection_name,
	jsonb_array_elements(outputs) ->> 'OutputKey' as OutputKey,
	jsonb_array_elements(outputs) ->> 'OutputValue' as OutputValue

from aws_cloudformation_stack 

where name like 'StackSet-SteampipeUser-%';