/**************************************************************
  OBJECTIVE 01:
  Demonstrate how to 
**************************************************************/

------------------------------------------------------------

-- Heading 1

/*
result:
Table shows col1 and col2 only
*/

-- Heading 2

/*
result:
Table shows col1 and col2 only
*/

/*
conclusion:--
        Table was not altered and trigger worked.
*/

------------------------------------------------------------

-- Display a list of values from a column as a single string 
USE AW2022;
GO 

SELECT STUFF(
              (SELECT ', ' + Name
               FROM HumanResources.Department 
               FOR XML PATH ('')),
              1,
              1,
              '')
        AS DepartmentList


/*
DepartmentList
 Document Control, Engineering, Executive, Facilities and Maintenance, Finance, Human Resources, Information Services, Marketing, Production, Production Control, Purchasing, Quality Assurance, Research and Development, Sales, Shipping and Receiving, Tool Design
*/
