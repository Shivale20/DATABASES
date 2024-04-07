/**************************************************************
  OBJECTIVE 01:
  Demonstrate how to define a column as primary key for an existing table
**************************************************************/

-- create a sample table with the same structure as DimProduct without copying any actual data
-- make sure delete existing table 

USE AdventureWorksDW2022;
GO

IF EXISTS ( SELECT 1
FROM sys.tables
WHERE NAME = 'DimProduct_temp')

BEGIN
  DROP TABLE DimProduct_temp
END

SELECT *
INTO DimProduct_temp
FROM dbo.DimProduct
WHERE 1 <> 1
GO

-- check if there is any constraint in the table
USE AdventureWorksDW2022;
GO

SELECT name as constraint_name, type_desc
FROM sys.objects
WHERE parent_object_id = (
SELECT object_id
FROM sys.objects
where name LIKE 'DimProduct_temp'
);

-- result show that there is no constraint as if now.

-- define a primary key constraint on column: ProductKey as it is unique and not null
USE AdventureWorksDW2022;
GO

ALTER TABLE DimProduct_temp
  ADD CONSTRAINT PK_ProductKey PRIMARY KEY(ProductKey)
GO

-- check if there is any constraint in the table
USE AdventureWorksDW2022;
GO

SELECT name as constraint_name, type_desc
FROM sys.objects
WHERE parent_object_id = (
SELECT object_id
FROM sys.objects
where name LIKE 'DimProduct_temp'
);

/**
constraint_name	type_desc
PK_ProductKey	PRIMARY_KEY_CONSTRAINT
**/

/**************************************************************
  OBJECTIVE 02:
  Demonstrate how to define a foreign key constraint referring to another column in same table
**************************************************************/

-- create a sample table using the same structure as DimEmployee
-- create primary key on EmployeeKey column
-- create foreign key constraint on ParentEmployeeKey column

USE AdventureWorksDW2022;
GO

IF EXISTS (SELECT 1
FROM sys.tables
WHERE name = 'DimEmployee_temp' )
BEGIN
  DROP TABLE DimEmployee_temp
END
SELECT *
INTO DimEmployee_temp
FROM DimEmployee
WHERE 1 <> 1
GO

ALTER TABLE DimEmployee_temp
  ADD CONSTRAINT PK_EmployeeKey PRIMARY KEY (EmployeeKey)
GO

ALTER TABLE DimEmployee_temp
  ADD CONSTRAINT FK_ParentEmployeeKey FOREIGN KEY (ParentEmployeeKey) REFERENCES DimEmployee_temp (EmployeeKey)
GO

SELECT name as constraint_name, type_desc
FROM sys.objects
WHERE parent_object_id = (
SELECT object_id
FROM sys.objects
where name LIKE 'DimEmployee_temp'
);

/**************************************************************
  OBJECTIVE 03:
  Demonstrate how to define a foreign key constraint referring to table in the same database
**************************************************************/

-- create a sample table DimProduct_temp as same structure as DimProduct table
-- verfiy if sample table exists, delete it
-- create a primary key on ProductKey column on DimProduct_temp
-- create a sample table FactInternetSales_temp as same structure as FactInternetSales table
-- create a foreign key on Productkey column in FactInternetSales_temp table

USE AdventureWorksDW2022;
GO

IF EXISTS (SELECT 1
FROM sys.tables
WHERE name = 'DimProduct_temp')
BEGIN
  DROP TABLE DimProduct_temp
END

SELECT *
INTO DimProduct_temp
FROM DimProduct
WHERE 1<>1
GO

-- checked and new sample table has been created

ALTER TABLE DimProduct_temp
  ADD CONSTRAINT pK_ProductKey PRIMARY KEY (ProductKey)
GO

-- checked and now it has Productkey as primary key

USE AdventureWorksDW2022;
GO

IF EXISTS (SELECT 1
FROM sys.tables
WHERE name = 'FactInternetSales_temp')
BEGIN
  DROP TABLE FactInternetSales_temp
END

SELECT *
INTO FactInternetSales_temp
FROM FactInternetSales
WHERE 1<>1
GO

ALTER TABLE FactInternetSales_temp
  ADD CONSTRAINT FK_DimProduct_FactInternetSales FOREIGN KEY (ProductKey) REFERENCES DimProduct_temp (ProductKey)
GO

SELECT name as constraint_name, type_desc
FROM sys.objects
WHERE parent_object_id = (
SELECT object_id
FROM sys.objects
where name LIKE 'FactInternetSales_temp'
);


/**************************************************************
  OBJECTIVE 04:
  Demonstrate how to create a check constraint on one of the columns in an existing table.
**************************************************************/

-- create a check constraint on HireDate column in the DimEmployee_temp table

SELECT name as constraint_name, type_desc
FROM sys.objects
WHERE parent_object_id = (
SELECT object_id
FROM sys.objects
where name LIKE 'DimEmployee_temp'
);

-- currently they have only PK and FK.
USE AdventureWorksDW2022;
GO

ALTER TABLE DimEmployee_temp
  ADD CONSTRAINT 
                CHK_HireDate
                CHECK (HireDate < GETDATE())
GO  

SELECT name as constraint_name, type_desc
FROM sys.objects
WHERE parent_object_id = (
SELECT object_id
FROM sys.objects
where name LIKE 'DimEmployee_temp'
);


-- test check constraint CHK_HireDate
-- insert data from DimEmployee table

INSERT INTO DimEmployee_temp
SELECT NULL AS ParentEmployeeKey,
 EmployeeNationalIDAlternateKey,
 ParentEmployeeNationalIDAlternateKey,
 SalesTerritoryKey,
 FirstName,
 LastName,
 MiddleName,
 NameStyle,
 Title,
 HireDate,
 BirthDate,
 LoginID,
 EmailAddress,
 Phone,
 MaritalStatus,
 EmergencyContactName,
 EmergencyContactPhone,
 SalariedFlag,
 Gender,
 PayFrequency,
 BaseRate,
 VacationHours,
 SickLeaveHours,
 CurrentFlag,
 SalesPersonFlag,
 DepartmentName,
 StartDate,
 EndDate,
 Status,
 EmployeePhoto
FROM DimEmployee
WHERE EmployeeKey = 290
GO

-- NULL AS ParentEmployeeKey,creates a column named ParentEmployeeKey in the result set where each value is NULL.

-- update HireDate against condition
UPDATE DimEmployee_temp
SET HireDate = GETDATE() + 1
GO


/* Returns error:
Msg 547, Level 16, State 0, Line 2
The UPDATE statement conflicted with the CHECK constraint "CHK_HireDate". The conflict occurred in database "AdventureWorksDW2022", table "dbo.DimEmployee_temp", column 'HireDate'.
The statement has been terminated.

Completion time: 2024-03-23T11:52:32.3805903-04:00



*/

/**************************************************************
  OBJECTIVE 05:
  Demonstrate how to create a unique constraint on one of the columns in an existing table.
**************************************************************/

-- create a unique constraint on ProductAlternateKey column in DimProduct_temp table
USE AdventureWorksDW2022;
GO

ALTER TABLE DimProduct_temp
  ADD CONSTRAINT UX_ProductAlternateKey UNIQUE (ProductAlternateKey)
GO

SELECT name as constraint_name, type_desc
FROM sys.objects
WHERE parent_object_id = (
SELECT object_id
FROM sys.objects
where name LIKE 'DimProduct_temp'
);

/*
constraint_name	type_desc
pK_ProductKey	PRIMARY_KEY_CONSTRAINT
UX_ProductAlternateKey	UNIQUE_CONSTRAINT
*/