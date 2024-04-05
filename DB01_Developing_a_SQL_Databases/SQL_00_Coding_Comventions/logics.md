# How to solve SQL problems?

**Clarify the output client is seeking**

- Consider asking following questions:

    ## Column Names
    What are the columns name that should appear in the output table?

    ## Data format
    What format should the data be in each column such as text, date, numeric etc?

    ## Column Order
    In what order the columns should appear in the table?

    ## Sorting
    Should the table be sorted in particular way?

    ## Additonal columns
    Are there any additional columns or information that should be included in the output table?

    ## Grouping or aggregation
    Should the table display aggregated or grouped data?

    ## Naming conventions
    Are there any specific naming conventions or standards to follow for column names or table structure?

    ## Filter or Conditions
    Should the output table only include data that meets certain criteria or conditions?

    ## Visual presentations
    Is there a prefered visual presentation or styling for the output table? 

    ## Delivery format
    In what format should the output table be delivered (e.g Excel, CSV, database table)?



# SQL Naming Conventions

## Stored Procedures:
- *Retrieving Data*: `usp_GetEntityByCriteria`
- *Inserting Data*: `usp_InsertEntity`
- *Updating Data*: `usp_UpdateEntity`
- *Deleting Data*: `usp_DeleteEntity`
- *Executing Specific Action*: `usp_DoSomething`

## Functions:
- *Scalar Functions*: `udf_GetSomething`
- *Table-Valued Functions*: `udf_GetSomethingTable`

## Views:
- `vw_EntityName`

## Tables:
- *Regular Tables*: `TableName`
- *Lookup Tables*: `Lookup_TableName`

## Columns:
- *Primary Key*: `TableNameID`
- *Foreign Key*: `RelatedTableNameID`
- *Date Columns*: `DateColumnName`
- *Boolean Columns*: `IsSomething`

## Indexes:
- *Non-Clustered Indexes*: `IX_TableName_ColumnName`
- *Unique Indexes*: `UX_TableName_ColumnName`

## Constraints:
- *Primary Key Constraints*: `PK_TableName`
- *Foreign Key Constraints*: `FK_TableName_ColumnName`
- *Unique Constraints*: `UK_TableName_ColumnName`

## Triggers:
- `trg_EntityName_Action`

## Temporary Tables:
- `#TempTableName`

## Database Objects:
- *Schemas*: `SchemaName`
- *Database Roles*: `RoleName`
- *Users*: `UserName`


## Task Description Template

### Action:
[Describe the action or task to be performed in a concise sentence.]

### Data:
- **Database:** [Name of the database]
- **Table:** [Name of the table]
- **Columns:** [List of columns involved]
- **Filter:** [Any specific filter or condition]

### Requirements:
1. [Requirement 1]
2. [Requirement 2]
3. [Requirement 3]
   - [Additional details, if needed]

### Notes:
- [Any additional notes or considerations regarding the task]
- [Optional: Provide examples, queries, or code snippets related to the task]

