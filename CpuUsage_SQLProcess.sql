-- Determines the cpu used by the SQL Server process.

SELECT 
    case baseValueCounter
        when 0 then 0
        else convert(float, cntr_value) / convert(float, baseValueCounter)*100
    end as 'cpu_usage'
FROM 
(SELECT cntr_value FROM sys.dm_os_performance_counters
WHERE counter_name LIKE '%CPU usage%'
AND object_name LIKE '%Workload Group Stats%'
AND cntr_type = 537003264
AND instance_name = 'default') Counter
,
(SELECT cntr_value AS baseValueCounter FROM sys.dm_os_performance_counters
WHERE counter_name LIKE '%CPU usage%'
AND object_name LIKE '%Workload Group Stats%'
AND cntr_type = 1073939712
AND instance_name = 'default') baseValue
