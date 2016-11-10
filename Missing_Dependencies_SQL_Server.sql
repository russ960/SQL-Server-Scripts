/*
Find objects with missing dependencies.
*/
SELECT OBJECT_NAME(referencing_id) AS ObjectName, referenced_entity_name AS MissingObjectInReplication FROM sys.sql_expression_dependencies WHERE referenced_id IS NULL