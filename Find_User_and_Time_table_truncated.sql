SET NOCOUNT ON;
DECLARE @ObjectName SYSNAME
DECLARE @TransactionID NVARCHAR(500)

SET @ObjectName = 'dbo.Example'
-- Your schema qualified table name here

--============== Retrieving the last TransactionID for the table
SET @TransactionID = ( SELECT TOP 1 [Transaction ID]
                          FROM fn_dblog(NULL, NULL)
                          WHERE AllocUnitName = @ObjectName
                          ORDER BY [Transaction ID] DESC
                       )

PRINT 'Transaction Id : ' + @TransactionID
--============== Retrieving the UserName & Time when the table was truncated, based on the TransactionID

SELECT @ObjectName AS ObjectName
      ,   [Transaction Name]
      ,   SUSER_SNAME([Transaction SID]) AS UserName
      ,   [Begin Time]
      ,   Operation
      ,   [Transaction ID]
      FROM fn_dblog(NULL, NULL)
      WHERE [Transaction ID] = @TransactionID -- Transaction ID
          AND [Transaction Name] LIKE 'TRUNCATE%'
          AND Operation = 'LOP_BEGIN_XACT'