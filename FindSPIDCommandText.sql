-- Query to get current full SQL Text of a running one or more SPIDs
-- wait type and resource consumption info
-- NOTE: Run this pointing to the customer database to get 
--       current active connections information
SELECT DISTINCT
	   DB_NAME(r.database_id) AS DatabaseName,
       st.[text],
       r.session_id,
       r.[status],
       wt.wait_type,
       r.command,
       r.cpu_time,
	   r.blocking_session_id,
       r.total_elapsed_time,
       p.hostname,
       p.program_name
  FROM sys.dm_exec_requests r with (nolock)
 INNER JOIN master.dbo.sysprocesses p with (nolock)
    ON p.spid = r.session_id
  LEFT JOIN sys.dm_os_waiting_tasks wt with (nolock)
    ON wt.session_id = p.spid
 CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) AS st
 WHERE r.session_id <> @@SPID
   AND r.database_id > 4   
ORDER By 1
go
