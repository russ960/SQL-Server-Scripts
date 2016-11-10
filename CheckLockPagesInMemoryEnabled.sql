--Source: http://www.sqlservercentral.com/Forums/Topic518661-146-1.aspx
--Author: Arshpreet
CREATE TABLE #xp_cmdshell_output (Output VARCHAR (8000));
-- run whoami command via xp_cmdshell
INSERT INTO #xp_cmdshell_output EXEC ('xp_cmdshell ''whoami /priv''');

IF EXISTS (SELECT * FROM #xp_cmdshell_output WHERE Output LIKE '%SeLockMemoryPrivilege%enabled%')
PRINT 'Lock Page in memory enabled'
ELSE
PRINT 'Lock Page in memory disabled';

DROP TABLE #xp_cmdshell_output;