/**************************************************************
  OBJECTIVE 01:
  Demonstrate how to reorganize a columnstore index
**************************************************************/

-- check the fragmentation of the entire indexes in the dimSales_2011 table

/***
LOGIC:
- I need fragmentation % for each index in db
- so index id, index name and frag%
- frag% will come from ?
- index info will come from ?
- join both on ?

- sys.dm_db_index_physical_stats() function returns information about the physical characteristics of indexes.
- useful for analyzing the 

***/

SELECT *
FROM sys.indexes;

-- return the object id for dimension table.
select *
from sys.objects
where name = 'dimSales_2011';

-- return info for index fragmentation stats for dimension table
select *
from sys.dm_db_index_physical_stats(
  DB_ID(N'AdventureWorksDW2022'),
  OBJECT_ID(N''), 
  NULL, 
  NULL , 
  NULL
  )
WHERE object_id = (select object_id
from sys.objects
where name = 'dimSales_2011')

-- return index name and index id for dimension table
SELECT index_id, name as index_name
FROM sys.indexes
WHERE object_id = (select object_id
from sys.objects
where name = 'dimSales_2011')

-- return index id, index name and avg fragmentation in percent from both tables
select
  a.index_id,
  b.name as index_name,
  a.avg_fragmentation_in_percent as degree
from sys.dm_db_index_physical_stats(
  DB_ID(N'AdventureWorksDW2022'),
  OBJECT_ID(N''), 
  NULL, 
  NULL , 
  NULL
  ) as a
  JOIN sys.indexes as b
  ON a.index_id = b.index_id
WHERE b.object_id = (
  select object_id
  from sys.objects
  where name = 'dimSales_2011')
  AND (b.name IS NOT NULL)
  AND (a.avg_fragmentation_in_percent != 0)
ORDER BY a.avg_fragmentation_in_percent desc;


-- add another column to show reorganize or rebuild based on criteria
with
  c
  as
  (
    select
      a.index_id,
      b.name as index_name,
      a.avg_fragmentation_in_percent as degree
    from sys.dm_db_index_physical_stats(
  DB_ID(N'AdventureWorksDW2022'),
  OBJECT_ID(N''), 
  NULL, 
  NULL , 
  NULL
  ) as a
      INNER JOIN sys.indexes as b
      ON a.index_id = b.index_id
    WHERE b.object_id = (
  select object_id
      from sys.objects
      where name = 'dimSales_2011')
      AND (b.name IS NOT NULL)
      AND (a.avg_fragmentation_in_percent != 0)
  )
select
  c.index_id,
  c.index_name,
  CASE 
        WHEN (degree BETWEEN 5 AND 30) THEN 'reorganize'
        WHEN (degree > 30) THEN 'rebuild'
        ELSE 'no_action'
      END AS to_do
from c

-- remove ORDER BY a.avg_fragmentation_in_percent desc - it is not allowed in view ro subquery.

-- WARNING
-- above code gave misleading values

-- let's do this way


SELECT i.object_id, i.name, i.index_id
FROM sys.indexes i
WHERE object_id = (
      select object_id
from sys.objects
where name = 'dimSales_2011'
    );

select
  a.database_id,
  a.object_id,
  a.index_id,
  a.partition_number,
  a.avg_fragmentation_in_percent,
  a.fragment_count
from sys.dm_db_index_physical_stats(
  DB_ID(N'AdventureWorksDW2022'),
  OBJECT_ID(N''), 
  NULL, 
  NULL , 
  NULL
  ) AS a

-- return index name, fragmentation % and fragment count using above 2 tables

select
  i.name,
  a.avg_fragmentation_in_percent,
  a.fragment_count
from sys.dm_db_index_physical_stats(
  DB_ID(N'AdventureWorksDW2022'),
  OBJECT_ID(N''), 
  NULL, 
  NULL , 
  NULL
  ) AS a
  INNER JOIN sys.indexes i
  ON (i.object_id = a.object_id )
    AND (a.index_id = i.index_id)

-- categorize them into reorganize and rebuild

with
  desired_table
  as
  (
    select
      i.name as index_name,
      a.avg_fragmentation_in_percent as degree,
      a.fragment_count as fragment_count
    from sys.dm_db_index_physical_stats(
  DB_ID(N'AdventureWorksDW2022'),
  OBJECT_ID(N''), 
  NULL, 
  NULL , 
  NULL
  ) AS a
      INNER JOIN sys.indexes i
      ON (i.object_id = a.object_id )
        AND (a.index_id = i.index_id)
  )
SELECT desired_table.index_name as index_name,
  CASE 
        WHEN (degree BETWEEN 5 AND 30) THEN 'reorganize'
        WHEN (degree > 30) THEN 'rebuild'
        ELSE 'no_action'
      END AS to_do,
  desired_table.degree as degree,
  desired_table.fragment_count as fragment_count
FROM desired_table
ORDER BY degree desc;

-- from above table I can specifically ask for dimSales_2011 if I know their index name

-- actual_query
with
  desired_table
  as
  (
    select
      i.name as index_name,
      a.avg_fragmentation_in_percent as degree,
      a.fragment_count as fragment_count
    from sys.dm_db_index_physical_stats(
  DB_ID(N'AdventureWorksDW2022'),
  OBJECT_ID(N''), 
  NULL, 
  NULL , 
  NULL
  ) AS a
      INNER JOIN sys.indexes i
      ON (i.object_id = a.object_id )
        AND (a.index_id = i.index_id)
  )
SELECT desired_table.index_name as index_name,
  CASE 
        WHEN (degree BETWEEN 5 AND 30) THEN 'reorganize'
        WHEN (degree > 30) THEN 'rebuild'
        ELSE 'no_action'
      END AS to_do,
  desired_table.degree as degree,
  desired_table.fragment_count as fragment_count
FROM desired_table
WHERE index_name LIKE 'Sales_%'
ORDER BY degree desc;

-- results show that only Sales_nonCL needs reorganize and no rebuild for any index


-- stats before reorganizing for Sales-nonCL
select *
from sys.dm_db_index_physical_stats(
  DB_ID(N'AdventureWorksDW2022'),
  OBJECT_ID(N''), 
  NULL, 
  NULL , 
  NULL
  )
WHERE object_id = (select object_id
  from sys.objects
  where name = 'dimSales_2011') AND index_id = 2


-- REORGANIZE

USE AdventureWorksDW2022;
GO

ALTER INDEX [Sales_nonCL] 
ON [dbo].[dimSales_2011]
REORGANIZE;

--  query_action
select *
from sys.dm_db_index_physical_stats(
  DB_ID(N'AdventureWorksDW2022'),
  OBJECT_ID(N''), 
  NULL, 
  NULL , 
  NULL
  )
WHERE object_id = (select object_id
  from sys.objects
  where name = 'dimSales_2011') AND index_id = 2



/**************************************************************
  OBJECTIVE 02:
  Demonstrate how to rebuild a columnstore index

**************************************************************/

-- For the purpose of the demonstration, let us assume that the degree of fragmentation of Sales_NCCI non clustered columnstore index is greater than thirty percent.

--  query_action index = 3
select *
from sys.dm_db_index_physical_stats(
  DB_ID(N'AdventureWorksDW2022'),
  OBJECT_ID(N''), 
  NULL, 
  NULL , 
  NULL
  )
WHERE object_id = (select object_id
  from sys.objects
  where name = 'dimSales_2011') AND index_id = 3

-- index depth is 2
-- page count is 5

-- REBUILD Sales_NCCI

USE AdventureWorksDW2022;
GO

ALTER INDEX [Sales_NCCI] 
ON [dbo].[dimSales_2011]
REBUILD PARTITION = ALL with
( DATA_COMPRESSION = COLUMNSTORE);
GO

--  query_action index = 3
select *
from sys.dm_db_index_physical_stats(
  DB_ID(N'AdventureWorksDW2022'),
  OBJECT_ID(N''), 
  NULL, 
  NULL , 
  NULL
  )
WHERE object_id = (select object_id
  from sys.objects
  where name = 'dimSales_2011') AND index_id = 3


/*
DID THIS AFTER LEARNING \DB01_Developing_a_SQL_Databases\SQL_08_Creating_Stored_Procedures
*/

-- Create stored procedure to check which index needs reorganize or rebuild.

USE AdventureWorksDW2022;
GO

CREATE PROCEDURE sp_Check_Reorganize_Rebuild_Column
  @p_database_name NVARCHAR(100),
  @p_table_name NVARCHAR(100)
AS
SET NOCOUNT ON;
BEGIN

  SELECT
    a.object_id,
    b.name,
    a.hobt_id,
    a.partition_number,
    a.index_type_desc,
    a.index_depth,
    a.avg_fragmentation_in_percent ,
    CASE
      WHEN (avg_fragmentation_in_percent BETWEEN 5 AND 30) THEN 'Reorganize'
      WHEN (avg_fragmentation_in_percent > 30) THEN 'Rebuild'
      ELSE 'no_action'
  END AS 'Reorganize or Rebuild'
  FROM sys.dm_db_index_physical_stats(DB_ID(@p_database_name),OBJECT_ID(N''),NULL,NULL, NULL) as a
    join sys.objects as b
    on b.object_id = a.object_id
  where b.name = @p_table_name

  SET NOCOUNT OFF;
END

GO

-- create stored procedure to reorganize and rebuild
USE AdventureWorksDW2022;
GO
CREATE PROCEDURE sp_Reorganize_Index
  @p_table_name NVARCHAR(100)
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @SQL NVARCHAR(MAX) = '';
  SELECT @SQL += 
        'ALTER INDEX ' + QUOTENAME(i.name) + ' ON ' + QUOTENAME(OBJECT_SCHEMA_NAME(s.object_id)) + '.' + QUOTENAME(@p_table_name) + 
        ' REORGANIZE; '
  FROM sys.dm_db_index_physical_stats(DB_ID(), OBJECT_ID(N''), NULL, NULL, NULL) AS s
    JOIN sys.indexes AS i ON s.object_id = i.object_id AND s.index_id = i.index_id
    JOIN sys.objects AS o ON o.object_id = s.object_id
  WHERE o.name = @p_table_name
    AND
    (
        (s.avg_fragmentation_in_percent BETWEEN 5 AND 30) OR
    (s.avg_fragmentation_in_percent > 30 AND s.avg_fragmentation_in_percent IS NOT NULL)
    );

  EXEC sp_executesql @SQL;
END
GO

DECLARE @p_table_name NVARCHAR(100) = 'DimGeography'
-- before reorganize


EXEC sp_Check_Reorganize_Rebuild_Column 'AdventureWorksDW2022', @p_table_name;
EXEC sp_Reorganize_Index @p_table_name;
EXEC sp_Check_Reorganize_Rebuild_Column 'AdventureWorksDW2022', @p_table_name;
GO








/*
TO-DO:
Error Handling and Validation: Consider adding error handling and validation checks, especially when executing DDL statements like ALTER INDEX. This can help prevent unintended consequences or errors in production environments.

Documentation:  Ensure consistency and clarity in your comments throughout the script.

Testing: It's essential to thoroughly test your queries, especially when performing index maintenance operations like reorganizing or rebuilding indexes. Consider testing in a non-production environment before applying changes in a production environment.

*/