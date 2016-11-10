-- Source: http://www.sanssql.com/2008/11/find-domain-name-using-t-sql.html
DECLARE @Domain varchar(100), @key varchar(100)

SET @key = 'SYSTEM\ControlSet001\Services\Tcpip\Parameters\'
EXEC master..xp_regread @rootkey='HKEY_LOCAL_MACHINE', @key=@key,@value_name='Domain',@value=@Domain OUTPUT 
SELECT 'Server Name: '+@@servername + ' Domain Name:'+convert(varchar(100),@Domain)