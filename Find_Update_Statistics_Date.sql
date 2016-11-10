-- Source: http://blog.sqlauthority.com/2010/01/25/sql-server-find-statistics-update-date-update-statistics/

USE AdventureWorks
GO
SELECT name AS index_name,
STATS_DATE(OBJECT_ID, index_id) AS StatsUpdated
FROM sys.indexes
WHERE OBJECT_ID = OBJECT_ID('HumanResources.Department')
GO