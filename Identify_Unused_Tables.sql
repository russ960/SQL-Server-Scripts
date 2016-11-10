--Identify tables unused since the last restart of SQL Server instance
SELECT DISTINCT OBJECTNAME = OBJECT_NAME(I.OBJECT_ID),I.OBJECT_ID
FROM SYS.INDEXES AS I
INNER JOIN SYS.OBJECTS AS O
ON I.OBJECT_ID = O.OBJECT_ID
WHERE OBJECTPROPERTY(O.OBJECT_ID,'IsUserTable') = 1
AND I.OBJECT_ID
NOT IN (SELECT DISTINCT I.OBJECT_ID
FROM SYS.DM_DB_INDEX_USAGE_STATS AS S ,SYS.INDEXES AS I
WHERE S.OBJECT_ID = I.OBJECT_ID
AND I.INDEX_ID = S.INDEX_ID
AND DATABASE_ID = DB_ID(db_name()))

--Uptime of a particular SQL Server service instance
SELECT MIN ([login_time]) FROM sysprocesses;

-- Identify cached (used) SPs (works on SQL Server 2008 systems)
SELECT  distinct OBJECT_NAME(object_id, database_id) 'proc name'
FROM sys.dm_exec_procedure_stats AS d
where database_id = 5
