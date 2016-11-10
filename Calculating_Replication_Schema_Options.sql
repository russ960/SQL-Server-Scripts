/*
Source: http://www.englishtosql.com/english-to-sql-blog/2010/9/9/calculating-replication-schema-options.html
*/

/* PROVIDES THE REPLICATION OPTIONS ENABLED FOR A GIVEN @SCHEMA_OPTION IN SYSARTICLES */
declare @schema_option varbinary(8) = 0x0000000048000001  --< PUT YOUR SCHEMA_OPTION HERE

set nocount on
declare @OptionTable table ( HexValue varbinary(8), IntValue as cast(HexValue as bigint), OptionDescription varchar(255))
insert into @OptionTable (HexValue, OptionDescription)
select 0x01 ,'Generates object creation script'
union all  select 0x02 ,'Generates procs that propogate changes for the article'
union all  select 0x04 ,'Identity columns are scripted using the IDENTITY property'
union all  select 0x08 ,'Replicate timestamp columns (if not set timestamps are replicated as binary)'
union all  select 0x10 ,'Generates corresponding clustered index'
union all  select 0x20 ,'Converts UDT to base data types'
union all  select 0x40 ,'Create corresponding nonclustered indexes'
union all  select 0x80 ,'Replicate pk constraints'
union all  select 0x100 ,'Replicates user triggers'
union all  select 0x200 ,'Replicates foreign key constraints'
union all  select 0x400 ,'Replicates check constraints'
union all  select 0x800  ,'Replicates defaults'
union all  select 0x1000 ,'Replicates column-level collation'
union all  select 0x2000 ,'Replicates extended properties'
union all  select 0x4000 ,'Replicates UNIQUE constraints'
union all  select 0x8000 ,'Not valid'
union all  select 0x10000 ,'Replicates CHECK constraints as NOT FOR REPLICATION so are not enforced during sync'
union all  select 0x20000 ,'Replicates FOREIGN KEY constraints as NOT FOR REPLICATION so are not enforced during sync'
union all  select 0x40000 ,'Replicates filegroups'
union all  select 0x80000 ,'Replicates partition scheme for partitioned table'
union all  select 0x100000 ,'Replicates partition scheme for partitioned index'
union all  select 0x200000 ,'Replicates table statistics'
union all  select 0x400000 ,'Default bindings'
union all  select 0x800000 ,'Rule bindings'
union all  select 0x1000000 ,'Full text index'
union all  select 0x2000000 ,'XML schema collections bound to xml columns not replicated'
union all  select 0x4000000 ,'Replicates indexes on xml columns'
union all  select 0x8000000 ,'Creates schemas not present on subscriber'
union all  select 0x10000000 ,'Converts xml columns to ntext'
union all  select 0x20000000 ,'Converts (max) data types to text/image'
union all  select 0x40000000 ,'Replicates permissions'
union all  select 0x80000000 ,'Drop dependencies to objects not part of publication'
union all  select 0x100000000 ,'Replicate FILESTREAM attribute (2008 only)'
union all  select 0x200000000 ,'Converts date & time data types to earlier versions'
union all  select 0x400000000 ,'Replicates compression option for data & indexes'
union all  select 0x800000000  ,'Store FILESTREAM data on its own filegroup at subscriber'
union all  select 0x1000000000 ,'Converts CLR UDTs larger than 8000 bytes to varbinary(max)'
union all  select 0x2000000000 ,'Converts hierarchyid to varbinary(max)'
union all  select 0x4000000000 ,'Replicates filtered indexes'
union all  select 0x8000000000 ,'Converts geography, geometry to varbinary(max)'
union all  select 0x10000000000 ,'Replicates geography, geometry indexes'
union all  select 0x20000000000 ,'Replicates SPARSE attribute '

select HexValue,OptionDescription as 'Schema Options Enabled'
From @OptionTable where (cast(@schema_option as bigint) & cast(HexValue as bigint)) <> 0 