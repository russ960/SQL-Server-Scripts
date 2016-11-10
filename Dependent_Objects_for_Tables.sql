--Queries for tables with dependent objects.
DECLARE @msg VARCHAR(250)
DECLARE @object_name sysname
DECLARE @idnum int
DECLARE @stopval int
DECLARE @minval int
set @stopval = 0
select @minval=min(id) from sys.sysobjects with(NOLOCK) where type = 'U'

--Determines dependencies for all tables.
select @object_name=name, @idnum=id from sys.sysobjects with(NOLOCK) where type = 'U' order by id

WHILE @stopval <> 1
BEGIN
	print @object_name
    SELECT routine_name, routine_type FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_DEFINITION LIKE '%'+@object_name+'%'
	IF @@rowcount = 0 Print @object_name + ' has no dependencies'
	
    --next select of cursor free loop
    select @object_name=name, @idnum=id  from sys.sysobjects with(NOLOCK) 
	where type = 'U' and id < @idnum order by id

	if @idnum = @minval set @stopval=1
	
END

	-- Addresses the first the last table
	select @minval=min(id) from sys.sysobjects with(NOLOCK) where type = 'U'
    SELECT routine_name, routine_type FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_DEFINITION LIKE '%'+@object_name+'%'
	IF @@rowcount = 0 Print @object_name + ' has no dependencies'
	print @object_name
