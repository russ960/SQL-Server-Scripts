-- Find date, days and seconds since instance restart from tempdb.
-- Source: https://www.simple-talk.com/sql/database-administration/exploring-your-sql-server-databases-with-t-sql/
SELECT @@Servername AS ServerName
	,create_date AS ServerStarted
	,DATEDIFF(s, create_date, GETDATE()) / 86400.0 AS DaysRunning
	,DATEDIFF(s, create_date, GETDATE()) AS SecondsRunnig
FROM sys.databases
WHERE NAME = 'tempdb';
GO