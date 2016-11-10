-- Returns database name, logical filename, physcial filename, size in mb
select b.name "Database Name", a.name "Logical Name", a.physical_name "Physical Name", 
a.size*8/1024 "Size in MB" from sys.master_files a join sys.databases b on 
a.database_id=b.database_id