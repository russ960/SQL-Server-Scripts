IF OBJECT_ID('tempdb..#TEMPhtml2') IS NOT NULL
BEGIN
   DROP TABLE #TEMPhtml2
END

CREATE TABLE #TEMPhtml2
(
       [columns] VARCHAR (MAX)
)

DECLARE @finalhtmlout VARCHAR(MAX)
DECLARE @columns VARCHAR(8000)
DECLARE @colHeader VARCHAR(8000)
DECLARE @Final VARCHAR(8000)
DECLARE @clientName VARCHAR(50)
DECLARE @instanceName VARCHAR(50)
DECLARE @col VARCHAR(MAX)

/******************************************************************************************/
/*  DEBUG OUTPUT CONTROL    */
DECLARE @DEBUG SMALLINT = 0  --> 0 == OFF  1 == VERBOSE   2 == FINAL HTML ONLY
/******************************************************************************************/

/******************************************************************************************/
/* CLIENT NAME    */
SET @clientName = 'Test Client'
/******************************************************************************************/
SET @instanceName = CONVERT (VARCHAR,SERVERPROPERTY ('ComputerNamePhysicalNetBIOS')) + '\' + CONVERT(VARCHAR,SERVERPROPERTY('InstanceName'))

--initialize HTML page
SET @finalhtmlout = ' <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en"> <body> '
SET @finalhtmlout = @finalhtmlout + '<h1>' + @clientName + '</h1>' + '<h2>SQL Server Performance Snapshot</h2>'
SET @finalhtmlout = @finalhtmlout + '<h3>'+ CONVERT(VARCHAR,GETDATE(),100) + '</h3><br />'
/*********************************************************************************************/
--get General Info
--dump contents of the temp table
TRUNCATE TABLE #TEMPhtml2
--drop the temp table for this data if it already exists
IF OBJECT_ID('tempdb..#DBA_GenInfo') IS NOT NULL
BEGIN
   DROP TABLE #DBA_GenInfo
END
--create the temp table for this data
CREATE TABLE #DBA_GenInfo
(
NetbiosName VARCHAR(50),
SERVERNAME VARCHAR(50),
Edition VARCHAR(50),
[VERSION] VARCHAR(50),
[LEVEL] VARCHAR(50),
OnlineSince VARCHAR(50),
UptimeDays VARCHAR(9)
)
--declare any variables needed for data collection
DECLARE @vDate_Now AS DATETIME
DECLARE @vOnline_Since AS VARCHAR (19)
DECLARE @vUptime_Days AS INT
DECLARE @vDate_24_Hours_Ago AS DATETIME

--insert the data into the temp table defined above
SELECT
        @vOnline_Since = CONVERT (NVARCHAR (19), DB.create_date, 120)
       ,@vUptime_Days = DATEDIFF (DAY, DB.create_date, GETDATE ())
FROM
       [master].[sys].[databases] DB
WHERE
       DB.name = 'Perfstats' --this is a database that was installed at the same time as the instance

SET @vDate_24_Hours_Ago = GETDATE ()-1
SET @vDate_Now = @vDate_24_Hours_Ago+1
INSERT INTO #DBA_GenInfo
SELECT
        CONVERT (VARCHAR,SERVERPROPERTY ('ComputerNamePhysicalNetBIOS'))
       ,CONVERT (VARCHAR,@@SERVERNAME)
       ,REPLACE (CONVERT (VARCHAR, SERVERPROPERTY ('Edition')),' Edition','')
       ,CONVERT (VARCHAR,SERVERPROPERTY ('ProductVersion'))
       ,CONVERT (VARCHAR,SERVERPROPERTY ('ProductLevel'))
       ,CONVERT (VARCHAR,@vOnline_Since)
       ,CONVERT (VARCHAR,REVERSE (SUBSTRING (REVERSE (CONVERT (VARCHAR (15), CONVERT (MONEY, @vUptime_Days), 1)), 4, 15)))

IF @DEBUG = 1
BEGIN
       SELECT * FROM #DBA_GenInfo
END

--get the column names and store them in @columns
SELECT @columns = COALESCE(@columns + ' + '' </td><td> '' + ', '') +
                             'convert(varchar(100),isnull(' + c.name +','' ''))'
FROM tempdb.sys.columns c
INNER JOIN tempdb.sys.tables t ON c.object_id = t.object_id
WHERE t.name LIKE '#DBA_GenInfo%'

IF @DEBUG = 1
BEGIN
       SELECT @columns AS [columns]
END

--Setup the html column header
SET @colHeader = '<tr bgcolor=#EDFEDF align=center> <TR><TH><H3><BR>Server / Instance Information</H3></TH></TR>'
SELECT @colHeader = @colHeader + '<td><b> ' + c.name + '</b></td>'
FROM tempdb.sys.columns c
INNER JOIN tempdb.sys.tables t ON c.object_id = t.object_id
WHERE t.name LIKE '#DBA_GenInfo%'

SET @colHeader=@colHeader + '</tr>'

IF @DEBUG = 1
BEGIN
       SELECT @colHeader AS [columnHeader]
END

--get the data selection and insertion statements ready
SET @Final = 'insert into #TEMPhtml2 Select ''<tr><td>'' + ' + @columns + '+ ''</td></tr> '' from #DBA_GenInfo '

IF @DEBUG = 1
BEGIN
       SELECT @final AS FINAL
END

--execute the select
EXECUTE( @Final )

IF @DEBUG = 1
BEGIN
       SELECT @colHeader AS COLHEADER
       SELECT * FROM #TEMPhtml2 AS TEMPHTML2
END
--initialize the HTML table
SET @finalhtmlout = @finalhtmlout + ' <style type="text/css" media="all">  table { margin-bottom: 2em; border-collapse: collapse } td,th {border= 1 solid #999; padding: 0.2em 0.2em; font-size: 12;} </style> <table width="100%"> ' + @colHeader

IF @DEBUG = 1
BEGIN
       SELECT @finalhtmlout AS HTMLoutput1
END
-- insert values for retrieved metric in HTML format
SET @col = NULL
DECLARE HTML_Cur CURSOR
FOR SELECT [columns] FROM #TEMPhtml2
OPEN HTML_Cur
FETCH NEXT FROM HTML_Cur
INTO @col

WHILE @@FETCH_STATUS = 0
BEGIN
       SET @finalhtmlout= @finalhtmlout + @col + '</td></tr>'
       FETCH NEXT FROM HTML_Cur
       INTO @col
END

CLOSE HTML_Cur
DEALLOCATE HTML_Cur
-- clean up locals
DROP TABLE #DBA_GenInfo
SET @columns = NULL
SET @colHeader = NULL
SET @Final = NULL
/***********************************************************************************************/
-- get io stats
--dump contents of the temp table
TRUNCATE TABLE #TEMPhtml2

IF OBJECT_ID('tempdb..#DBA_PLEStats') IS NOT NULL
BEGIN
   DROP TABLE #DBA_IOStats
END

--get IO stats and generate HTML for data
CREATE TABLE #DBA_IOStats
(
[Fname] VARCHAR(25),
[Platter] VARCHAR(5),
[Database_Name] VARCHAR(75),
[Avg_IO_Stall_ms] VARCHAR(15),
[Number_of_Reads] VARCHAR(15),
[Number_of_Writes] VARCHAR(15),
[Number_of_Bytes_Read] VARCHAR(15),
[Number_of_Bytes_Written] VARCHAR(15),
[Total_IO_Stall] VARCHAR(15),
[Total_IO] VARCHAR(15)
)
    
DECLARE @TotalIO BIGINT ,
    @TotalBytes BIGINT ,
    @TotalStall BIGINT
 
SELECT  @TotalIO = SUM(num_of_reads + num_of_writes) ,
        @TotalBytes = SUM(num_of_bytes_read + num_of_bytes_written) ,
        @TotalStall = SUM(io_stall)
FROM    sys.dm_io_virtual_file_stats(-1, -1)

INSERT INTO #DBA_IOStats ([Fname],[Platter],[Database_Name],[Avg_IO_Stall_ms],[Number_of_Reads],
[Number_of_Writes],[Number_of_Bytes_Read],[Number_of_Bytes_Written],[Total_IO_Stall],[Total_IO])

SELECT  LOWER(SUBSTRING(physical_name, LEN(physical_name) - 2, 4)) ,
        UPPER(SUBSTRING(physical_name, 1, 3))  ,
        [DbName] = DB_NAME([f].[database_id]) ,
        CAST(( io_stall_read_ms + io_stall_write_ms ) / ( 1.0 + num_of_reads
                                                          + num_of_writes ) AS NUMERIC(10,
                                                              1)) ,
        [num_of_reads] ,
        [num_of_writes] ,
        [num_of_bytes_read] ,
        [num_of_bytes_written] ,
        [io_stall] ,
        [TotalIO] = ( num_of_reads + num_of_writes )
        FROM    sys.dm_io_virtual_file_stats(-1, -1) [IO]
        INNER JOIN sys.master_files f ON [IO].database_id = f.database_id
                                         AND [IO].[file_id] = f.[file_id]

IF @DEBUG = 1
BEGIN
       SELECT * FROM #DBA_IOStats
END

------Prepare column statement
SELECT @columns = COALESCE(@columns + ' + '' </td><td> '' + ', '') +
                             'convert(varchar(100),isnull(' + c.name +','' ''))'
FROM tempdb.sys.columns c
INNER JOIN tempdb.sys.tables t ON c.object_id = t.object_id
WHERE t.name LIKE '#DBA_IOStats%'

IF @DEBUG = 1
BEGIN
       SELECT @columns AS [columns]
END
----Prepare column Header
SET @colHeader = '<tr bgcolor=#EDFEDF align=center> <TR><TH><H3><BR>File IO Statistics</H3></TH></TR>'
SELECT @colHeader = @colHeader + '<td><b> ' + c.name + '</b></td>'
FROM tempdb.sys.columns c
INNER JOIN tempdb.sys.tables t ON c.object_id = t.object_id
WHERE t.name LIKE '#DBA_IOStats%'

SET @colHeader=@colHeader + '</tr>'

IF @DEBUG = 1
BEGIN
       SELECT @colHeader AS [columnHeader]
END
------prepare final output
SET @Final = 'insert into #TEMPhtml2 Select ''<tr><td>'' + ' + @columns + '+ ''</td></tr> '' from #DBA_IOStats '

IF @DEBUG = 1
BEGIN
       SELECT @final AS FINAL
END

EXECUTE( @Final )

IF @DEBUG = 1
BEGIN
       SELECT @colHeader AS COLHEADER
       SELECT * FROM #TEMPhtml2 AS TEMPHTML2
END

--initialize table
SET @finalhtmlout = @finalhtmlout + ' <style type="text/css" media="all">  table { margin-bottom: 2em; border-collapse: collapse } td,th {border= 1 solid #999; padding: 0.2em 0.2em; font-size: 12;} </style> <table width="100%"> ' + @colHeader

IF @DEBUG = 1
BEGIN
       SELECT @finalhtmlout AS HTMLoutput1
END

-- insert values for retrieved metric in HTML format
SET @col=NULL
DECLARE HTML_Cur CURSOR
FOR SELECT [columns] FROM #TEMPhtml2

OPEN HTML_Cur
FETCH NEXT FROM HTML_Cur
INTO @col

WHILE @@FETCH_STATUS = 0
BEGIN
       SET @finalhtmlout= @finalhtmlout + @col + '</td></tr>'
       FETCH NEXT FROM HTML_Cur
       INTO @col
END

CLOSE HTML_Cur
DEALLOCATE HTML_Cur
-- clean up locals
DROP TABLE #DBA_IOStats
SET @columns = NULL
SET @colHeader = NULL
SET @Final = NULL
/**********************************************************************************************/
-- closes the HTML file
SET @finalhtmlout= @finalhtmlout + ' </table></body></htmL>'

IF OBJECT_ID('tempdb..##tempOut') IS NOT NULL
BEGIN
   DROP TABLE ##tempOut
END

CREATE TABLE ##tempOut
(
       html VARCHAR(MAX)
)

INSERT INTO ##tempOut
SELECT @finalhtmlout
-- write html file to disk
DECLARE @filename VARCHAR(75)

/******************************************************************************************/
/*  File Name    */
SET @filename = 'c:\dbahtml\'
/******************************************************************************************/
SET @filename = @filename + CONVERT(VARCHAR,SERVERPROPERTY('InstanceName')) + '_' + CONVERT(VARCHAR,GETDATE(),112) + '.html'
DECLARE @string AS NVARCHAR(4000)
SELECT    @string = 'bcp ##tempOut  out ' + @filename + ' -T -c -S  ' + @instanceName

EXEC master.dbo.xp_cmdshell @string , no_output

IF @DEBUG >= 1
BEGIN
       SELECT @string AS [BCP command]
       SELECT @filename AS [FileName]
       SELECT @finalhtmlout AS [Final HTML OUTPUT]
END

DROP TABLE ##tempOut