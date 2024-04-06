
USE AW2022;
GO

SELECT DISTINCT TABLE_SCHEMA
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
GO 

SELECT HRSchemaTables = TABLE_SCHEMA + '.' + TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA ='HumanResources'
AND TABLE_TYPE = 'BASE TABLE'
ORDER BY HRSchemaTables
GO 

SELECT SalesSchemaTables = TABLE_SCHEMA + '.' + TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA ='Sales'
AND TABLE_TYPE = 'BASE TABLE'
ORDER BY SalesSchemaTables;
GO 

SELECT ProductionSchemaTables = TABLE_SCHEMA + '.' + TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA ='Production'
AND TABLE_TYPE = 'BASE TABLE'
ORDER BY ProductionSchemaTables;
GO 

SELECT PurchasingSchemaTables = TABLE_SCHEMA + '.' + TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA ='Purchasing'
AND TABLE_TYPE = 'BASE TABLE'
ORDER BY PurchasingSchemaTables;
GO 

SELECT dboSchemaTables = TABLE_SCHEMA + '.' + TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA ='dbo'
AND TABLE_TYPE = 'BASE TABLE'
ORDER BY dboSchemaTables;
GO

-- REFACTOR ABOVE CODES USING LOOP

/*
Task Description: 
    Retrieving Subcategories and Column Lists for AW2022 Database

Action:
1. Retrieve all subcategories present in the AW2022 database along with their column lists.
2. Save the result in JSON format.

Data:
    Database: AW2022
    Columns:
        TABLE_CATALOG: Name of the database
        TABLE_SCHEMA: Name of the schema
        TABLE_NAME: Name of the table
        TABLE_TYPE: Type of the table (BASE TABLE or VIEW)

Requirements:
1. Retrieve all subcategories present in the AW2022 database.
2. For each subcategory, gather the list of columns.
3. Display the results in a readable format.
*/

-- APPROACH 1: USING CURSOR AND LOOP
USE AW2022; -- Use DW2022 its data
GO 

-- Declare a cursor to loop through distinct Table_Schemas
DECLARE schema_cursor CURSOR FOR 
SELECT DISTINCT TABLE_SCHEMA
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_TYPE = 'BASE TABLE';

-- Declare variables to store schema name and schema tables
DECLARE @table_schema NVARCHAR(100);
DECLARE @SchemaTable NVARCHAR(MAX)


-- Create a staging table
CREATE TABLE #AW2022SchemaTable
(
    TableSchema NVARCHAR(512),
    ColumnList NVARCHAR(MAX)
)

-- Open the cursor
OPEN schema_cursor;

-- Fetch the first row from cursor
FETCH NEXT FROM schema_cursor INTO @table_schema;

-- Start the loop
WHILE @@FETCH_STATUS = 0
BEGIN

    -- Print next row
    PRINT 'Schema:   ' + @table_schema

    SELECT @SchemaTable = STRING_AGG(TABLE_SCHEMA + '.' + TABLE_NAME, ', ')
    FROM INFORMATION_SCHEMA.TABLES 
    WHERE TABLE_TYPE = 'BASE TABLE'
    AND TABLE_SCHEMA = @table_schema;

    PRINT 'Schema_Tables:  ' + @SchemaTable

    INSERT INTO #AW2022SchemaTable (TableSchema, ColumnList)
    VALUES (@table_schema, @SchemaTable)

    -- Fetch the next row from cursor
    FETCH NEXT FROM schema_cursor INTO @table_schema;

END

-- Close and deallocate the cursor
CLOSE schema_cursor ;
DEALLOCATE schema_cursor;

-- Retreive from staging table
SELECT *
FROM #AW2022SchemaTable;

-- Drop the staging table
DROP TABLE #AW2022SchemaTable;

GO

-- APPROACH 2: USING FUNCTION AND WITHOUT CURSOR OR LOOP

-- Create function to retreive list of tables in a schema in csv format
USE AW2022;
GO 

CREATE FUNCTION dbo.ufnGetTablesBySchema (@schema NVARCHAR(512))
RETURNS NVARCHAR (MAX)
AS 
BEGIN 
RETURN (
    SELECT STUFF ((SELECT DISTINCT ', ' + TABLE_NAME
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_TYPE = 'BASE TABLE'
    AND TABLE_SCHEMA = @schema
    FOR XML PATH ('')), 1, 1, '')  
)
END 
GO 

-- Retreive CVS formatted HR schema tables list
SELECT HRSchemaTables = dbo.ufnGetTablesBySchema('HumanResources')

-- Retreive CVS formatted list of tables for each schema.

SELECT DISTINCT TABLE_SCHEMA, TABLES_LIST = dbo.ufnGetTablesBySchema(TABLE_SCHEMA)
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_SCHEMA;
GO 


