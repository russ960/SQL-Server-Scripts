SELECT [schema] = OBJECT_SCHEMA_NAME([object_id]), name
    FROM sys.objects
    WHERE OBJECT_DEFINITION([object_id]) LIKE '%<text>%'
    AND [type] IN ('P', 'IF', 'FN', 'TF');