-------Copy GRANT/REVOKE User/Group Permissions--------------------------
--------------04/01/2005-----------------
-------------AJITH DHARWAR-----------
------------akdharwar@yahoo.com------
------------Systems Architect--------

--REPLACE <Your Role/User on Source Server> with say DBAUSER_OLD

--REPLACE <Your Role/User on Target Server> with say DBAUSER_NEW


SELECT
CASE protecttype WHEN  204 THEN 'GRANT_W_GRANT '
     WHEN 205 THEN 'GRANT '
     WHEN 206 THEN 'REVOKE '
ELSE 'DUMMY GRANT' END
+ CASE action WHEN 26 THEN 'REFERENCES'
	WHEN 178 THEN 'CREATE FUNCTION'
	WHEN 193 THEN 'SELECT'
	WHEN 195 THEN 'INSERT'
	WHEN 196 THEN 'DELETE'
	WHEN 197 THEN 'UPDATE'
	WHEN 198 THEN 'CREATE TABLE'
	WHEN 203 THEN 'CREATE DATABASE'
	WHEN 207 THEN 'CREATE VIEW'
	WHEN 222 THEN 'CREATE PROCEDURE'
	WHEN 224 THEN 'EXECUTE'
	WHEN 228 THEN 'BACKUP DATABASE'
	WHEN 233 THEN 'CREATE DEFAULT'
	WHEN 235 THEN 'BACKUP LOG'
	WHEN 236 THEN 'CREATE RULE'
 ELSE ' DUMMY ' END + ' ON ' 
+ so.name + ' TO <Your Role/User on Source Server>'
from sysprotects sp
inner join sysobjects so on (so.id=sp.id)
inner join sysusers s on (sp.uid=s.uid)
where s.name= '<Your Role/User on Source Server>'