/*Average Task Counts 
-	 High Avg Task Counts (>10) are often caused by blocking or other resource contention
-    High Avg Runnable Task Counts (>1) are a good sign of CPU pressure
-    High Avg Pending DiskIO Counts (>1) are a sign of disk pressure
Source: http://thomaslarock.com/2014/06/performance-metrics-for-sql-server-2014/
*/

SELECT AVG(current_tasks_count) AS [Avg Task Count],
AVG(runnable_tasks_count) AS [Avg Runnable Task Count],
AVG(pending_disk_io_count) AS [Avg Pending DiskIO Count]
FROM sys.dm_os_schedulers WITH (NOLOCK)
WHERE scheduler_id < 255 OPTION (RECOMPILE)
GO
