/**************************************************************
  OBJECTIVE 01:
  Demonstrate how to create a table using Transact-SQL statement
**************************************************************/

/*** Create a new table called 'ClientInfo' in 'AdventureWorksDW2022' ***/

-- we can use Table Designer as well.

USE AdventureWorksDW2022;
GO

CREATE TABLE ClientInfo
(
  Client_id INT NOT NULL PRIMARY KEY, -- primary key column
  Client_name [NVARCHAR](50),
  Client_city [NVARCHAR](50),
  Client_phone [NVARCHAR](20),

);
GO


/*** Create a new table called 'Client_Orders' in 'AdventureWorksDW2022' ***/

USE AdventureWorksDW2022;
GO

CREATE TABLE Client_Orders
(
  Order_id INT NOT NULL PRIMARY KEY, -- primary key column
  Order_no INT NOT NULL,
  Client_id INT,
  FOREIGN KEY (Client_id) REFERENCES AdventureWorksDW2022.dbo.ClientInfo (Client_id)

);
GO

-- run these if you are curious now.

/*** find the object id of both tables ***/
SELECT OBJECT_ID('AdventureWorksDW2022.dbo.ClientInfo') as ClientInfo_object_id,
       OBJECT_ID('AdventureWorksDW2022.dbo.Client_Orders') as Client_Orders_object_id;

/*** find the constraint name of foreign key ***/
SELECT name as constraint_name
FROM sys.foreign_keys
WHERE parent_object_id = OBJECT_ID('AdventureWorksDW2022.dbo.Client_Orders');

-- constraint_name
-- FK__Client_Or__Clien__41EDCAC5


/**************************************************************
  OBJECTIVE 02:
  Demonstrate how to create a schema using Transact-SQL statement
**************************************************************/

/*** create schema- order under database AdventureWorksDW2022 ***/

USE AdventureWorksDW2022;
GO

CREATE SCHEMA orders AUTHORIZATION dbo;
GO

USE AdventureWorksDW2022;
GO

/*** create schema client under database AdventureWorksDW2022 ***/

CREATE SCHEMA client AUTHORIZATION dbo;
GO


/**************************************************************
  OBJECTIVE 03:
  Review the table created in the first task to ensure it is normalized
**************************************************************/

/*** write a query to show the relation between them using foreign key ***/

select 
      name as constraint_name,
      OBJECT_NAME(referenced_object_id) as 'referenced_table',
      OBJECT_SCHEMA_NAME(referenced_object_id) as 'referenced_schema',
      OBJECT_NAME(parent_object_id) as 'fact_table',
      OBJECT_SCHEMA_NAME(parent_object_id) as 'fact_schema'

from sys.foreign_keys
where OBJECT_NAME(referenced_object_id) = 'ClientInfo'

/*
constraint_name	                referenced_table	referenced_schema	fact_table	  fact_schema
FK__Client_Or__Clien__41EDCAC5	ClientInfo	      dbo	              Client_Orders	dbo 

this shows that both table are related through foreign key constraints
which is crucial for normalization
*/

/*
DID THIS AFTER LEARNING \DB01_Developing_a_SQL_Databases\SQL_08_Creating_Stored_Procedures
*/

-- Create stored procedure to run above query where parameter is table_name
use AdventureWorksDW2022;
GO

CREATE PROCEDURE sp_Display_FNF
  @p_referenced_table_name NVARCHAR(50)
AS 
  SET NOCOUNT ON;
  BEGIN
  SELECT 
        name as constraint_name,
        OBJECT_SCHEMA_NAME(parent_object_id) as fact_schema,
        OBJECT_NAME(parent_object_id) as fact_table,
        OBJECT_SCHEMA_NAME(referenced_object_id) as referenced_schema,
        OBJECT_NAME(referenced_object_id) as referenced_table
  FROM sys.foreign_keys
  WHERE OBJECT_NAME(referenced_object_id) = @p_referenced_table_name
  SET NOCOUNT OFF;
  
  END
GO


DECLARE @p_referenced_table_name_1 NVARCHAR(50) = 'DimProduct'

EXEC sp_Display_FNF @p_referenced_table_name_1
go  

DECLARE @p_referenced_table_name_2 NVARCHAR(50) = 'FactInternetSales'
EXEC sp_Display_FNF @p_referenced_table_name_2
go  

/*
so just by changing one parameter - I can get different table.
User does not need to do who stored procedure fetching the table.
Data encapsulation it is.
*/
