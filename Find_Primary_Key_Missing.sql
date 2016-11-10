-- Query finds tables with no primary key defined
-- Source: http://www.mssqltips.com/sqlservertip/1237/finding-primary-keys-and-missing-primary-keys-in-sql-server/

SELECT c.name, b.name  
FROM sys.tables b  
INNER JOIN sys.schemas c ON b.schema_id = c.schema_id  
WHERE b.type = 'U'  
AND NOT EXISTS 
(SELECT a.name  
FROM sys.key_constraints a  
WHERE a.parent_object_id = b.OBJECT_ID  
AND a.schema_id = c.schema_id  
AND a.type = 'PK' )
GO
