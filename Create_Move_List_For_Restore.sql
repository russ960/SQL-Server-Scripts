declare @path varchar(255)

create table #tmp
(
LogicalName nvarchar(128)
,PhysicalName nvarchar(260)
,Type char(1)
,FileGroupName nvarchar(128)
,Size numeric(20,0)
,MaxSize numeric(20,0),
Fileid tinyint,
CreateLSN numeric(25,0),
DropLSN numeric(25, 0),
UniqueID uniqueidentifier,
ReadOnlyLSN numeric(25,0),
ReadWriteLSN numeric(25,0),
BackupSizeInBytes bigint,
SourceBlocSize int,
FileGroupId int,
LogGroupGUID uniqueidentifier,
DifferentialBaseLSN numeric(25,0),
DifferentialBaseGUID uniqueidentifier,
IsReadOnly bit,
IsPresent bit,
TDEThumbprint varbinary(32) 
)
set @path = '' -- Path to backup file.

insert #tmp
EXEC ('restore filelistonly from disk = ''' + @path + '''')

select 'MOVE ''' + LogicalName + ''' TO ''' + PhysicalName + ''',' from #tmp
go
drop table #tmp
