-- Suspend all Mirrored DBs
select 'alter database ' + db_name(database_id)+ ' set partner suspend'
+ char(10) + 'go'
FROM   SYS.DATABASE_MIRRORING
WHERE  MIRRORING_GUID IS NOT NULL

-- Resume all Mirrored DBs
select 'alter database ' + db_name(database_id)+ ' set partner resume'
+ char(10) + 'go'
FROM   SYS.DATABASE_MIRRORING
WHERE  MIRRORING_GUID IS NOT NULL

-- Set Full Safety on for Mirrored DBs
select 'alter database ' + db_name(database_id)+ ' set partner safety full'
+ char(10) + 'go'
FROM   SYS.DATABASE_MIRRORING
WHERE  MIRRORING_GUID IS NOT NULL

-- Failover Mirrored DBs
select 'alter database ' + db_name(database_id)+ ' set partner failover'
+ char(10) + 'go'
FROM   SYS.DATABASE_MIRRORING
WHERE  MIRRORING_GUID IS NOT NULL

-- Set Full Safety off for Mirrored DBs
select 'alter database ' + db_name(database_id)+ ' set partner safety off'
+ char(10) + 'go'
FROM   SYS.DATABASE_MIRRORING
WHERE  MIRRORING_GUID IS NOT NULL