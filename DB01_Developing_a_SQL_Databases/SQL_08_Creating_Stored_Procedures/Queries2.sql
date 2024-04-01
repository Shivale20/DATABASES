/*
Problem I am solving:

Create a simple procedure that selects the contents of the Sales.Currency table

Input: None
Output: A table
*/

USE AW2022;
GO

CREATE PROCEDURE Sales.uspGetCurrencyInformation
AS
SELECT CurrencyCode, Name
FROM Sales.Currency;

GO

-- Call usp: Method 1
EXEC Sales.uspGetCurrencyInformation;

-- View usp using sp_helptext
EXEC sp_helptext 'Sales.uspGetCurrencyInformation';


/*
Problem I am solving:

Provide a single value as Input Parameter in procedure.

Input: a single string or int value
Output: A table based on input
*/

-- Get currency information based on given currency code 

USE AW2022;
GO

CREATE PROCEDURE Sales.uspGetCurrencyInformationByCode
    @CurrencyCode char (3)
AS
SELECT CurrencyCode, Name
FROM Sales.Currency
WHERE CurrencyCode = @CurrencyCode;

GO

-- Call usp
EXEC Sales.uspGetCurrencyInformationByCode 'USD';
GO


/*
Problem I am solving:

Alter procedure Sales.uspGetCurrencyInformationByCode
and Give default value for CurrencyCode

Show how to call usp with default parameter value.
*/

USE AW2022;
GO

ALTER PROCEDURE Sales.uspGetCurrencyInformationByCode
    @CurrencyCode char (3) = 'USD'
AS 
SELECT CurrencyCode, Name
FROM Sales.Currency
WHERE CurrencyCode = @CurrencyCode;

GO

-- Call usp without parameter value
EXEC Sales.uspGetCurrencyInformationByCode;
GO

/*
Problem I am solving:

I have a list of values only for which I need to do query.
Provide a list as Input Parameter to stored procedure.

Input: a list 
Output: a table
*/


-- Get the currency rate for given currency list = ['USD', 'AUD', 'CAD', 'MXN']

-- Without usp 
USE AW2022;
GO
SELECT *
FROM Sales.Currency
WHERE CurrencyCode IN ('USD', 'AUD', 'CAD', 'MXN')
ORDER BY CurrencyCode;

-- What if we want to run same query but for differenct currency code list.
-- i.e WHERE CurrencyCode IN @CurrencyCodelist

-- Method 1: Dynamic SQL in Stored Procedure

USE AW2022;
GO

CREATE PROCEDURE Sales.uspGetCurrencyInformationByCodeList
    @CurrencyCodeList VARCHAR (50)
AS

DECLARE @SQLString NVARCHAR(1000)

SET @SQLString = N'
SELECT CurrencyCode, Name
FROM Sales.Currency
WHERE CurrencyCode IN ('+@CurrencyCodeList+');
'
EXECUTE sp_executesql @SQLString;

GO

-- Call the usp with a list formatted properly for SQLString
EXECUTE Sales.[uspGetCurrencyInformationByCodeList] '''USD'', ''AUD'', ''CAD'', ''MXN''';
GO

/*
Problem I am solving:

I have a huge list of values and it is stored as csv file.
Everytime I update the list, the stored procedure
should also provide currency rate for those currency code in the list.
*/

/*
logic:
create a procedure that will execute the Sales.[uspGetCurrencyInformationByCodeList] with formatted currencycode list.

create a staging table for currency
declare @list 
import data from csv into staging table
select currency code and format it and store in @list 
and use @ list while calling procedure execute the Sales.[uspGetCurrencyInformationByCodeList]
and then delete the staging table.
*/


USE AW2022;
GO

CREATE PROCEDURE Sales.uspGetCurrencyInformationByImportedcsvList
    @CurrencyCodeListCSVFilePath NVARCHAR(MAX)
AS
BEGIN
    BEGIN TRY
        -- Declare the temporary table outside of dynamic SQL
        CREATE TABLE #StagingCurrency
    (
        CurrencyCode CHAR(3)
    );

        -- Load data into the staging table
        DECLARE @SQLString NVARCHAR(MAX);
        SET @SQLString = N'BULK INSERT #StagingCurrency 
        FROM ''' + @CurrencyCodeListCSVFilePath + '''
        WITH (FIELDTERMINATOR = '','', ROWTERMINATOR = ''\n'')';
        EXEC sp_executesql @SQLString;

        -- Get the list of currency codes
        DECLARE @CurrencyCodeList NVARCHAR(MAX);
        SELECT @CurrencyCodeList = STRING_AGG(QUOTENAME(CurrencyCode,''''), ',')
    FROM #StagingCurrency;

        -- Construct and execute the SQL query
        SET @SQLString = N'
        SELECT CurrencyCode, Name
        FROM Sales.Currency
        WHERE CurrencyCode IN (' + @CurrencyCodeList + ')';
        EXEC sp_executesql @SQLString;

    END TRY
    BEGIN CATCH
        -- Handle errors
        PRINT 'An error occurred: ' + ERROR_MESSAGE();
    END CATCH;

    -- Drop the temporary table
    DROP TABLE IF EXISTS #StagingCurrency;
END;
GO

EXECUTE Sales.uspGetCurrencyInformationByImportedcsvList 'C:\Users\manish.shivale\Documents\Projects\DATABASES\DB01_Developing_a_SQL_Databases\SQL_08_Creating_Stored_Procedures\CurrencyCode.csv';
GO 

