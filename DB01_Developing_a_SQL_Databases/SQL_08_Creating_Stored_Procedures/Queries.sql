/**************************************************************
  OBJECTIVE 01:
  Demonstrate how to create Stored Procedures.
**************************************************************/

-- NAMING CONVENTIONS
-- sp_procedureName
-- @p_variableName

-- create a stored procedure that fetch all procedures stored in current database

-- without procedure this is how we do it.
USE AdventureWorksDW2022;
GO
SELECT *
FROM sys.procedures;






-- create procedure to get all procedures;

USE AdventureWorksDW2022;
GO

CREATE PROCEDURE sp_GetProcedures
AS
BEGIN
    SET NOCOUNT ON;
    SELECT name as 'sp_name', object_id, schema_id
    FROM sys.procedures
END
GO

-- execute the procedure
EXECUTE sp_GetProcedures;








-- create procedure to filter records based on given parameter

USE AdventureWorksDW2022;
GO

CREATE PROCEDURE sp_Filter_DepartmentGroupKey
    @given_DepartmentGroupKey INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT *
    FROM DimDepartmentGroup
    WHERE DepartmentGroupKey = @given_DepartmentGroupKey
END
GO

-- check list of procedures again
EXECUTE sp_GetProcedures;

-- execute procedure to filter for DepartmentGroupKey = 7
EXECUTE sp_Filter_DepartmentGroupKey 7;

-- create procedure to filter record using wildcard paramaters

USE AdventureWorksDW2022;
GO

CREATE PROCEDURE sp_Filter_FirstName_begin_with_X
    @FirstName NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT FirstName, Gender, MaritalStatus
    FROM DimEmployee
    WHERE FirstName LIKE @FirstName
END
GO

-- check list of procedures again
EXECUTE sp_GetProcedures;

-- execute procedure to filter fistname beginning with A
EXECUTE sp_Filter_FirstName_begin_with_X 'A%';







-- create a stored procedure with output parameters

-- without stored procedures without variables

USE AdventureWorksDW2022;
GO

SELECT Count(*) as production_employee_count
FROM DimEmployee
WHERE DepartmentName = 'Production'
go

-- with stored procedures with variables
USE AdventureWorksDW2022;
GO

CREATE PROCEDURE sp_Count_Employee_Filter_DepartmentName
    @p_DepartmentName NVARCHAR(30),
    @p_EmployeeCount INT OUT
AS
BEGIN
    SELECT @p_EmployeeCount = Count(*)
    FROM DimEmployee
    WHERE DepartmentName = @p_DepartmentName
END
GO

-- check list of procedures again
EXECUTE sp_GetProcedures;

/*execute the stored procedure by passing the department name as ‘Production’. The total count of employees working in the ‘Production’ department from DimEmployee table is calculated and displayed on procedure execution.
*/

DECLARE 
    @p_Input_DepartmentName_1 NVARCHAR(30) = 'Production', 
    @p_Input_DepartmentName_2 NVARCHAR(30) = 'Marketing',
    @p_Output_p_EmployeeCount_1 INT,
    @p_Output_p_EmployeeCount_2 INT;

EXECUTE sp_Count_Employee_Filter_DepartmentName @p_Input_DepartmentName_1, @p_Output_p_EmployeeCount_1 OUTPUT

EXECUTE sp_Count_Employee_Filter_DepartmentName @p_Input_DepartmentName_2, @p_Output_p_EmployeeCount_2 OUTPUT

SELECT @p_Output_p_EmployeeCount_1 AS 'Production', @p_Output_p_EmployeeCount_2 AS 'Marketing'

GO
-- refactor above code

DECLARE
    @p_ProductionEmployeeCount INT, 
    @p_MarketingEmployeeCount INT;

EXEC dbo.sp_Count_Employee_Filter_DepartmentName 'Production', @p_ProductionEmployeeCount OUTPUT;
EXEC dbo.sp_Count_Employee_Filter_DepartmentName 'Marketing', @p_MarketingEmployeeCount OUTPUT;

-- Display the results
SELECT 'Production' AS Department, @p_ProductionEmployeeCount AS EmployeeCount
UNION ALL
SELECT 'Marketing' AS Department, @p_MarketingEmployeeCount AS EmployeeCount

-- Refactor this sp: sp_Filter_FirstName_begin_with_X
USE AdventureWorksDW2022;
GO

CREATE PROCEDURE sp_Filter_LastName_Begin_With_Letter
    @p_letter NVARCHAR(1)
AS
    SET NOCOUNT ON;
    BEGIN
        SELECT *
        FROM dbo.DimEmployee
        WHERE LastName LIKE @p_letter + '%';
    SET NOCOUNT OFF;
    END


EXEC sp_Filter_LastName_Begin_With_Letter 'A';
GO






/***************************************************************
TABLE VALUED APPROACH AND INSERTION OF MULTIPLE ROWS
***************************************************************/

/*
create a table-type named DeptGroup that consists of two fields.
create a sp named sp_DeptGroup where the
*/
USE AdventureWorksDW2022;
GO

CREATE TYPE DeptGroup AS TABLE (
    ParentDepartmentGroupKey INT, 
    DepartmentGroupName NVARCHAR(100)
)
GO
CREATE PROCEDURE sp_DeptGroup @p_InsertDepartment DeptGroup READONLY
AS 
    BEGIN
    SET NOCOUNT ON;
    INSERT INTO DimDepartmentGroup (ParentDepartmentGroupKey, DepartmentGroupName)
    SELECT * FROM @p_InsertDepartment
    END
GO


-- Insert the values as a single row in DimDepartmentGroup table

USE AdventureWorksDW2022;
GO

DECLARE @p_InsertDepartment dbo.DeptGroup;

INSERT INTO @p_InsertDepartment (ParentDepartmentGroupKey, DepartmentGroupName)
VALUES (1, 'd1'), (1, 'd2'), (1, 'd3'), (1, 'd4'), (1, 'd5'), (1, 'd6')

DECLARE @RC INT
EXECUTE @RC = dbo.sp_DeptGroup @p_InsertDepartment
GO






/***************************************************************
TEMPORARY TABLE APPROACH AND BULK DATA IMPORT FROM CSV FILE
***************************************************************/

/*
create a sp for data import from test.csv file.
however we will be using temporary table to hold csv data.
we will bulk insert csv data into temporary table
and 
then insert data from temporary table into DimDepartmentGroup.

*/


USE AdventureWorksDW2022;
GO

CREATE PROCEDURE sp_ImportDepartmentFromCSV
    @CSVFilePath NVARCHAR(500)
AS
    BEGIN
    SET NOCOUNT ON;

    -- Create a temporary table to hold CSV data
    CREATE TABLE #TempDepartments(
        ParentDepartmentGroupKey INT, 
        DepartmentGroupName NVARCHAR(100)
    );

    -- Dynamic SQL to execute BULK INSERT
    DECLARE @SQL NVARCHAR(MAX);
    SET @SQL = 'BULK INSERT #TempDepartments FROM ''' + @CSVFilePath + ''' WITH (FIELDTERMINATOR = '','', ROWTERMINATOR = ''\n'', FIRSTROW = 2); ';
    EXEC sp_executesql @SQL;

    -- Insert data from temporary table into DimDepartmentGroup
    INSERT INTO DimDepartmentGroup (ParentDepartmentGroupKey, DepartmentGroupName)
    SELECT ParentDepartmentGroupKey, DepartmentGroupName
    FROM #TempDepartments;

    -- Drop the temporary table
    DROP TABLE #TempDepartments;

    END
GO

DECLARE @p_CSVFilePath NVARCHAR(500) = 'C:\Users\manish.shivale\Documents\Projects\DATABASES\DB01_Developing_a_SQL_Databases\SQL_08_Creating_Stored_Procedures\test.csv';
EXEC sp_ImportDepartmentFromCSV @p_CSVFilePath



/*
Update stored procedure sp_ImportDepartmentFromCSV with return code
Insert data from test2.csv
Display print based on return code matches or not.
*/


USE AdventureWorksDW2022;
GO

ALTER PROCEDURE sp_ImportDepartmentFromCSV
    @CSVFilePath NVARCHAR(500)
AS
    BEGIN
    SET NOCOUNT ON;

    -- Create a temporary table to hold CSV data
    CREATE TABLE #TempDepartments(
        ParentDepartmentGroupKey INT, 
        DepartmentGroupName NVARCHAR(100)
    );

    -- Dynamic SQL to execute BULK INSERT
    DECLARE @SQL NVARCHAR(MAX);
    SET @SQL = 'BULK INSERT #TempDepartments FROM ''' + @CSVFilePath + ''' WITH (FIELDTERMINATOR = '','', ROWTERMINATOR = ''\n'', FIRSTROW = 2); ';
    EXEC sp_executesql @SQL;

    -- Insert data from temporary table into DimDepartmentGroup
    INSERT INTO DimDepartmentGroup (ParentDepartmentGroupKey, DepartmentGroupName)
    SELECT ParentDepartmentGroupKey, DepartmentGroupName
    FROM #TempDepartments;

    -- Drop the temporary table
    DROP TABLE #TempDepartments;

    RETURN 2

    END
GO


DECLARE @p_CSVFilePath NVARCHAR(500) = 'C:\Users\manish.shivale\Documents\Projects\DATABASES\DB01_Developing_a_SQL_Databases\SQL_08_Creating_Stored_Procedures\test2.csv';
DECLARE @return_value INT
EXEC @return_value = sp_ImportDepartmentFromCSV @p_CSVFilePath

SELECT @return_value
IF @return_value = 2
    BEGIN
    PRINT 'sp_ImportDepartmentFromCSV Executed Successfully.'
    END
ELSE    
    BEGIN
    PRINT 'sp_ImportDepartmentFromCSV NOT EXECUTED!.'
    END