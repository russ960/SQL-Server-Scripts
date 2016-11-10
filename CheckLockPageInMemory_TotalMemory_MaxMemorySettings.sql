-- Author: Dave Otto

set nocount on;

CREATE TABLE #xp_cmdshell_output (Output VARCHAR (8000));
-- run whoami command via xp_cmdshell
INSERT INTO #xp_cmdshell_output EXEC ('xp_cmdshell ''whoami /priv''');

DECLARE @locker varchar(MAX),
		@totalmem varchar(MAX),
		@allocmem int

IF EXISTS (SELECT * FROM #xp_cmdshell_output WHERE Output LIKE '%SeLockMemoryPrivilege%enabled%')
	SELECT @locker = 'LOCKED'
ELSE
	SELECT @locker = 'UNLOCKED'

SELECT @totalmem = physical_memory_in_bytes/(1024*1024) FROM sys.dm_os_sys_info

SELECT @allocmem = cntr_value / 1024
  FROM sys.dm_os_performance_counters
  WHERE counter_name = 'Target Server Memory (KB)'


DROP TABLE #xp_cmdshell_output;

select @locker 'MemLocked', @totalmem 'TotalMem', @allocmem 'AllocatedMem'
