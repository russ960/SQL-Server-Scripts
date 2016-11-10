-- Determine if user is in sa role.
SELECT name, SUSER_NAME(role_principal_id) AS ServerRole
FROM sys.server_role_members a
INNER JOIN sys.server_principals b
ON a.member_principal_id = b.principal_id
WHERE SUSER_NAME(member_principal_id) = '<username>'
GO