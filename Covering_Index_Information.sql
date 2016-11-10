/*
MSSQL Tips Querying SQL Server Index Statistics:
http://www.mssqltips.com/sqlservertip/2979/querying-sql-server-index-statistics/?utm_source=dailynewsletter&utm_medium=email&utm_content=headline&utm_campaign=20130621
*/
DECLARE @schemaid varchar(50) 
DECLARE @tablename varchar(50) 
DECLARE @indexname varchar(50) 
-- Update with the schmea, table name and index name below. 
SET @schemaid = 'Production'
SET @tablename = 'ProductReview'
SET @indexname = 'IX_ProductReview_ProductID_Name'

SELECT
    SCHEMA_NAME([sObj].[schema_id]) AS [SchemaName]
    , [sObj].[name] AS [ObjectName]
    , CASE
        WHEN [sObj].[type] = 'U' THEN 'Table'
        WHEN [sObj].[type] = 'V' THEN 'View'
        END AS [ObjectType]
    , [sIdx].[index_id] AS [IndexID]  -- 0: Heap; 1: Clustered Idx; > 1: Nonclustered Idx;
    , ISNULL([sIdx].[name], 'N/A') AS [IndexName]
    , CASE
        WHEN [sIdx].[type] = 0 THEN 'Heap'
        WHEN [sIdx].[type] = 1 THEN 'Clustered'
        WHEN [sIdx].[type] = 2 THEN 'Nonclustered'
        WHEN [sIdx].[type] = 3 THEN 'XML'
        WHEN [sIdx].[type] = 4 THEN 'Spatial'
        WHEN [sIdx].[type] = 5 THEN 'Reserved for future use'
        WHEN [sIdx].[type] = 6 THEN 'Nonclustered columnstore index'
    END AS [IndexType]
    , [sCol].[name] AS [ColumnName]
   , CASE 
  WHEN [sIdxCol].[is_included_column] = 0x1 THEN 'Yes'
  WHEN [sIdxCol].[is_included_column] = 0x0 THEN 'No'
  WHEN [sIdxCol].[is_included_column] IS NULL THEN 'N/A'
  END AS [IsIncludedColumn]
    , [sIdxCol].[key_ordinal] AS [KeyOrdinal]
FROM 
    [sys].[indexes] AS [sIdx]
    INNER JOIN [sys].[objects] AS [sObj]
        ON [sIdx].[object_id] = [sObj].[object_id]
    LEFT JOIN [sys].[index_columns] AS [sIdxCol]
        ON [sIdx].[object_id] = [sIdxCol].[object_id]
        AND [sIdx].[index_id] = [sIdxCol].[index_id]
    LEFT JOIN [sys].[columns] AS [sCol]
        ON [sIdxCol].[object_id] = [sCol].[object_id]
        AND [sIdxCol].[column_id] = [sCol].[column_id]
WHERE
    SCHEMA_NAME([sObj].[schema_id]) = @schemaid
 AND [sObj].[name] = @tablename
    AND [sIdx].[name] = @indexname