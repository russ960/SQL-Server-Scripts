/*
Run DBCC CHECKDB PHYSICAL_ONLY for a list of tables.
Author: Donbosco Vazhappilly
03-29-2016

*/

DECLARE @databaseList as CURSOR;
DECLARE @databaseName as NVARCHAR(500);
DECLARE @tsql AS NVARCHAR(500);

SET @databaseList = CURSOR  LOCAL FORWARD_ONLY STATIC READ_ONLY 
FOR
  SELECT QUOTENAME([name])
  FROM sys.databases
  WHERE [state] = 0
  AND [is_read_only] = 0 AND DATABASE_ID > 4
	AND NAME NOT IN (''); -- List of databases to exclude.
OPEN @databaseList;
FETCH NEXT FROM @databaseList into @databaseName;
WHILE @@FETCH_STATUS = 0
BEGIN
SET @tsql = N'DBCC CheckDB(' + @databaseName + ') WITH PHYSICAL_ONLY;';
EXECUTE (@tsql);
FETCH NEXT FROM @databaseList into @databaseName;
END
CLOSE @databaseList;
DEALLOCATE @databaseList;
