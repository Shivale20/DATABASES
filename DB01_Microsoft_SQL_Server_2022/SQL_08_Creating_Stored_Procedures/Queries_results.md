# OBJECTIVE 01:

## **How to create stored procedures**

### Use of set "NOCOUNT ON"
- SQL server stops sending the "n rows affected" message to the client.
- This is useful when you have multiple stored procedures or loops that involve multiple SQL st.
- By default SET NOCOUNT OFF that is why we get n rows affected after every sql execution.

### Declare variable for input and output parameters in stored procedures.

**Input Parameters**
- input parameters are used to pass values into the sp.

```sql
    CREATE PROCEDURE sp_1
        @p_InputParameter INT -- declare an input parameter
    AS
        BEGIN
            --your stored procedure logic here
            SELECT * FROM my_table WHERE my_column = @p_InputParameter
        END
```

**Output Parameters**
-- these are used to return values from the sp
```sql
    CREATE PROCEDURE sp_1
        @p_InputParameter INT,
        @p_OutputParameter INT OUTPUT --declare an output parameter
    AS
        BEGIN
            --your stored procedure logic here
            SET @p_OutputParameter = @p_InputParameter * 2
        END
```

**Call the sp with parameters**
```sql
    DECLARE @p_Input INT = 10;
    DECLARE @p_Output INT;

    EXECUTE sp_1 @p_InputParameter = @p_Input, @p_OutputParameter = @p_Output OUTPUT;

    -- Now @p_Output contains the value returned by the sp_1
    PRINT @p_Output
```

**Bulk data operations using table-valued parameter**
- Normally parameters are for passing single values, like a number or word.
- Table-valued parameter lets you pass a whole table of data as one parameter.
- ### How does it work?
    - Table Type: create a table type which defines the structure of the table you want to pass.
    - Passing the table: when you call sp, you create a table with the same structure as the table type. Then you fill the table with your data
    - Inside the sp: treat the table-valued parameter just like a regular table.
- ### Example

Let's say we have a sp that needs to work with a list of employee names and their IDs.
Instead of passing each name and ID separately, we can create a table type that defines
these columns - EmployeeID and EmployeeName.
Then we can pass a whole table of employee data to the sp using a table-valued parameter.

```sql
    CREATE TYPE EmployeeTable AS TABLE (
        EmployeeID INT, 
        EmployeeName NVARCHAR(100)
    );

    CREATE PROCEDURE sp_ProcessEmployees
        @Employees EmployeeTable READONLY
    AS 
        BEGIN
        -- work with @Employees like a regular table
        SELECT * FROM @Employees;
        END
```

**Create a stored procedure with RETURN CODE**

- sp can return an integer value that is called the return code.
- return code will determines the successful or unsuccessful execution status of procedure.
- return code must be stored in a variable- 0 as successful and nonzero as unsuccessful execution.
```sql
DECLARE @return_value INT
EXEC @return_value = sp_procedureName

SELECT @return_value
IF @return_value = 2
    BEGIN
    PRINT 'sp_procedureName executed successfully'
    END
ELSE
    BEGIN
    PRINT 'sp_procedureName not executed'
    END
```