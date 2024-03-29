/**************************************************************
  OBJECTIVE 01:
  Demonstrate how to enforce integrity with constraints when used with DMl statements.
**************************************************************/

-- Create a new table called 'DimEmployee_tbl' in schema 'dbo'
-- Drop the table if it already exists
IF OBJECT_ID('dbo.DimEmployee_tbl', 'U') IS NOT NULL
DROP TABLE dbo.DimEmployee_tbl
GO
-- Create the table in the specified schema
USE AdventureWorksDW2022;
GO

CREATE TABLE dbo.DimEmployee_tbl
(
    Employee_Id INT NOT NULL,
    -- primary key column
    FirstName [NVARCHAR](50) NOT NULL,
    LastName [NVARCHAR](50) NOT NULL,
    JobTitle [NVARCHAR](50) NOT NULL,
    CountryRegion [NVARCHAR](50) NOT NULL,
    ParentEmployeeKey INT,
    HireDate DATE,
    CONSTRAINT PK_DimEmployee_tbl_Employee_Id PRIMARY KEY CLUSTERED (Employee_Id)
);
GO

-- add foreign key constraint to table 
ALTER TABLE dbo.DimEmployee_tbl
    WITH CHECK ADD CONSTRAINT FK_DimEmployee_tbl_ParentEmployeeKey 
    FOREIGN KEY (ParentEmployeeKey) REFERENCES DimEmployee_tbl (Employee_Id)


-- Insert rows into table 'DimEmployee_tbl'
INSERT INTO DimEmployee_tbl
( -- columns to insert data into
 Employee_Id, FirstName, LastName, JobTitle, CountryRegion, ParentEmployeeKey
)
VALUES
( -- first row: values for the columns in the list above
 1, 'Manish', 'Shivale', 'CEO', 'CANADA', NULL
)
GO

/*
What will happen if we insert row with ParentEmployeeKey as 10.
-- ParentEmployeeKey = 10 means Employee_Id = 10 must exist
-- However, Employee_Id = 10 does not exist yet.
*/

-- Insert rows into table 'DimEmployee_tbl'
INSERT INTO DimEmployee_tbl
( -- columns to insert data into
 Employee_Id, FirstName, LastName, JobTitle, CountryRegion, ParentEmployeeKey
)
VALUES
( -- first row: values for the columns in the list above
 2, 'Pooja', 'Shivale', 'BA', 'CANADA', 10
)
GO

/*
RESULT: 
The INSERT statement conflicted with the FOREIGN KEY SAME TABLE constraint "FK_DimEmployee_tbl_ParentEmployeeKey". The conflict occurred in database "AdventureWorksDW2022", table "dbo.DimEmployee_tbl", column 'Employee_Id'. 
	
	The statement has been terminated.

CONCLUSION: Insertion is not violating data integrity.
*/

-- Insert rows into table 'DimEmployee_tbl' with ParentEmployeeKey from existing Employee_Id
INSERT INTO DimEmployee_tbl
( -- columns to insert data into
 Employee_Id, FirstName, LastName, JobTitle, CountryRegion, ParentEmployeeKey
)
VALUES
( -- first row: values for the columns in the list above
-- Choose ParentEmployeeKey = 1: means Pooja works under Manish
 2, 'Pooja', 'Shivale', 'BA', 'CANADA', 1
)
GO

/*
What will happen if we insert row with Employee_Id say 1 which already exist in table?
*/

-- Insert rows into table 'DimEmployee_tbl'
INSERT INTO DimEmployee_tbl
( -- columns to insert data into
 Employee_Id, FirstName, LastName, JobTitle, CountryRegion, ParentEmployeeKey
)
VALUES
( -- first row: values for the columns in the list above
 1, 'Mithilesh', 'Shivale', 'CTO', 'CANADA', NULL
)
GO

/*
RESULT:
Violation of PRIMARY KEY constraint 'PK_DimEmployee_tbl_Employee_Id'. Cannot insert duplicate key in object 'dbo.DimEmployee_tbl'. The duplicate key value is (1).

CONCLUSION: Primary Key constraint does not allow insertion of DUPLICATE row in PRIMARY KEY column.
*/

/**************************************************************
  OBJECTIVE 02:
  Demonstrate how to bulk import data in a table with check constraint on a column by specifying IGNORE CONSTRAINT
**************************************************************/


-- Create a new table called 'Bulk_import' in schema 'dbo'
-- Drop the table if it already exists
USE AdventureWorksDW2022;
GO

IF OBJECT_ID('dbo.Bulk_import', 'U') IS NOT NULL
DROP TABLE dbo.Bulk_import
GO
-- Create the table in the specified schema
CREATE TABLE dbo.Bulk_import
(
    Id INT,
    first_name [NVARCHAR](50),
    
);
GO

-- bulk insert from test.txt file where each row data is separated by new line and column data is separated by comma.

BULK INSERT dbo.Bulk_import
FROM 'C:\Users\manish.shivale\Documents\Projects\DATABASES\DB01_Developing_a_SQL_Databases\SQL_07_Effects_of_constraint\test.txt'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n'
)

-- fetch all data to verify bulk insertion
SELECT * FROM Bulk_import;

-- add check constraint on id column 
ALTER TABLE Bulk_import
    ADD CONSTRAINT CK_Id CHECK ( Id < 10)
GO

-- add 11,Kathy 9,Bob in test.txt

-- Do the bulk insertion again
BULK INSERT dbo.Bulk_import
FROM 'C:\Users\manish.shivale\Documents\Projects\DATABASES\DB01_Developing_a_SQL_Databases\SQL_07_Effects_of_constraint\test.txt'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n'
)

-- fetch all data to verify bulk insertion
SELECT * FROM Bulk_import;

/* RESULT:
Id	first_name
1	Sam
2	Fuller
3	Mike
1	Sam
2	Fuller
3	Mike
11	Kathy
9	Bob

OBSERVATION: 
a. Bulk insertion did not enforce check constraint.
*/

-- try single insertion on table
-- Insert rows into table 'dbo.Bulk_import'
INSERT INTO dbo.Bulk_import
( -- columns to insert data into
    id, first_name
)
VALUES
( -- first row: values for the columns in the list above
    12, 'Namrita'
)

GO

/*RESULT

The INSERT statement conflicted with the CHECK constraint "CK_Id". The conflict occurred in database "AdventureWorksDW2022", table "dbo.Bulk_import", column 'Id'.

OBSERVATION:
a. single insertion did not violate check constraint.

/* CONCLUSION:  CHECK constraint is ignored if data is imported using BULK INSERT.
*/