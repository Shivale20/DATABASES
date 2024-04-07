# OBJECTIVE 02:

## ** Demonstrate how to bulk import data in a table with check constraint on a column by specifying IGNORE CONSTRAINT**


- When using BULK INSERT, constraints such as check constraints are not evaluated row by row during the insertion process. Instead, the entire data set is loaded into the table in a single operation. 
- enforcing constraint check row by row will lead to performance issue and might fail entire insertion process.

**Solution**

- Create temporary staging table where we did bulk insertion without constraint check.
- Do the data cleaning in this staging table
- Move the cleaned data to final destination table with constraint enforced.