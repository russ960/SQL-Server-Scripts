/********************************************************************************************************/
Use master
declare @dbname varchar(128)
declare @fromdate smalldatetime
--select @dbname = db_name()
select @fromdate = getdate()-548  
create table #sizeinfo
(
filedate datetime null,
dbname nvarchar(128) null,
Dsize numeric (20,0) null,
Lsize numeric (20,0) null,
backup_set_id int null,
backup_size numeric (20,0) null
)
insert #sizeinfo
select 
filedate=bs.backup_finish_date,
dbname=bs.database_name, 
SUM(CASE file_type WHEN 'D' THEN file_size ELSE 0 END) as Dsize,
SUM(CASE file_type WHEN 'L' THEN file_size ELSE 0 END) as Lsize,
bs.backup_set_id,
bs.backup_size
from msdb..backupset bs, msdb..backupfile bf
where bf.backup_set_id = bs.backup_set_id
--and rtrim(bs.database_name) = rtrim(@dbname)
and bs.type = 'D'
and bs.backup_finish_date >= @fromdate
group by bs.backup_finish_date, bs.backup_set_id, bs.backup_size, bs.database_name
order by bs.backup_finish_date, bs.backup_set_id, bs.backup_size, bs.database_name
 
select 
Date=filedate, 
Dbname=dbname, 
MDFSizeInMB=(Dsize/1024)/1024, 
LDFSizeInMB=(Lsize/1024)/1024, 
TotalFIleSizeInMB=((Dsize+Lsize)/1024)/1024,
BackupSizeInMB=(backup_size/1024)/1024
from #sizeinfo
order by dbname,filedate
 
drop table #sizeinfo
/********************************************************************************************************/