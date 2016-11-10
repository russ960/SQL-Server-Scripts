-- Find untrusted foreign keys.
-- Source: http://www.sqlservercentral.com/blogs/waterox-sql/2014/10/17/untrusted-foreign-keys/
-- Reenable with: ALTER TABLE <s.name from results>.<o.name from results> WITH CHECK CHECK CONSTRAINT <i.name from results>

SELECT '[' + s.name + '].[' + o.name + '].[' + i.name + ']' AS keyname
FROM    sys.foreign_keys i
        INNER JOIN sys.objects o ON i.parent_object_id = o.object_id
        INNER JOIN sys.schemas s ON o.schema_id = s.schema_id
WHERE   i.is_not_trusted = 1
        AND i.is_not_for_replication = 0
        AND i.is_disabled = 0