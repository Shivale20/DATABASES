/**************************************************************
  OBJECTIVE 01:
  Demonstrate how to create indexes based on the given tables, queries
**************************************************************/

/*** create a nonclustered index on FactInternetSales table of AdventureWorksDW2022 ***/
USE AdventureWorksDW2022;
GO

create NONCLUSTERED INDEX FactInternetSales_NC_ProductKey
ON FactInternetSales (ProductKey);
GO



/**************************************************************
  OBJECTIVE 02:
  Demonstrate how to create a non-clustered index with key columns

**************************************************************/

/*** create a non-clustered index with OrderDateKey and DueDateKey as the key columns from the FactInternetSales table.  ***/

USE AdventureWorksDW2022;
GO

create NONCLUSTERED INDEX FactInternetSales_NC_OrderDatekey_DueDatekey
ON FactInternetSales (OrderDateKey, DueDateKey)
GO


/**************************************************************
  OBJECTIVE 03:
  Demonstrate how to create a non-clustered index with included non-key columns

**************************************************************/

/*** create an index with the key column as FirstName and include the non-key columns HireDate, BirthDate, and Gender. ***/

USE AdventureWorksDW2022;
GO

create NONCLUSTERED INDEX DimEmployee_NCNK01
ON DimEmployee (FirstName)
INCLUDE (HireDate, BirthDate, Gender);
GO





