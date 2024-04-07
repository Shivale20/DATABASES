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

/*
- open a try block 
- create a staging table with columns that are being filled.
- bulk insert data into staging table for their respective column using dynamic sql
- create a dynamic sql to get the columns from staging table
- store the columns to a input parameter to next query
- run the query using dynamic sql and using input parameter.
- close the try block
- catch any error message
- delete the staging table
*/

/*
Problem I am solving:

I have table of data that will be fed into a stored procedure as 
input parameter 

what would be the source of table?
1. from some previous internal query?
2. from external file
*/

/*
Input1: table: Col1: FromCurrencyCode ; Col2: ToCurrencyCode
Input2: scalar parameter: CurrencyRateDate

Output table: 
    Col1: CurrencyRateID, 
    Col2: FromCurrencyCode
    Col3: ToCurrencyCode
    Col4: AverageRate
    Col5: EndofDayRate
    Col6: CurrencyRateDate
*/

/*
Logic:
Batch1:
1. Define a user-defined table type with 2 cols.
    1. FromCurrencyCode
    2. ToCurrencyCode

Batch 2:
1. Create procedure- pass 2 parameters:
    1. user-defined table as READONLY
    2. conditional criteria parameter i.e CurrencyRateDate
2. Do the select query using both parameters to get output table
end of batch

Batch 3:
1. Declare TVP variable and Populate cols of table parameter either internally or through external source
2. Call stored procedure and pass TVP variable and another input parameter.

*/
-- Batch 1
USE AW2022;
GO
CREATE TYPE CurrencyCodeTableType AS TABLE ( 
    FromCurrencyCode nchar (3), ToCurrencyCode nchar (3))
GO

-- Batch 2
USE AW2022;
GO
CREATE PROCEDURE Sales.uspGetCurrencyInformationUDT
    @CurrencyCodeInputTable as CurrencyCodeTableType READONLY,
    @CurrencyRateDate DATE 
AS 
SELECT c.CurrencyRateID, c.FromCurrencyCode, c.ToCurrencyCode, c.AverageRate, c.EndOfDayRate, c.CurrencyRateDate
FROM Sales.CurrencyRate c 
JOIN @CurrencyCodeInputTable t 
ON t.FromCurrencyCode = c.FromCurrencyCode AND (t.ToCurrencyCode = c.ToCurrencyCode)
WHERE c.CurrencyRateDate = @CurrencyRateDate;
GO 

-- Batch 3:
DECLARE @CurrencyCodeTableVariable as CurrencyCodeTableType
INSERT INTO @CurrencyCodeTableVariable (FromCurrencyCode, ToCurrencyCode)
VALUES ('USD', 'AUD'), ('USD', 'GBP'), ('USD', 'CAD'), ('USD', 'MXN');

-- Call the procedure with parameters
EXEC Sales.uspGetCurrencyInformationUDT @CurrencyCodeInputTable = @CurrencyCodeTableVariable, 
@CurrencyRateDate = '2011-07-14';

