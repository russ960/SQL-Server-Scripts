-- Query Plan Cached Plans
SELECT query_plan FROM sys.dm_exec_cached_plans c CROSS APPLY sys.dm_exec_query_plan(c.plan_handle) p 