SELECT OBJECT_NAME(i.OBJECT_ID) AS 'tableName'
    , i.name AS 'indexName'
    , i.type_desc
    , MAX(p.partition_number) AS 'partitions'
    , SUM(p.ROWS) AS 'rows'
    , SUM(au.data_pages) AS 'dataPages'
    , SUM(p.ROWS) / SUM(au.data_pages) AS 'rowsPerPage'
FROM sys.indexes AS i
Join sys.partitions AS p
    ON i.OBJECT_ID = p.OBJECT_ID
    And i.index_id = p.index_id
Join sys.allocation_units AS au
    ON p.hobt_id = au.container_id
WHERE OBJECT_NAME(i.OBJECT_ID) Not Like 'sys%'
GROUP BY OBJECT_NAME(i.OBJECT_ID)
    , i.name
    , i.type_desc
HAVING SUM(au.data_pages) > 100
ORDER BY rowsPerPage;