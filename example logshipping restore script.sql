RESTORE database ACCESSCONTROL
FROM DISK = 'E:\BACKUPS\ACCESSCONTROL_db_200601171047.BAK'
with 
move 'ACCESSCONTROL_Data' to 'd:\MSSQL\data\ACCESSCONTROL_data.mdf',
move 'ACCESSCONTROL_Log' to 'e:\MSSQL\tlog\ACCESSCONTROL_log.ldf',
norecovery,
stats = 1