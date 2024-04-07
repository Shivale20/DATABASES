/**************************************************************
  OBJECTIVE 01:
  Demonstrate how creating a clustered index on a varchar column which has existing data in the IN_ROW_DATA allocation unit affects subsequent insert or update actions on the column
**************************************************************/

/*** Get data about allocation units for your tables 
ClientInfo
FactInternetSales
***/

USE AdventureWorksDW2022;
GO

select name, object_id
from sys.objects;

select hobt_id, object_id
from sys.partitions;


with
  prev_query
  as
  (
    select o.name, p.hobt_id
    from sys.objects o
      inner join sys.partitions p
      on p.object_id = o.object_id
  )
select prev_query.name,
  au.type_desc as AU_type,
  au.total_pages as total_pages,
  au.data_pages as data_pages,
  au.used_pages as used_pages
from prev_query
  inner join sys.allocation_units au
  on au.container_id = prev_query.hobt_id
where prev_query.name = 'ClientInfo' AND (au.type_desc = 'IN_ROW_DATA' OR
  au.type_desc = 'ROW_OVERFLOW_DATA');


with
  prev_query
  as
  (
    select o.name, p.hobt_id
    from sys.objects o
      inner join sys.partitions p
      on p.object_id = o.object_id
  )
select prev_query.name,
  au.type_desc as AU_type,
  au.total_pages as total_pages,
  au.data_pages as data_pages,
  au.used_pages as used_pages
from prev_query
  inner join sys.allocation_units au
  on au.container_id = prev_query.hobt_id
where prev_query.name = 'FactInternetSales' AND (au.type_desc = 'IN_ROW_DATA' OR
  au.type_desc = 'ROW_OVERFLOW_DATA');


-- Create a clone table named DimProduct_tmp with the records imported from DimProduct table.

USE AdventureWorksDW2022;
GO

SELECT *
INTO DimProduct_tmp
FROM DimProduct;

/* 

very important: The SELECT INTO statement creates a new table based on the result set of the SELECT query, but it does not inherit any constraints, including primary keys, from the source table 

*/

-- Add a new varchar column in DimProduct_tmp table.

USE AdventureWorksDW2022;
GO

ALTER TABLE DimProduct_tmp 
ADD new_row VARCHAR(500);

-- Create a clustered index named IX_TestTable on the newly added column in DimProduct_tmp table.
USE AdventureWorksDW2022;
GO

CREATE CLUSTERED INDEX IX_TestTable
ON DimProduct_tmp(new_row);

GO

-- update the new_row with random values for row in the DimProduct_tmp table.

UPDATE DimProduct_tmp
SET new_row = CAST(NEWID() AS VARCHAR(500))
WHERE new_row IS NULL;

-- Get data about allocation units for the table.
with
  prev_query
  as
  (
    select o.name, p.hobt_id
    from sys.objects o
      inner join sys.partitions p
      on p.object_id = o.object_id
  )
select prev_query.name,
  au.type_desc as AU_type,
  au.total_pages as total_pages,
  au.data_pages as data_pages,
  au.used_pages as used_pages
from prev_query
  inner join sys.allocation_units au
  on au.container_id = prev_query.hobt_id
where prev_query.name = 'DimProduct_tmp';


-- Drop the clustered index.

DROP INDEX IX_TestTable
ON DimProduct_tmp 
WITH (ONLINE = OFF)
GO


/**************************************************************
  OBJECTIVE 02:
  Demonstrate how creating clustered indexes on a table followed by several nonclustered indexes is the best practice rather than creating several nonclustered indexes on a table followed by a clustered indexes

**************************************************************/


-- Create multiple nonclustered indexes.

CREATE NONCLUSTERED INDEX IDX_Product_Color
ON DimProduct_tmp (Color)
GO

CREATE NONCLUSTERED INDEX IDX_Product_List
ON DimProduct_tmp (ListPrice)
GO

CREATE NONCLUSTERED INDEX IDX_Product_Size
ON DimProduct_tmp (Size)
GO

-- Create a clustered index named IX_TestTable on the newly added column in DimProduct_tmp table.

CREATE UNIQUE CLUSTERED INDEX IX_TestTable
ON DimProduct_tmp (new_row)
GO

-- Rebuild the nonclustered indexes.

use AdventureWorksDW2022;
GO

ALTER INDEX ALL ON DimProduct_tmp
REBUILD WITH (
  FILLFACTOR = 80,
  SORT_IN_TEMPDB = ON,
  STATISTICS_NORECOMPUTE = ON
);

GO