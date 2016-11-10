/*
getting information regarding users who has accessed MS SQL 2005 tables in past

http://social.msdn.microsoft.com/Forums/en/transactsql/thread/03b701b2-7301-456c-bbde-17246fb55d64

*/

SELECT 
   I.NTUserName,
   I.loginname,
   I.SessionLoginName,
   I.databasename,
   Min(I.StartTime) as first_used,
   Max(I.StartTime) as last_used,
   S.principal_id,
   S.sid,
   S.type_desc,
   S.name
FROM
   sys.traces T CROSS Apply
   ::fn_trace_gettable(CASE 
                          WHEN CHARINDEX( '_',T.[path]) <> 0 THEN 
                               SUBSTRING(T.PATH, 1, CHARINDEX( '_',T.[path])-1) + '.trc' 
                          ELSE T.[path] 
                       End, T.max_files) I LEFT JOIN
   sys.server_principals S ON
       CONVERT(VARBINARY(MAX), I.loginsid) = S.sid  
WHERE
    T.id = 1 And
    I.LoginSid is not null
    AND I.databasename not in ('master','tempdb','msdb')
Group By
   I.NTUserName,
   I.loginname,
   I.SessionLoginName,
   I.databasename,
   S.principal_id,
   S.sid,
   S.type_desc,
   S.name


