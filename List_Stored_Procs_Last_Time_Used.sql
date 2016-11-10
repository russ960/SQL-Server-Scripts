/*
Gather list of stored procedures and last execution time.
*/

select b.name, a.last_execution_time
from sys.dm_exec_procedure_stats a 
inner join sys.objects b on a.object_id = b.object_id 
where DB_NAME(a.database_ID) = '' -- Database Name