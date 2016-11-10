/* Please replace the use <databasename> and the <username> */
USE < databasename >
GO

IF NOT EXISTS (
		SELECT *
		FROM sys.database_principals dprinc
		INNER JOIN sys.database_permissions dperm ON dprinc.principal_id = dperm.grantee_principal_id
		WHERE dprinc.NAME = '<username>'
			AND dperm.permission_name = 'CONNECT'
		)
BEGIN
	GRANT CONNECT
		TO [<username>]
END
GO


