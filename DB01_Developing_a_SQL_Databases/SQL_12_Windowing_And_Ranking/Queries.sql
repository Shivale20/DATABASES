/*
Action:
Retrieve a list of Purchase Order IDs and their corresponding Ship Dates for a specific employee.

Data:
- Database: AW2022
- Table: PurchaseOrderHeader
- Columns: PurchaseOrderID, ShipDate
- Filter: EmployeeID = 259

Requirements:
1. Use the ROW_NUMBER() function to generate a sequential row number for each record, ordered by ShipDate.
2. Retrieve Purchase Order IDs and Ship Dates.
3. Filter the data to only include records where EmployeeID is 259.

*/

USE AW2022;
GO

SELECT 
	ROW_NUMBER() OVER(ORDER BY ShipDate) as RowNumber,
	PurchaseOrderID,
	ShipDate
FROM Purchasing.PurchaseOrderHeader
WHERE EmployeeID = 259;
GO




/*
Task Description: Retrieving Purchase Orders by Employee ID with Pagination

Objective:
Retrieve a subset of purchase orders belonging to a specific employee, with pagination applied.

Steps:
1. Retrieve purchase orders for a specified employee.
2. Apply row numbers to the result set ordered by ship date.
3. Filter the result set to include rows between specified row numbers for pagination.

Additional Notes:
Pagination allows for easier navigation of large result sets by dividing them into smaller, more manageable pages.
*/

USE AW2022;
GO

WITH PQ1 AS (
    SELECT 
	ROW_NUMBER() OVER(ORDER BY ShipDate) as RowNumber,
	PurchaseOrderID,
	ShipDate
    FROM Purchasing.PurchaseOrderHeader
    WHERE EmployeeID = 259
)
SELECT *
FROM PQ1 
WHERE PQ1.RowNumber BETWEEN 20 AND 30;
GO



/*
Task Description: Retrieving Purchase Orders by Employee ID with Offset and Fetch

Objective:
Retrieve a subset of purchase orders belonging to a specific employee, with offset and fetch applied for pagination.

Steps:
1. Retrieve purchase orders for a specified employee.
2. Apply row numbers to the result set ordered by ship date.
3. Filter the result set to include rows starting from a specified offset and fetching a specified number of rows.

Additional Notes:
Offset and fetch clauses are useful for implementing pagination in SQL queries.
Ensure that the ORDER BY clause is specified before the OFFSET and FETCH clauses to avoid syntax errors.
Adjust the offset and fetch values to change the pagination range as needed.
*/

USE AW2022;
GO

SELECT 
	ROW_NUMBER() OVER(ORDER BY ShipDate) as RowNumber,
	PurchaseOrderID,
	ShipDate
FROM Purchasing.PurchaseOrderHeader
WHERE EmployeeID = 259
ORDER BY RowNumber
OFFSET 20 ROWS
FETCH NEXT 10 ROWS ONLY;
GO


/*
Task Description: Analyze Sales Performance by Product ID

Action:
Analyze the sales performance of products based on the number of sales, using ranking functions.

Data:
- Database: AW2022
- Table: SalesOrderDetail
- Columns: ProductID
- Aggregated Column: COUNT(*) as NumberOfSales

Requirements:
1. Count the number of sales for each product.
2. Use RANK() and DENSE_RANK() functions to rank products based on the number of sales.
3. Order the results by the ranking.

Additional Notes:
- The RANK() function assigns a unique rank to each row, with gaps in the sequence in case of ties.
- The DENSE_RANK() function assigns a unique rank to each row without any gaps, in case of ties.
- The results are ordered by the rank.
*/


USE AW2022;
GO
SELECT 
    ProductID, 
    COUNT(*) AS NumberOfSales, 
    RANK() OVER(ORDER BY COUNT(*)) AS [Rank], 
    DENSE_RANK() OVER(ORDER BY COUNT(*)) AS [Dense_Rank]
FROM Sales.SalesOrderDetail
GROUP BY ProductID
ORDER BY [Rank];
GO



/*
Task Description: Analyze Sales Performance and Handle Tie Situations

Action:
Analyze the sales performance of products and handle tie situations using ranking functions.

Data:
- Database: AW2022
- Table: SalesOrderDetail
- Columns: ProductID
- Aggregated Column: COUNT(*) as NumberOfSales

Requirements:
1. Count the number of sales for each product.
2. Use the RANK() function to rank products based on the number of sales.
3. Handle tie situations where multiple products have the same rank.
4. Display the product ID, number of sales, and indicate tie situations.

Additional Notes:
- The RANK() function assigns a unique rank to each row, with gaps in the sequence in case of ties.
- The CTE "PQ1" calculates the number of sales for each product.
- The CTE "PQ2" calculates the rank of each product based on the number of sales.
- Tie situations are handled by comparing each product's rank with other products.
- AND PQ2.ProductID != Q3.ProductID make sure we do not keep the duplicate ProductIDs when cartisian product was formed due to self-join.
*/


USE AW2022;
GO

WITH PQ1 AS (
SELECT 
    ProductID,
    COUNT(*) AS NumberOfSales
FROM Sales.SalesOrderDetail
GROUP BY ProductID
),
PQ2 AS (
    SELECT 
        PQ1.ProductID,
        PQ1.NumberOfSales,
        RANK() OVER (ORDER BY PQ1.NumberOfSales) AS [Rank]
    FROM PQ1
)
SELECT 
    PQ2.ProductID, 
    PQ2.NumberOfSales,
    CONCAT('Tie_at_', PQ2.Rank) AS Tie_at_Rank
FROM PQ2
JOIN PQ2 AS Q3
ON PQ2.Rank = Q3.Rank AND PQ2.ProductID != Q3.ProductID
GO

/*

Task Description:
Objective:
Retrieve product sales information and calculate percentiles for each product's sales count and sales count within each product subcategory.

Data:
- Database: AW2022
- Tables:
  - Sales.SalesOrderDetail (Alias: SOD)
  - Production.Product (Alias: P)
  - Production.ProductSubcategory (Alias: PSC)
- Columns:
  - ProductID
  - Product (Name of the product)
  - SalesCount (Number of sales for each product)
  - ProductSubcategory (Name of the product subcategory)
- Calculations:
  - Calculate the percentile rank of each product's sales count across all products.
  - Calculate the sales count percentile within each product subcategory.

Additional Notes:
- The query calculates percentiles for product sales counts to analyze the distribution of sales across products.
- Percentile values are calculated both globally and within each product subcategory.
- Sales count percentiles provide insights into the relative performance of each product and product subcategory.
- The query is optimized for performance by aggregating data at the product and product subcategory levels before calculating percentiles.
*/


USE AW2022;
GO 

SELECT 
    ProductID, 
    Product, 
    SalesCount, 
    NTILE(100) OVER ( ORDER BY SalesCount) AS Percentile,
    ProductSubcategory, 
    CAST(
        CAST(SalesCount AS numeric(9,2)) / SUM(SalesCount) OVER (PARTITION BY ProductSubcategory)* 100 AS numeric(4,1)) AS SubPercentile

FROM (SELECT 
    P.ProductID, 
    P.[Name] AS Product,
    PSC.[Name] AS ProductSubcategory,
    COUNT(*) AS SalesCount
FROM Sales.SalesOrderDetail AS SOD
JOIN Production.Product AS P 
ON P.ProductID = SOD.ProductID
JOIN Production.ProductSubcategory AS PSC 
ON P.ProductSubcategoryID = PSC.ProductSubcategoryID
GROUP BY PSC.Name, P.[Name], P.ProductID) AS Q 
ORDER BY Percentile DESC;

-- Identify Underperforming Products:
-- 1. "LL Mountain Frame - Black, 52": This product has a relatively low sales count and percentile compared to other items in the dataset, indicating lower demand or market interest.
-- 2. "LL Touring Frame - Blue, 58": Similarly, this product exhibits lower sales counts and percentiles, suggesting it may not be as popular among customers compared to other touring frames.

-- Identify Overperforming Products:
-- 1. "Water Bottle - 30 oz.": This product stands out with a high sales count and percentile, indicating strong demand and popularity among customers.
-- 2. "AWC Logo Cap": With a high sales count and percentile, this product performs exceptionally well compared to other caps in the dataset, demonstrating its popularity and market demand.
