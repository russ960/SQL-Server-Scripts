------------------------------------------------------------------------------
-- Table Creation:
------------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'SchemaName' AND TABLE_NAME = 'TableName')
BEGIN
--Insert Code to create table.
END
GO

------------------------------------------------------------------------------
-- Add Column to Table:
------------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'SchemaName' AND TABLE_NAME = 'TableName' AND COLUMN_NAME = 'ColumnName')
BEGIN
--Insert Code to add column to table.
END
GO

------------------------------------------------------------------------------
-- Create Default Constraint on Table:
------------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[SchemaName].[ConstraintName]') AND type = 'D')
BEGIN
-- Insert Default Constraint Create Statement
END
GO

------------------------------------------------------------------------------
-- Create Check Constraint on Table:
------------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[SchemaName].[ConstraintName]') AND type = 'C')
BEGIN
-- Insert Default Constraint Create Statement
END
GO

------------------------------------------------------------------------------
-- Create Foreign Key Constraint on Table:
------------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[SchemaName].[ForeignKeyName]') AND parent_object_id = OBJECT_ID(N'[SchemaName].[TableName]'))
BEGIN
-- Insert Foreign Key Create Statement
END
GO

------------------------------------------------------------------------------
-- Create Unique Constraint on Table:
------------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SchemaName].[TableName]') AND name = N'UniqueConstraintName')
BEGIN
-- Insert Unique Constraint Create Statement
END
GO

------------------------------------------------------------------------------
-- Drop Column from Table:
------------------------------------------------------------------------------
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'SchemaName' AND TABLE_NAME = 'TableName' AND COLUMN_NAME = 'ColumnName')
BEGIN
--Insert Code to drop column from table.
END
GO

------------------------------------------------------------------------------
-- Drop Default Constraint from Table:
------------------------------------------------------------------------------
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[ConstraintName]') AND type = 'D')
BEGIN
-- Insert Default Constraint Drop Statement
END
GO

------------------------------------------------------------------------------
-- Drop Check Constraint from Table:
------------------------------------------------------------------------------
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[ConstraintName]') AND type = 'C')
BEGIN
-- Insert Default Constraint Drop Statement
END
GO

------------------------------------------------------------------------------
-- Drop Foreign Key Constraint on Table:
------------------------------------------------------------------------------
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[SchemaName].[ForeignKeyName]') AND parent_object_id = OBJECT_ID(N'[SchemaName].[TableName]'))
BEGIN
-- Insert Foreign Key Drop Statement
END
GO

------------------------------------------------------------------------------
-- Drop Unique Constraint on Table:
------------------------------------------------------------------------------
IF EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SchemaName].[TableName]') AND name = N'UniqueConstraintName')
BEGIN
-- Insert Unique Constraint Drop Statement
END
GO

------------------------------------------------------------------------------
-- View Creation:
------------------------------------------------------------------------------
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_SCHEMA = 'SchemaName' AND TABLE_NAME = 'ViewName')
BEGIN
DROP VIEW SchemaName.ViewName
END
GO
-- Insert View Creation Definition Code.

------------------------------------------------------------------------------
-- Stored Procedure Creation:
------------------------------------------------------------------------------
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE SPECIFIC_SCHEMA = 'SchemaName' AND SPECIFIC_NAME = 'StoredProcedureName')
BEGIN
DROP PROCEDURE SchemaName.StoredProcedureName
END
GO
-- Insert Stored Procedure Creation Definition Code.

------------------------------------------------------------------------------
-- Function Creation:
------------------------------------------------------------------------------
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE SPECIFIC_SCHEMA = 'SchemaName' AND SPECIFIC_NAME = 'FunctionName')
BEGIN
DROP FUNCTION SchemaName.FunctionName
END
GO
-- Insert Stored Procedure Creation Definition Code.

------------------------------------------------------------------------------
-- Extended Properties Creation:
------------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 from sys.extended_properties where major_id = OBJECT_ID('StoredProcedureName'))
BEGIN
EXEC sys.sp_addextendedproperty
END
GO
