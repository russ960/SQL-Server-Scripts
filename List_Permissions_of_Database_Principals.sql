--Listing all the permissions of database principals
--Source: http://msdn.microsoft.com/en-us/library/ms188367.aspx


SELECT pr.principal_id, pr.name, pr.type_desc, 
    pe.state_desc, pe.permission_name
FROM sys.database_principals AS pr
JOIN sys.database_permissions AS pe
    ON pe.grantee_principal_id = pr.principal_id;