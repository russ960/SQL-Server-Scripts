-- Returns the query needed to fix orphaned users.
SELECT 'ALTER USER ' + NAME + ' WITH LOGIN = ' + NAME
FROM sysusers
WHERE issqluser = 1
	AND NAME NOT IN (
		'guest'
		,'dbo'
		,'sys'
		,'INFORMATION_SCHEMA'
		)
	AND SUSER_SNAME(sid) IS NULL
GO