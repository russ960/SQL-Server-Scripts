SELECT b.NAME
	,database_id
	,sum((size * 8) / 1024)
FROM sys.master_files a
JOIN sys.sysdatabases b ON a.database_id = b.dbid
GROUP BY b.NAME
	,database_id
