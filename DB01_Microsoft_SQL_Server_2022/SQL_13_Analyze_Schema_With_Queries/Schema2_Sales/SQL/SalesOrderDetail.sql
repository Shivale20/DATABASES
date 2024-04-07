-- Least Sold Products

USE AW2022;
GO 

SELECT
    TOP 5
    SOD.ProductID, 
    COUNT(*) AS [Count]
FROM Sales.SalesOrderDetail AS SOD
GROUP BY SOD.ProductID
ORDER BY COUNT(*);
GO


-- Product performance based on volume of sales
-- Volume of sales for each product
USE AW2022;
GO 

SELECT 
    TOP 5
    P.ProductID, 
    SUM(SOD.OrderQty) AS TotalOrderQty
FROM 
    Sales.SalesOrderDetail SOD 
INNER JOIN 
    Production.Product P 
ON 
    P.ProductID = SOD.ProductID
GROUP BY 
    P.ProductID
ORDER BY 
    P.ProductID;
GO

-- Product performance based on frequency of sales

USE AW2022;
GO 

SELECT 
    TOP 5
    P.ProductID, 
    count(SOD.OrderQty) AS SalesCount
FROM 
    Sales.SalesOrderDetail SOD 
INNER JOIN 
    Production.Product P 
ON 
    P.ProductID = SOD.ProductID
GROUP BY 
    P.ProductID
ORDER BY 
    P.ProductID;

/*
|| If you're interested in frequency or popularity, you'd use SalesCount. 
|| If you're interested in overall volume or revenue, you'd use TotalOrderQuantity.
*/


-- Most Popular Product By Product Subcategory

USE AW2022;
GO 

SELECT 
    Q.ProductID,
    RANK() OVER (
        PARTITION BY Q.ProductSubcategory
        ORDER BY SalesCount DESC) AS RankInSubcat,
    Q.Product, 
    Q.ProductSubcategory,
    Q.SalesCount
FROM 
(
SELECT 
    P.ProductID,
    P.Name AS Product, 
    PS.Name AS ProductSubcategory,
    COUNT(SOD.OrderQty) AS SalesCount
FROM 
    Sales.SalesOrderDetail SOD 
INNER JOIN 
    Production.Product P 
ON 
    P.ProductID = SOD.ProductID
INNER JOIN 
    Production.ProductSubcategory PS 
ON 
    PS.ProductSubcategoryID = P.ProductSubcategoryID
GROUP BY 
    P.ProductID,
    P.Name, 
    PS.Name

) AS Q

ORDER BY 
    RankInSubcat,
    SalesCount DESC;

/*
This ranking allows you to directly compare products within the same subcategory and identify the top-selling products in each category.
*/

-- Product performance comparision 

USE AW2022;
GO 

SELECT 
    PSCQ.ProductID,
    PSCQ.Product,
    PSCQ.SalesCount,

    NTILE(100) OVER(
        ORDER BY PSCQ.SalesCount
    ) AS ProductPercentile,

    PSCQ.ProductSubcategory,

    CAST (
        CAST (PSCQ.SalesCount AS numeric(9,2)) / 
        SUM(PSCQ.SalesCount) OVER(
            PARTITION BY PSCQ.ProductSubcategory)
        * 100 AS numeric (4,1) ) 
        AS ProductSubcategoryPercentile
FROM (
    SELECT 
        P.ProductID,
        P.Name AS Product,
        PC.Name AS ProductSubcategory,
        COUNT(SOD.OrderQty) AS SalesCount
    FROM 
        Sales.SalesOrderDetail AS SOD
    INNER JOIN 
        Production.Product AS P
    ON 
        P.ProductID = SOD.ProductID
    INNER JOIN 
        Production.ProductSubcategory PC
    ON 
        P.ProductSubcategoryID = PC.ProductSubcategoryID
    GROUP BY 
        P.Name,
        PC.Name, 
        P.ProductID
) AS PSCQ
ORDER BY
    ProductPercentile DESC;
GO 


/*
This percentile allows you to understand each product's performance relative to other products in the same subcategory, irrespective of their absolute sales counts.
*/