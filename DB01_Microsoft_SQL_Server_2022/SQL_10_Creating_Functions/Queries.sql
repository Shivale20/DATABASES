/**************************************************************
  OBJECTIVE 01:
  Demonstrate how to create a scalar function.
**************************************************************/

------------------------------------------------------------

-- Create a function CurrencyRateDifference

USE DW2022;
GO

CREATE FUNCTION sfn_Calculate_Currency_Rate_Difference( 
        @sfn_Start_Date DATE,
        @sfn_End_Date DATE,
        @sfn_Currency_Key INT
)
RETURNS FLOAT
AS
BEGIN
    DECLARE @sfn_Rate_Difference FLOAT;
    DECLARE @sfn_Starting_Rate FLOAT;
    -- logic of function
    SELECT TOP 1
        @sfn_Starting_Rate = EndOfDayRate
    FROM FactCurrencyRate
    WHERE CurrencyKey = @sfn_Currency_Key AND Date IN (@sfn_Start_Date, @sfn_End_Date)
    ORDER BY DATE ASC

    SELECT TOP 1
        @sfn_Rate_Difference = EndOfDayRate - @sfn_Starting_Rate
    FROM FactCurrencyRate
    WHERE CurrencyKey = @sfn_Currency_Key AND Date IN (@sfn_Start_Date, @sfn_End_Date)
    ORDER BY DATE DESC;

    RETURN @sfn_Rate_Difference;
END
GO


-- Call the function 

SELECT dbo.sfn_Calculate_Currency_Rate_Difference('2010-12-29 00:00:00.000','2014-02-27 00:00:00.000',3) as sfn_Rate_Difference

/*
results:--
sfn_Rate_Difference
-0.7251200421894419
*/


/**************************************************************
  OBJECTIVE 02:
  Demonstrate how to write Table valued functions
**************************************************************/

------------------------------------------------------------

-- Create the inline table valued function 

-- function that returns product details based on giving parameter
USE DW2022;
GO
CREATE FUNCTION udf_Product_Details(
    @udf_Product_Id INT
)
RETURNS TABLE
AS
RETURN 
SELECT *
FROM DimProduct
WHERE ProductKey = @udf_Product_Id
GO

-- Call the function
SELECT *
FROM udf_Product_Details(1);


------------------------------------------------------------

-- Create the multi-line table valued function 

/*
Problem:
Calculate the rate difference for each currency between the specified start and end dates and returns the result as a table variable.

-function takes two parameters @StartDate and @EndDate, both of type DATETIME, and returns a table variable @CurRateDifference with columns CurrencyKey (INT) and rateDiff (FLOAT).
*/

-- Do this without function
/*
logic:
We have been given two specified date say Date1 and Date2
Find the earliest date close to Date 1 for currency A and its rate say earliest rate
Find the latest date close to Date 2 for currency A and its rate say latest rate
Find the difference between latest and earliest rate-- this difference is for currency A only.

Now we have to do it for all currency type in the list.
*/
-- Get data between two specified dates
DECLARE @startDate DATETIME = '2010-01-01', @endDate DATETIME = '2010-12-31';
with
    table1
    as
    (
        SELECT CurrencyKey, EndOfDayRate, ROW_NUMBER() OVER (PARTITION BY CurrencyKey ORDER BY Date DESC) as Latest
        FROM FactCurrencyRate
        WHERE [Date] BETWEEN @startDate AND @endDate
    ),
    table2
    as
    (
        SELECT CurrencyKey, EndOfDayRate, ROW_NUMBER() OVER (PARTITION BY CurrencyKey ORDER BY Date ASC) as Earliest
        FROM FactCurrencyRate
        WHERE [Date] BETWEEN @startDate AND @endDate
    )
SELECT table1.CurrencyKey, (table1.EndOfDayRate - table2.EndOfDayRate) AS RateDifference
FROM table1
    INNER JOIN table2
    ON table1.CurrencyKey = table2.CurrencyKey AND table1.Latest = table2.Earliest
WHERE table1.Latest = 1 AND table2.Earliest = 1;

-- Create function to find the RateDifference between specified dates

USE DW2022;
GO

CREATE FUNCTION udf_Currency_Rate_Difference (
    @udf_start_date DATETIME,
    @udf_end_date DATETIME
)
RETURNS TABLE 
AS
RETURN
(
    WITH table1 AS (
        SELECT CurrencyKey, EndOfDayRate, ROW_NUMBER() OVER (PARTITION BY CurrencyKey ORDER BY Date DESC) AS Latest
        FROM FactCurrencyRate
        WHERE [Date] BETWEEN @udf_start_date AND @udf_end_date
    ),
    table2 AS (
        SELECT CurrencyKey, EndOfDayRate, ROW_NUMBER() OVER (PARTITION BY CurrencyKey ORDER BY Date ASC) AS Earliest
        FROM FactCurrencyRate
        WHERE [Date] BETWEEN @udf_start_date AND @udf_end_date   
    )
    SELECT table1.CurrencyKey, (table1.EndOfDayRate - table2.EndOfDayRate) AS RateDifference
    FROM table1
    INNER JOIN table2 ON table1.CurrencyKey = table2.CurrencyKey AND table1.Latest = 1 AND table2.Earliest = 1
);
GO

-- call the function
USE DW2022;
GO
SELECT * FROM udf_Currency_Rate_Difference ('2010-01-01','2010-12-31' )
WHERE CurrencyKey = 3;

/*
result:--
RateDifference
-0.00019988005597593173

This shows that price of Currency 3 has plumetted during year 2010.
*/

-- call the function to find the significant change in rate and its corresponding currency
USE DW2022;
GO
SELECT CurrencyKey, RateDifference
FROM udf_Currency_Rate_Difference('2010-01-01','2010-12-31')
ORDER BY 2;

/*
Currency 36: Costlier
Currency 6: Cheaper
*/
go
