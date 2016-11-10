SELECT sys.server_principals.name as Owner, sys.databases.*
FROM sys.databases
LEFT OUTER JOIN sys.server_principals
	ON sys.databases.owner_sid = sys.server_principals.sid
WHERE is_trustworthy_on = 1
AND sys.databases.name <> 'msdb'