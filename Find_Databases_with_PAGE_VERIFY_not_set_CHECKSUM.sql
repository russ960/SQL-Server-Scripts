-- Find Databases with PAGE_VERIFY not set to CHECKSUM.
-- Source: http://sqlstudies.com/2015/01/13/tsql-tuesday-62-invitation-to-healthy-sql-why-page-verify/

SELECT name, page_verify_option_desc 
FROM sys.databases
WHERE page_verify_option_desc != 'CHECKSUM'