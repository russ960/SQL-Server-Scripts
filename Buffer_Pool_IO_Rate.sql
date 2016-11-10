/*Buffer Pool I/O Rate - Rule of thumb is 20 but formula is: {Server RAM}/3600 (1 hour) = Rate.
You should also be aware that if your server is NUMA aware then you will want to take that into consideration whenever you try to use PLE as a performance metric.
Source: http://thomaslarock.com/2014/06/performance-metrics-for-sql-server-2014/
*/

SELECT (1.0*cntr_value/128) /
(SELECT 1.0*cntr_value
FROM sys.dm_os_performance_counters
WHERE object_name like '%Buffer Manager%'
AND lower(counter_name) = 'Page life expectancy')
AS [BufferPoolRate]
FROM sys.dm_os_performance_counters
WHERE object_name like '%Buffer Manager%'
AND counter_name = 'total pages'
GO
