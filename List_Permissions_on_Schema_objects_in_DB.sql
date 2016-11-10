--Listing permissions on schema objects within a database
--Source: http://msdn.microsoft.com/en-us/library/ms188367.aspx


SELECT pr.principal_id, pr.name, pr.type_desc, 
    pe.state_desc, 
    pe.permission_name, s.name + '.' + o.name AS ObjectName
FROM sys.database_principals AS pr
JOIN sys.database_permissions AS pe
    ON pe.grantee_principal_id = pr.principal_id
JOIN sys.objects AS o
    ON pe.major_id = o.object_id
JOIN sys.schemas AS s
    ON o.schema_id = s.schema_id;