select * from dbo.backupfile with (NOLOCK)

select * from dbo.backupset with (NOLOCK)


select a.database_name, b.logical_name, a.backup_finish_date, sum(b.file_size), a.backup_set_id
from dbo.backupset a with (NOLOCK), dbo.backupfile b with (NOLOCK) where a.backup_set_id = b.backup_set_id 
and a.backup_finish_date = a.backup_finish_date
and a.backup_finish_date > '2005-12-31 23:59:59.000' and file_type = 'D' 
group by a.database_name, b.logical_name, a.backup_finish_date, a.backup_set_id 
order by 1, 2, 3, 4, 5

select a.backup_finish_date, LOWER(a.database_name)as DatabaseName, sum(b.file_size) as Database_Filesize
from dbo.backupset a with (NOLOCK), dbo.backupfile b with (NOLOCK) where a.backup_set_id = b.backup_set_id 
and a.backup_finish_date = a.backup_finish_date
and a.backup_finish_date > '2005-12-31 23:59:59.000' and file_type = 'D' 
group by a.backup_finish_date, a.database_name
order by 2,1