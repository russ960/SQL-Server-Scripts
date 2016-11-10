DECLARE @sn NVARCHAR(128);

EXEC master.dbo.xp_regread
    'HKEY_LOCAL_MACHINE',
    'SYSTEM\CurrentControlSet\services\SQLSERVERAGENT',
    'ObjectName', 
    @sn OUTPUT;

SELECT @sn;

EXEC master.dbo.xp_regread
    'HKEY_LOCAL_MACHINE',
    'SYSTEM\CurrentControlSet\services\MSSQLSERVER',
    'ObjectName', 
    @sn OUTPUT;
	
SELECT @sn;