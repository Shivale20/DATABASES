/*
|| Testing CHAR data types ERRORS.
||
|| Write edge cases for input string that validate against defined CharColumn CHAR(5).
|| This test will check:
|| 1. Exceeding length. 
|| 2. Trailing spaces. 
|| 3. Control characters.
|| 4. Multibyte characters.
|| 5. Collation differences.
|| 6. Implicit conversions.
|| 7. Invalid characters.
*/

/*
|| Create two tables.
||
|| Table 1:
|| - It is a table variable
|| - column1: ID INT PRIMARY KEY
|| - column2: Edge Value VARCHAR (255)
|| - column3: Results VARHCHAR(5)
|| - column4: ErrorMsg NVARCHAR(MAX)
||
|| Table 2:
|| - It is Temporary Table
|| - column1: ID INT PRIMARY KEY
|| - column2: CharColumn CHAR(5)
||
|| 1. The process begins with defining the edge cases.
|| 2. Two tables are created: 
||      Table 1 to store edge cases and their results, and 
||      Table 2 to test the CHAR(5) data type.
|| 3. The code then enters a loop to iterate through each edge case.
|| 4. Within the loop, each edge case is retrieved from Table 1 and 
||      inserted into Table 2 for testing.
|| 5. The result of the insertion (Pass/Fail) is checked.
|| 6. If the insertion fails, the error message is retrieved.
|| 7. The result and error message are stored in Table 1.
|| 8. The loop continues until all edge cases have been tested.
|| 9. After testing, the results are selected from Table 1.
|| 10. The process ends.
*/

/*
VALUES
    (1, 123456),                                -- Exceeding Length
    (2, 123.456),                               -- Numeric value
    (3, GETDATE()),                             -- Date/Time value
    (4, CAST('abc' AS VARCHAR)),                -- Variable-length string
    (5, CAST('abcdef' AS CHAR)),                -- Fixed-length string exceeding limit
    (6, CAST(123 AS SMALLINT)),                 -- Numeric value within range
    (7, CAST(123456 AS BIGINT)),                -- Numeric value exceeding range
    (8, CAST(123.456 AS DECIMAL(5,2))),         -- Numeric value exceeding precision/scale
    (9, 'abc   '),                              -- Trailing Spaces
    (10, 'abc' + CHAR(9)),                      -- Control Characters
    (11, N'äöü'),                               -- Multibyte Characters
    (12, 'abc'),                                -- Collation Differences
    (13, CAST(123 AS VARCHAR(255))),            -- Implicit Conversion
    (14, 'abc' + NCHAR(10000)),                 -- Invalid Characters
    (15, ''),                                   -- Empty string
    (16, NULL);                                 -- NULL value
*/




DROP TABLE IF EXISTS #TestTable;
CREATE TABLE #TestTable (
    ID INT PRIMARY KEY,
    CharColumn CHAR(5)
);


DECLARE @ResultTable TABLE (
    Results VARCHAR(5), 
    ErrorMsg NVARCHAR(MAX)
);

DECLARE 
    @RESULTS VARCHAR(5), 
    @ERROR NVARCHAR(MAX);


BEGIN TRY

    INSERT INTO #TestTable (ID, CharColumn)
    VALUES 
        (1, CAST(123 AS VARCHAR(255)))                              
    SET @RESULTS = 'PASS';
    SET @ERROR = NULL

END TRY 

BEGIN CATCH

    SET @RESULTS = 'FAIL';
    SET @ERROR = 'LINE '+ CAST(ERROR_LINE() AS VARCHAR)+ ': ' + ERROR_MESSAGE() 
    
END CATCH


INSERT INTO @ResultTable (Results, ErrorMsg)
VALUES (@RESULTS, @ERROR)

SELECT * FROM @ResultTable;


PRINT 'RESULT: ' + @RESULTS
PRINT 'Error Message at Line: ' + @ERROR;


-- Drop TestTable
DROP TABLE #TestTable;

GO 