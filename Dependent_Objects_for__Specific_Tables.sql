--Queries for tables with dependent objects.
DECLARE @msg VARCHAR(250)
DECLARE @object_name sysname
DECLARE @idnum int
DECLARE @stopval int
DECLARE @minval int
set @stopval = 0


--Load into temp table
CREATE TABLE #objects1
	(
	name varchar(100) NOT NULL,
	object_id int NOT NULL
	)  ON [PRIMARY]


INSERT INTO #objects1 (name, object_id)
select name, object_id from sys.objects with(NOLOCK) where name in 
('') --Object list
and type = 'U' and schema_id = 1 order by object_id 



select @minval=min(object_id) from #objects1

--Determines dependencies for all tables.
select @object_name=name, @idnum=object_id from #objects1 order by object_id

WHILE @stopval <> 1
BEGIN
	print @object_name
    SELECT routine_name, routine_type FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_DEFINITION LIKE '%'+@object_name+'%'
	IF @@rowcount = 0 Print @object_name + ' has no dependencies'
	
    --next select of cursor free loop
    select @object_name=name, @idnum=OBJECT_ID  from #objects1 where object_id < @idnum order by object_id

	if @idnum = @minval set @stopval=1
	
END

	-- Addresses the first the last table
	select @minval=min(object_id) from #objects1
    SELECT routine_name, routine_type FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_DEFINITION LIKE '%'+@object_name+'%'
	IF @@rowcount = 0 Print @object_name + ' has no dependencies'
	print @object_name
	
DROP TABLE #objects1
