/**************************************************************
  OBJECTIVE 01:
  Demonstrate how to create a clustered columnstore index 
  for a large dimension table
**************************************************************/

/*** create a dimension table for Sales between 2011 and 2013  in DW2022 ***/

use AdventureWorksDW2022;
GO

create table dbo.dimSales_2011
(
  OrderDate datetime not null,
  check (OrderDate between '20110101' and '20131231'),
  SalesAmount money not null,
  TaxAmt money not null,
  Freight money not null
)

/*** import data from FactInternetSales ***/

insert dbo.dimSales_2011
select
  CONVERT(varchar(8), OrderDate, 112),
  SUM(SalesAmount),
  SUM(TaxAmt),
  SUM(Freight)
from FactInternetSales
where OrderDate between '20110101' and '20131231'
group by CONVERT(varchar(8), OrderDate, 112);

/*** create a clustered index on the dimension table ***/

create CLUSTERED INDEX IDX_CCI_OrderDate
ON dbo.dimSales_2011 (OrderDate);
GO

/*** convert the clustered index into clustered columnstore index ***/

-- this query will first create clustered columnstore index with same name as clusterd index
-- then this will drop the existing clustered indexes if any and creates a new one.

create CLUSTERED COLUMNSTORE INDEX IDX_CCI_OrderDate
ON dbo.dimSales_2011
WITH (DROP_EXISTING = ON);
GO


/**************************************************************
  OBJECTIVE 02:
  Demonstrate how to define a nonclustered index 
  on a clustered columnstore index
**************************************************************/

/*** create a non clustered index on dimension table dimSales_2011 ***/

create INDEX nc2_sales ON dimSales_2011 ([SalesAmount]);
GO

create INDEX nc3_sales ON dimSales_2011 ([OrderDate]);
GO

/*** drop the dimension table for next objective ***/
-- check if dimSales exist anymore. It shouldn't.

drop table dbo.dimSales_2011;


/**************************************************************
  OBJECTIVE 03:
  Demonstrate how to create a nonclustered columnstore index 
  for real time performance analysis
**************************************************************/

/*** create a dimension table ***/

use AdventureWorksDW2022;
GO

create table dbo.dimSales_2011 
(
  Orderkey int IDENTITY (1,1), 
  --OrderKey will be primary key, each value will be generated in sequential manner, starting from 1 and increament by 1.
  OrderDate datetime not null,
  check (OrderDate between '20110101' and '20131231'),
  SalesAmount money not null,
  TaxAmt money not null,
  Freight money not null
);

/*** import data from FactInternetSales between 2011 and 2013 ***/

insert dbo.dimSales_2011
select
      CONVERT(varchar(8), OrderDate, 112),
      sum(SalesAmount), sum(TaxAmt), sum(Freight)
from FactInternetSales
where OrderDate between '20110101' and '20131231'
group by CONVERT(varchar(8), OrderDate, 112);

/*** running this query to find the key lookup cost in execution plan in smms ***/

select *
from dimSales_2011;

/*** create a nonclustered columnstore index on the dimension table ***/

create nonclustered COLUMNSTORE INDEX Sales_NCCI
on dimSales_2011 (Orderkey, OrderDate, TaxAmt);

/*** create a nonclustered index on dimension table ***/

use AdventureWorksDW2022;
GO

create NONCLUSTERED index Sales_nonCL
on dimSales_2011
(
  SalesAmount ASC,
  TaxAmt ASC
)

/*** run the select query and include execution plan ***/

select SalesAmount
from dimSales_2011
where TaxAmt > 24;
-- Total execution time: 00:00:00.017