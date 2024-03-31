/**************************************************************
  SQL SERVER BIBLE
  Chapter 18: Building User-Defined Functions
**************************************************************/

------------------------------------------------------------

-- Get the metadata associated with udf
USE AW2022;
GO
SELECT definition, type
FROM sys.sql_modules m
    JOIN sys.objects o
    ON m.object_id = o.object_id AND type in ('FN', 'IF', 'TF');
GO

------------------------------------------------------------
-- Scalar function

USE AW2022;
GO
CREATE FUNCTION dbo.ufnCalculateQuotient (
    @Numerator NUMERIC(5,2), 
    @Denominator NUMERIC(5,2) = 1.0)
RETURNS NUMERIC (5,2)
AS
BEGIN
    RETURN @Numerator / @Denominator;
END;
GO

-- Call function
SELECT dbo.ufnCalculateQuotient(10.0, 5.0) AS Result1,
    dbo.ufnCalculateQuotient(7.0, DEFAULT) AS Result2;

-- Get the metadata associated with ufnCalculateQuotient

PRINT 'Get metadata for ufnCalculateQuotient'
USE AW2022;
GO
SELECT definition, type
FROM sys.sql_modules m
    JOIN sys.objects o
    ON m.object_id = o.object_id AND type in ('FN', 'IF', 'TF')
WHERE definition LIKE '%ufnCalculateQuotient%';
GO

-- Create function to get metadata associated with given UDF.
USE AW2022;
GO
CREATE FUNCTION dbo.ufnGetMetadataUfn (
    @FunctionName NVARCHAR(512)
)
RETURNS VARCHAR(512)
AS 
BEGIN
    RETURN (SELECT definition
    FROM sys.sql_modules
    WHERE definition LIKE '%' + CAST(@FunctionName AS NVARCHAR(512)) + '%');
END
GO

-- Get metadata for above created function
SELECT dbo.ufnGetMetadataUfn('ufnCalculateQuotient') as function1,
    dbo.ufnGetMetadataUfn('ufnGetMetadataUfn') as function2;

------------------------------------------------------------
-- Challenge1: Get the total number of orders of each product

USE AW2022;
GO
SELECT TOP(5)
    *
FROM Production.Product;
GO

USE AW2022;
GO
SELECT TOP(5)
    *
FROM Sales.SalesOrderDetail;

/*
- Scalar function to return single value that is Order Total.
- Parameter: Product Id
*/

-- Find OrderTotal of Product Id say 2 without function
USE AW2022;
GO
SELECT s.ProductID, SUM(s.OrderQty) as OrderTotal
FROM Production.Product p
    JOIN Sales.SalesOrderDetail s
    ON p.ProductID = s.ProductID
GROUP BY s.ProductID
ORDER BY 1;


USE AW2022;
GO
CREATE FUNCTION ufnGetOrderTotalByProduct(
    @ProductID INT
)
RETURNS INT
AS 
BEGIN
    DECLARE @OrderTotal INT;
    SELECT @OrderTotal = SUM(s.OrderQty)
    FROM Production.Product p
        JOIN Sales.SalesOrderDetail s
        ON s.ProductID = p.ProductID
    WHERE p.ProductID = @ProductID
    GROUP BY p.ProductID;

    RETURN @OrderTotal;
END;
GO

-- Get Order total for each Product 
USE AW2022;
GO
SELECT p.Name, dbo.ufnGetOrderTotalByProduct(p.ProductID) AS OrderTotal
FROM Production.Product p
ORDER BY 2 DESC;
GO

/*
result:
Name	        OrderTotal
AWC Logo Cap	8311
....            ...
*/


------------------------------------------------------------
-- Inline Table-Valued function: Comparision with scalar function

-- Get the table row with Product ID, Product Name and Sales Order Total for given Product ID

-- Do it without function
USE AW2022;
GO

SELECT p.ProductID, p.Name, OrderTotal = SUM(s.OrderQty)
FROM Production.Product p
    JOIN Sales.SalesOrderDetail s
    ON s.ProductID = p.ProductID
GROUP BY p.ProductID, p.Name
ORDER BY 3 DESC;
GO

-- Create inline table valued function to get table row for given Product ID
USE AW2022;
GO
CREATE FUNCTION dbo.ufnGetProductOrderTotals(
    @ProductID INT
)
RETURNS TABLE 
AS 
    RETURN (
        SELECT p.ProductID, p.Name, OrderTotal = SUM(s.OrderQty)
FROM Production.Product p
    JOIN Sales.SalesOrderDetail s
    ON s.ProductID = p.ProductID
WHERE s.ProductID = @ProductID
GROUP BY p.ProductID, p.Name
        -- ORDER BY 3 DESC invalid in views
    );
GO

-- Call the function for Product ID = 782

SELECT ProductID, Name, OrderTotal
FROM dbo.ufnGetProductOrderTotals(782);
GO

/*
result:
ProductID	Name	                    OrderTotal
782	        Mountain-200 Black, 38	    2977
*/

------------------------------------------------------------
-- Inline Table-Valued function

-- Get Order total for each Product Category

-- Do it without function
USE AW2022;
GO
SELECT TOP 1
    s.ProductID, s.OrderQty
FROM Sales.SalesOrderDetail s;
SELECT TOP 1
    p.ProductID, p.Name, p.ProductSubcategoryID
FROM Production.Product p;
SELECT TOP 1
    ps.ProductCategoryID, ps.ProductSubcategoryID
FROM Production.ProductSubcategory ps;
SELECT TOP 1
    pc.ProductCategoryID
FROM Production.ProductCategory pc;
GO

USE AW2022;
GO
SELECT p.ProductID, p.Name, OrderTotal = SUM(s.OrderQty)
FROM Sales.SalesOrderDetail s
    JOIN Production.Product p
    ON s.ProductID = p.ProductID
    JOIN Production.ProductSubcategory ps
    ON p.ProductSubcategoryID = ps.ProductSubcategoryID
    JOIN Production.ProductCategory pc
    ON pc.ProductCategoryID = ps.ProductCategoryID
GROUP BY p.ProductID, p.Name;
GO

-- For only one subcategory say 1
USE AW2022;
GO
SELECT p.ProductID, p.Name, OrderTotal = SUM(s.OrderQty)
FROM Sales.SalesOrderDetail s
    JOIN Production.Product p
    ON s.ProductID = p.ProductID
    JOIN Production.ProductSubcategory ps
    ON p.ProductSubcategoryID = ps.ProductSubcategoryID
    JOIN Production.ProductCategory pc
    ON pc.ProductCategoryID = ps.ProductCategoryID
WHERE ps.ProductSubcategoryID = 1
-- this is parameter
GROUP BY p.ProductID, p.Name;

-- Create function to get set of ProductID, ProductName and OrderTotal for given ProductSubCategoryID
USE AW2022;
GO

CREATE FUNCTION dbo.ufnGetProductSubCategoryOrderTotal(
    @ProductSubCategoryID INT
)
RETURNS TABLE
AS 
    RETURN (
        SELECT p.ProductID, p.Name, OrderTotal = SUM(s.OrderQty)
FROM Sales.SalesOrderDetail s
    JOIN Production.Product p
    ON s.ProductID = p.ProductID
    JOIN Production.ProductSubcategory ps
    ON p.ProductSubcategoryID = ps.ProductSubcategoryID
    JOIN Production.ProductCategory pc
    ON pc.ProductCategoryID = ps.ProductCategoryID
WHERE ps.ProductSubcategoryID = @ProductSubCategoryID
-- this is parameter
GROUP BY p.ProductID, p.Name
    );
GO

-- Call the function to get the set for subcategoryID = 1 : 
select name
from Production.ProductSubcategory
where ProductSubcategoryID = 1;
-- i.e Mountain Bikes

SELECT ProductID, Name, OrderTotal
FROM dbo.ufnGetProductSubCategoryOrderTotal(1)
ORDER BY 3 desc;
GO



-- Create function to get set of ProductID, ProductName and OrderTotal for given ProductCategoryID
USE AW2022;
GO

CREATE FUNCTION dbo.ufnGetProductCategoryOrderTotal(
    @ProductCategoryID INT
)
RETURNS TABLE
AS 
    RETURN (
        SELECT p.ProductID, p.Name, OrderTotal = SUM(s.OrderQty)
FROM Sales.SalesOrderDetail s
    JOIN Production.Product p
    ON s.ProductID = p.ProductID
    JOIN Production.ProductSubcategory ps
    ON p.ProductSubcategoryID = ps.ProductSubcategoryID
    JOIN Production.ProductCategory pc
    ON pc.ProductCategoryID = ps.ProductCategoryID
WHERE pS.ProductCategoryID = @ProductCategoryID
-- this is parameter
GROUP BY p.ProductID, p.Name
    );
GO

-- Call the function to get the set for Category = 1 : 
select name
from Production.ProductCategory p
where p.ProductCategoryID = 1;
-- i.e Bikes

SELECT ProductID, Name as Bikes_Name, OrderTotal
FROM dbo.ufnGetProductCategoryOrderTotal(1)
ORDER BY 3 desc;
GO

-- Call the function to get the set for Category = 3 : 
select name
from Production.ProductCategory p
where p.ProductCategoryID = 3;
-- i.e Clothing

SELECT ProductID, Name as Clothing_Name, OrderTotal
FROM dbo.ufnGetProductCategoryOrderTotal(3)
ORDER BY 3 desc;
GO



-- Use CROSS APPLY to get order totals for each Product
SELECT ProductID, Name, OrderTotal
FROM dbo.ufnGetProductOrderTotals(782);
GO

SELECT t.Name, t.OrderTotal
FROM Production.Product p 
CROSS APPLY dbo.ufnGetProductOrderTotals(p.ProductID) t
ORDER BY t.OrderTotal DESC;
GO

-- Get Order total for each Product 
USE AW2022;
GO
SELECT p.Name, dbo.ufnGetOrderTotalByProduct(p.ProductID) AS OrderTotal
FROM Production.Product p
ORDER BY 2 DESC;
GO
/*
observations:
- The first query retrieves order totals using a table-valued function and CROSS APPLY.
- The second query retrieves order totals using a scalar-valued function called for each row directly in the SELECT statement.
*/

------------------------------------------------------------
-- Multistatement Table-Valued Functions

-- Get every product in Product table and the order total for each product

-- Do it without function

USE AW2022;
GO

SELECT s.ProductID, p.Name, SUM(s.OrderQty) AS Total
FROM Sales.SalesOrderDetail s
    JOIN Production.Product p
    ON s.ProductID = p.ProductID
GROUP BY s.ProductID, p.Name
ORDER BY Total desc;

-- Create the function 

USE AW2022;
GO

CREATE FUNCTION dbo.ufnGetProductsAndOrderTotals()
RETURNS @ProductList TABLE (
    ProductID INT,
    ProductName NVARCHAR(100),
    TotalOrders INT
)
AS 
BEGIN 
    -- insert 
    INSERT @ProductList( ProductID, ProductName)
    SELECT ProductID, Name
    FROM Production.Product;

    UPDATE pl 
    SET TotalOrders = (SELECT dbo.ufnGetOrderTotalByProduct(pl.ProductID))
    FROM @ProductList pl
    
    RETURN;
END;
GO

-- Call the function
SELECT ProductID, ProductName, TotalOrders
FROM ufnGetProductsAndOrderTotals()
ORDER BY TotalOrders DESC;
GO 