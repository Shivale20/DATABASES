/**************************************************************
  OBJECTIVE 01:
  Demonstrate how to create a DDL trigger using Transact-SQL statement
**************************************************************/

------------------------------------------------------------

-- Create a test table
USE AdventureWorksDW2022;
GO
CREATE TABLE dbo.DDLTrigger_test_table
(
    col1 INT,
    col2 NVARCHAR(20)
)
GO

------------------------------------------------------------

-- Create a DDL trigger on Database
CREATE TRIGGER trg_Table_Safety
ON DATABASE
FOR DROP_TABLE, ALTER_TABLE
AS
    BEGIN
    PRINT 'You can not drop or alter the table.'
    ROLLBACK;
END
GO

-- Get the list of triggers 
SELECT *
FROM sys.triggers;

------------------------------------------------------------

-- Drop the table and check trigger execution

USE AdventureWorksDW2022;
GO
DROP TABLE DDLTrigger_test_table;
GO

/*
result:
You can not drop or alter the table. 
	
	Msg 3609, Level 16, State 2, Line 3
The transaction ended in the trigger. The batch has been aborted. 
*/

-- Check if table is dropped

USE AdventureWorksDW2022;
GO
SELECT TOP(1)
    name, object_id, type_desc
FROM sys.tables
ORDER BY modify_date desc;
GO
/*
result:
name	                object_id	type_desc
DDLTrigger_test_table	222623836	USER_TABLE
*/

/*
conclusion:--
        Trigger executed and table did not drop.
*/

------------------------------------------------------------

-- Alter the table and check trigger execution.

USE AdventureWorksDW2022;
GO
ALTER TABLE DDLTrigger_test_table
    ADD col3 INT;
GO

/*
result:
You can not drop or alter the table. 
	
	Msg 3609, Level 16, State 2, Line 3
The transaction ended in the trigger. The batch has been aborted.
*/

-- Check columns of table and check if trigger executed.

USE AdventureWorksDW2022;
GO
SELECT *
FROM DDLTrigger_test_table;
GO

/*
result:
Table shows col1 and col2 only
*/

/*
conclusion:--
        Table was not altered and trigger worked.
*/

------------------------------------------------------------

-- Drop the trigger trg_Table_Safety.
USE AdventureWorksDW2022;
GO
DROP TRIGGER trg_Table_Safety ON DATABASE;
GO

-- Get the list of triggers 
SELECT *
FROM sys.triggers;


/**************************************************************
  OBJECTIVE 02:
  Demonstrate how to create a DML trigger using Transact-SQL statement
**************************************************************/

------------------------------------------------------------

-- Transfer the data from FactCurrencyRate table to FactCurrencyRate_updateAudit table.

USE AdventureWorksDW2022;
GO
SELECT *
INTO FactCurrencyRate_updateAudit
FROM FactCurrencyRate
WHERE 1<>1
GO

SELECT *
FROM FactCurrencyRate_updateAudit

-- Add a new column updateDate in FactCurrencyRate_updateAudit

USE AdventureWorksDW2022;
GO
ALTER TABLE FactCurrencyRate_updateAudit
    ADD updateDate DATETIME;
GO

SELECT *
FROM FactCurrencyRate_updateAudit



------------------------------------------------------------

-- Create a trigger on UPDATE statement

/*
logic:
    events: This trigger is fired FOR UPDATE events on the FactCurrencyRate table. It means it activates whenever a record in the FactCurrencyRate table is updated.

    action: Upon an update to a row in the FactCurrencyRate table, the trigger inserts a new record into the FactCurrencyRate_updateAudit table.

    updateDate: new column will have date and time when update was executed.
*/

USE AdventureWorksDW2022;
GO
CREATE TRIGGER trg_Track_Update_FactCurrencyRate
ON [FactCurrencyRate]
FOR UPDATE
AS
    INSERT INTO FactCurrencyRate_updateAudit
    (
    CurrencyKey, DateKey, AverageRate, EndOfDayRate, Date, updateDate
    )
SELECT CurrencyKey, DateKey, AverageRate, EndOfDayRate, Date, GETDATE()
FROM DELETED
GO

-- Get the list of triggers 
SELECT TOP(2) *
FROM sys.triggers
ORDER BY modify_date desc;


------------------------------------------------------------

-- Update the EndOfDayRate column values in FactCurrencyRate table

USE AdventureWorksDW2022;
GO
UPDATE FactCurrencyRate
SET EndOfDayRate = 0.998000399912
WHERE CurrencyKey = 3
    AND DateKey = 20101229
GO

-- Check the FactCurrencyRate_updateAudit for new data if Trigger worked.

SELECT * FROM FactCurrencyRate_updateAudit;

/*
results:--
CurrencyKey	DateKey	AverageRate	EndOfDayRate	Date	updateDate
3	20101229	1	0.999800039992002	2010-12-29 00:00:00.000	2024-03-30 15:22:18.453

*/

/*
conclusion:--
        Trigger trg_Track_Update_FactCurrencyRate is working.
*/


------------------------------------------------------------

-- Drop the trigger trg_Table_Safety.
USE AdventureWorksDW2022;
GO
DROP TRIGGER trg_Track_Update_FactCurrencyRate;
GO

-- Get the list of triggers 
SELECT *
FROM sys.triggers;


-- Drop the table FactCurrencyRate_updateAudit.
USE AdventureWorksDW2022;
GO
DROP TABLE FactCurrencyRate_updateAudit;
GO


/**************************************************************
  OBJECTIVE 02:
  Demonstrate how to create a DML trigger (AFTER UPDATE) 
  using Transact-SQL statement
**************************************************************/

------------------------------------------------------------

-- Transfer the data from FactCurrencyRate table to FactCurrencyRate_updateAudit table.

USE AdventureWorksDW2022;
GO
SELECT *
INTO FactCurrencyRate_updateAudit
FROM FactCurrencyRate
WHERE 1<>1
GO

SELECT *
FROM FactCurrencyRate_updateAudit

-- Add a new column updateDate in FactCurrencyRate_updateAudit

USE AdventureWorksDW2022;
GO
ALTER TABLE FactCurrencyRate_updateAudit
    ADD updateDate DATETIME;
GO

SELECT *
FROM FactCurrencyRate_updateAudit



------------------------------------------------------------

-- Create a trigger on UPDATE statement

/*
logic:
    events: This trigger is fired AFTER UPDATE events on the FactCurrencyRate table. It means it activates when FactCurrencyRate table is updated.

    action: Upon an update to a row in the FactCurrencyRate table, the trigger inserts a new record into the FactCurrencyRate_updateAudit table.

    updateDate: new column will have date and time when update was executed.
*/

USE AdventureWorksDW2022;
GO
CREATE TRIGGER trg_Track_After_Update_FactCurrencyRate
ON [FactCurrencyRate]
AFTER UPDATE
AS
    INSERT INTO FactCurrencyRate_updateAudit
    (
    CurrencyKey, DateKey, AverageRate, EndOfDayRate, Date, updateDate
    )
SELECT CurrencyKey, DateKey, AverageRate, EndOfDayRate, Date, GETDATE()
FROM DELETED
GO

-- Get the list of triggers 
SELECT TOP(2) *
FROM sys.triggers
ORDER BY modify_date desc;


------------------------------------------------------------

-- Update the EndOfDayRate column values in FactCurrencyRate table

USE AdventureWorksDW2022;
GO
UPDATE FactCurrencyRate
SET EndOfDayRate = 0.998000399912
WHERE CurrencyKey = 3
    AND DateKey = 20101229
GO

-- Check the FactCurrencyRate_updateAudit for new data if Trigger worked.

SELECT * FROM FactCurrencyRate_updateAudit;

/*
results:--
CurrencyKey	DateKey	AverageRate	EndOfDayRate	Date	updateDate
3	20101229	1	0.998000399912	2010-12-29 00:00:00.000	2024-03-30 16:02:05.953

*/

/*
conclusion:--
        Trigger trg_Track_After_Update_FactCurrencyRate is working.
*/


------------------------------------------------------------

-- Drop the trigger trg_Table_Safety.
USE AdventureWorksDW2022;
GO
DROP TRIGGER trg_Track_After_Update_FactCurrencyRate;
GO

-- Get the list of triggers 
SELECT *
FROM sys.triggers;


-- Drop the table FactCurrencyRate_updateAudit.
USE AdventureWorksDW2022;
GO
DROP TABLE FactCurrencyRate_updateAudit;
GO




/**************************************************************
  OBJECTIVE 02:
  Analyze DML trigger (AFTER UPDATE) 
**************************************************************/

------------------------------------------------------------

-- Transfer the data from FactCurrencyRate table to FactCurrencyRate_updateAudit table.

USE AdventureWorksDW2022;
GO
SELECT *
INTO FactCurrencyRate_updateAudit
FROM FactCurrencyRate
WHERE 1<>1
GO

SELECT *
FROM FactCurrencyRate_updateAudit

-- Add a new column updateDate in FactCurrencyRate_updateAudit

USE AdventureWorksDW2022;
GO
ALTER TABLE FactCurrencyRate_updateAudit
    ADD modifyDate DATETIME,
    oldEndOfDayRate DECIMAL(18,18), 
    newEndOfDayRate DECIMAL(18,18), EndOfDayRateDifference DECIMAL(18,18)
GO

SELECT *
FROM FactCurrencyRate_updateAudit



------------------------------------------------------------

-- Create a trigger on UPDATE statement

/*
logic:
    events: This trigger is fired AFTER UPDATE events on the FactCurrencyRate table. It means it activates when FactCurrencyRate table is updated.

    action: Upon an update to a row in the FactCurrencyRate table, the trigger inserts a new record into the FactCurrencyRate_updateAudit table.

    updateDate: new column will have date and time when update was executed.
*/

USE AdventureWorksDW2022;
GO
CREATE TRIGGER trg_Analyze_After_Update_FactCurrencyRate
ON [FactCurrencyRate]
AFTER UPDATE
AS
    BEGIN
    INSERT INTO FactCurrencyRate_updateAudit
    (
    CurrencyKey, DateKey, AverageRate, EndOfDayRate, Date, modifyDate, oldEndOfDayRate, newEndOfDayRate, EndOfDayRateDifference

    )
    SELECT i.CurrencyKey, i.DateKey, i.AverageRate, i.EndOfDayRate, i.Date,GETDATE(), d.EndOfDayRate as oldEndOfDayRate, i.EndOfDayRate as newEndOfDayRate, i.EndOfDayRate - d.EndOfDayRate as EndOfDayRateDifference
    FROM inserted i
    INNER JOIN deleted d
    ON i.CurrencyKey = d.CurrencyKey
    END 
GO


-- Get the list of triggers 
SELECT TOP(2) *
FROM sys.triggers
ORDER BY modify_date desc;


------------------------------------------------------------

-- Update the EndOfDayRate column values in FactCurrencyRate table

USE AdventureWorksDW2022;
GO
UPDATE FactCurrencyRate
SET EndOfDayRate = 0.998000399912
WHERE CurrencyKey = 3
    AND DateKey = 20101229
GO

-- Check the FactCurrencyRate_updateAudit for new data if Trigger worked.

SELECT * FROM FactCurrencyRate_updateAudit;

-- Check if Trigger tracks changes between old and new values after update.

USE AdventureWorksDW2022;
GO
UPDATE FactCurrencyRate
SET EndOfDayRate = 0.9980004000201
WHERE CurrencyKey = 3
    AND DateKey = 20101229
GO

/*
results:--

CurrencyKey	DateKey	AverageRate	EndOfDayRate	Date	modifyDate	oldEndOfDayRate	newEndOfDayRate	EndOfDayRateDifference
3	20101229	1	0.998000399912	2010-12-29 00:00:00.000	2024-03-30 16:36:11.223	0.998000399911999958	0.998000399911999958	0.000000000000000000
3	20101229	1	0.9980004000201	2010-12-29 00:00:00.000	2024-03-30 16:37:49.027	0.998000399911999958	0.998000400020100042	0.000000000108100084

*/

-- Get only EndDateDifference column that shows changes are being tracked.
SELECT CurrencyKey, EndOfDayRateDifference, modifyDate  FROM FactCurrencyRate_updateAudit;

/*
results:
CurrencyKey	  EndOfDayRateDifference	modifyDate
3	          0.000000000000000000	    2024-03-30 16:36:11.223
3	          0.000000000108100084	    2024-03-30 16:37:49.027

*/

/*
conclusion:--
        Trigger trg_Analyze_After_Update_FactCurrencyRate is working.
*/


------------------------------------------------------------

-- Drop the trigger trg_Table_Safety.
USE AdventureWorksDW2022;
GO
DROP TRIGGER trg_Analyze_After_Update_FactCurrencyRate;
GO

-- Get the list of triggers 
SELECT *
FROM sys.triggers;


-- Drop the table FactCurrencyRate_updateAudit.
USE AdventureWorksDW2022;
GO
DROP TABLE FactCurrencyRate_updateAudit;
GO


/**************************************************************
  OBJECTIVE 02:
  Analyze DML trigger (AFTER UPDATE) 
**************************************************************/

------------------------------------------------------------

-- Transfer data from FactCurrencyRate to FactCurrencyRate_insertUpdateAudit.

USE AdventureWorksDW2022;
GO
SELECT *
INTO FactCurrencyRate_insertUpdateAudit
FROM FactCurrencyRate
WHERE 1<>1;
GO

SELECT * FROM FactCurrencyRate_insertUpdateAudit;
GO

-- Add column modifyDate
USE AdventureWorksDW2022;
GO
ALTER TABLE FactCurrencyRate_insertUpdateAudit
    ADD modifyDate DATETIME;
GO

------------------------------------------------------------

-- Create trigger trg_Instead_of_Update_FactCurrencyRate

USE AdventureWorksDW2022;
GO

CREATE TRIGGER trg_Instead_of_Update_FactCurrencyRate
ON FactCurrencyRate
INSTEAD OF UPDATE
AS  
    DECLARE @trg_AverageRate FLOAT
    SELECT @trg_AverageRate = AverageRate FROM inserted
    
    IF (@trg_AverageRate < 0)
    BEGIN
        RAISERROR('Average Rate can not be negative, please check column.', 16, 1);
        ROLLBACK;
    END

    ELSE
    BEGIN
    INSERT INTO FactCurrencyRate_insertUpdateAudit
        (CurrencyKey, DateKey, AverageRate, EndOfDayRate, Date, modifyDate )
    SELECT CurrencyKey, DateKey, AverageRate, EndOfDayRate, Date, GETDATE() FROM deleted
    END
GO


-- Get all triggers

SELECT TOP(2) * FROM sys.triggers
ORDER BY modify_date desc;


------------------------------------------------------------

-- Update Average rate and set it to negative value to check trigger.

USE AdventureWorksDW2022;
GO

UPDATE FactCurrencyRate
SET AverageRate = -2
WHERE CurrencyKey = 3
AND DateKey = 20101229
GO

/*
results:--

Msg 50000, Level 16, State 1, Procedure trg_Instead_of_Update_FactCurrencyRate, Line 11
Average Rate can not be negative, please check column. 
	
	Msg 3609, Level 16, State 1, Line 4
The transaction ended in the trigger. The batch has been aborted.
*/

SELECT * FROM FactCurrencyRate_insertUpdateAudit;

/*
results:
no output
*/


-- Update Average rate and set it to positive value to check trigger.

USE AdventureWorksDW2022;
GO

UPDATE FactCurrencyRate
SET AverageRate = 2
WHERE CurrencyKey = 3
AND DateKey = 20101229
GO

SELECT * FROM FactCurrencyRate_insertUpdateAudit;

/*
results:
CurrencyKey	DateKey	AverageRate	EndOfDayRate	Date	modifyDate
3	20101229	1	0.9980004000201	2010-12-29 00:00:00.000	2024-03-30 17:57:32.677
*/



/**************************************************************
  OBJECTIVE 03:
  Demonstrate how to create a logon trigger using Transact-SQL statement
**************************************************************/



-- WARNING! I CREATED MESS-- I SHOULD NOT HAVE CREATED THIS TRIGGER.
-- I FAILED TO RESTORE BACK DATABASE AND LOG BACK IN.
-- THIS TRIGGER DID NOT ALLOW ME TO LOG BACK IN.
-- CREATING NEW INSTANCE OF DATABASE ENGINE FOR FURTHER LEARNING.






------------------------------------------------------------

-- Create a ServerLogonTracking table

USE AdventureWorksDW2022;
GO
CREATE TABLE trg_ServerLogon
(
    userlogin VARCHAR(512),
    SPID INT, 
    LogonTime DATETIME
)
GO
-- Create the logon trigger trg_ServerLogon

CREATE TRIGGER trg_Server_Logon_trigger
ON ALL SERVER FOR LOGON
AS
BEGIN
    DECLARE @trg_logon_count INT

    -- Check if there are existing rows for the current user on the current date
    SELECT @trg_logon_count = COUNT(1) 
    FROM AdventureWorksDW2022.dbo.trg_ServerLogon
    WHERE userlogin = SYSTEM_USER
    AND CAST(LogonTime AS DATE) = CAST(GETDATE() AS DATE)

    -- If there are fewer than 5 logon events, print a message
    IF (@trg_logon_count IS NULL OR @trg_logon_count < 5)
    BEGIN
        PRINT 'You have not exceeded the maximum logon limit today.';
    END
    ELSE
    BEGIN
        -- If there are 5 or more logon events, insert a new row
        INSERT INTO AdventureWorksDW2022.dbo.trg_ServerLogon
        VALUES (SYSTEM_USER, @@SPID, GETDATE());
    END
END
GO
--
/*
results:
TITLE: Connect to Server
------------------------------

Cannot connect to CA-L145S2M3\SQLEXPRESS.

------------------------------
ADDITIONAL INFORMATION:

Logon failed for login 'GROUPINFRA\manish.shivale' due to trigger execution.
Changed database context to 'master'.
Changed language setting to us_english. (Microsoft SQL Server, Error: 17892)

For help, click: https://docs.microsoft.com/sql/relational-databases/errors-events/mssqlserver-17892-database-engine-error

------------------------------
BUTTONS:

OK
------------------------------
*/
select * from sys.triggers;

-- Display all records from ServerLogonTracking table



