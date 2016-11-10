;WITH userWithoutLogin (
	is_user_without_login
	,NAME
	,type
	,type_desc
	)
AS (
	SELECT CASE 
			WHEN DATALENGTH(sid) = 28
				AND type = 'S' -- only want SQL users
				AND principal_id > 4 -- ignore built in users
				THEN 1
			ELSE 0
			END AS is_user_without_login
		,NAME
		,type
		,type_desc
	FROM sys.database_principals
	WHERE type = 'S'
	)
SELECT *
FROM userWithoutLogin
WHERE is_user_without_login = 1
