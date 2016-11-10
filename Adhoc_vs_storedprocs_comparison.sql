/*
Compiled Plans: Ad-Hoc Queries vs. Stored Procedures
*/

WITH CACHE_STATS AS (
SELECT 
cast(SUM(case when Objtype ='Proc'  then 1 else 0 end) as DECIMAL (10,2)) as [Proc],
cast(SUM(case when Objtype ='AdHoc'  then 1 else 0 end) as DECIMAL (10,2)) as [Adhoc],
cast(SUM(case when Objtype ='Proc' 
      or Objtype ='AdHoc' then 1 else 0 end)as DECIMAL (10,2)) as [Total]
FROM sys.dm_exec_cached_plans 
WHERE cacheobjtype='Compiled Plan' 
)
 SELECT
 cast(Adhoc/Total as decimal (5,2)) * 100 as Adhoc_pct,
 cast([Proc]  /Total as decimal (5,2)) * 100 as Proc_Pct
 FROM CACHE_STATS c