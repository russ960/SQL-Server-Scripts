SELECT top 100  qs.sql_handle, qs.execution_count,     qs.total_worker_time AS Total_CPU, 
qs.total_elapsed_time,     
st.text,     qp.query_plan FROM    sys.dm_exec_query_stats AS qs 
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st 
CROSS apply sys.dm_exec_query_plan (qs.plan_handle) AS qp 
WHERE ST.TEXT LIKE '%%' --procedure name
ORDER BY qs.total_worker_time DESC
