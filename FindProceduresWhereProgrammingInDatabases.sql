/*
** Find procedures that call other procedures and you are programmming in the database.	**
** Written by: Michael J. Swart															**
** Source: http://michaeljswart.com/2016/04/are-you-programming-in-the-database/		**
*/

select 
    OBJECT_SCHEMA_NAME(p.object_id) as schemaName, 
    OBJECT_NAME(p.object_id) as procedureName,
    count(*) as [calls to other procedures]	
from sys.procedures p
cross apply sys.dm_sql_referenced_entities(schema_name(p.schema_id) + '.' + p.name, 'OBJECT') re
where re.referenced_entity_name in (select name from sys.procedures)
group by p.object_id
order by count(*) desc;