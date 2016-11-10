/* Memory Grants - This counter helps me understand if I am seeing internal memory pressure. 
Ideally this value should be as close to 0 as possible. 
Sustained periods of non-zero values are worth investigating
Source: http://thomaslarock.com/2014/06/performance-metrics-for-sql-server-2014/
*/

SELECT cntr_value                                                                                                       
FROM sys.dm_os_performance_counters 
WHERE counter_name = 'Memory Grants Pending'
GO
