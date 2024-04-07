-- Create function to get column list is csv format by table name.
USE AW2022;
GO 

CREATE FUNCTION HumanResources.ufnGetTableColumns(@table_name NVARCHAR(MAX))
RETURNS NVARCHAR(MAX)
AS
BEGIN
RETURN (SELECT ColumnNames = STUFF(
        (SELECT ', ' + COLUMN_NAME
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_NAME = @table_name
        FOR XML PATH('')),
        1,1,''
    ))
END 
GO

-- Retreive column names list for table = shift from HR schema
SELECT ShiftColumns = HumanResources.ufnGetTableColumns('Shift')


-- Retreive column names list for all tables in HR schema


-- APPROACH 1: USING CURSOR 
USE AW2022;
GO

-- Creating a staging table
CREATE TABLE #HRColumns
(
    TABLE_NAME NVARCHAR(MAX),
    COLUMN_NAMES NVARCHAR(MAX)
);

-- Declare a cursor to loop through table names from HR schema
DECLARE table_cursor CURSOR FOR 
SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'HumanResources'
AND TABLE_TYPE = 'BASE TABLE'


-- Open the cursor
OPEN table_cursor;

-- Declare a variable to store table name
DECLARE @table_name NVARCHAR(MAX);

-- Fetch first row stored table_cursor
FETCH NEXT FROM table_cursor INTO @table_name

-- Loop through table name
WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT @table_name;
    
    -- Insert values in staging table
    INSERT INTO #HRColumns (TABLE_NAME, COLUMN_NAMES)
    VALUES (@table_name, HumanResources.ufnGetTableColumns(@table_name))

    FETCH NEXT FROM table_cursor INTO @table_name
END
-- Close and deallocate cursor
CLOSE table_cursor;
DEALLOCATE table_cursor;

-- Retreive the results of staging table
SELECT *
FROM #HRColumns;

-- Drop the staging table
DROP TABLE #HRColumns;
GO 


-- APPROACH 2: WITHOUT USING CURSOR
USE AW2022;
GO

SELECT TABLE_NAME, COLUMN_NAMES = HumanResources.ufnGetTableColumns(TABLE_NAME)
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'HumanResources'
AND TABLE_TYPE = 'BASE TABLE'

GO 

/*
Recommendation:

1. Approach 2 (without using a cursor) is generally preferable due to its simplicity and potentially better performance. It directly retrieves the required information without the need for cursor operations, which can be less efficient.

2. Consider using Approach 2 unless there are specific requirements that necessitate the use of a cursor.
*/

USE AW2022;
GO 
SELECT *
FROM HumanResources.Shift