------------------------------------------------------------

-- Check both tables and find foreign id that connects them.

USE AW2022;
GO

SELECT EMP.BusinessEntityID, EMP.OrganizationNode, EMP.OrganizationLevel
FROM HumanResources.Employee EMP;
GO

USE AW2022;
GO

SELECT P.BusinessEntityID, FullName = (P.FirstName + ' ' + P.LastName)
FROM Person.Person P;
GO

-- Convert OrganizationNode from Hex to Text data type 

USE AW2022;
GO

SELECT EMP.BusinessEntityID, HierarchyID =  EMP.OrganizationNode.ToString(), EMP.OrganizationLevel
FROM HumanResources.Employee EMP;
GO

-- HierarchyID : Materialized Path Pattern.

-- Get Employee Name for each HierarchyID

USE AW2022;
GO

SELECT EMP.BusinessEntityID, EMP.OrganizationNode, HierarchyID = EMP.OrganizationNode.ToString(),EMP.OrganizationLevel ,EMP.JobTitle ,FullName = (P.FirstName + ' ' + P.LastName)
FROM HumanResources.Employee EMP 
JOIN Person.Person P 
ON EMP.BusinessEntityID = P.BusinessEntityID;
GO

-- Create procedure to reuse above query results

USE AW2022;
GO

CREATE PROCEDURE HumanResources.uspGetHierarchyInformation
AS 
SELECT EMP.BusinessEntityID, EMP.OrganizationNode, HierarchyID = EMP.OrganizationNode.ToString(),EMP.OrganizationLevel ,EMP.JobTitle ,FullName = (P.FirstName + ' ' + P.LastName)
FROM HumanResources.Employee EMP 
JOIN Person.Person P 
ON EMP.BusinessEntityID = P.BusinessEntityID;
GO

/*
Since SQL Server does not allow direct execution of stored procedures within a SELECT statement like that, I'll need to use a different approach.
*/

-- Create a inline table-valued function
USE AW2022;
GO
CREATE FUNCTION HumanResources.ufnGetHierarchyInformation()
RETURNS TABLE 
AS 
RETURN (
    SELECT EMP.BusinessEntityID, EMP.OrganizationNode, HierarchyID = EMP.OrganizationNode.ToString(),EMP.OrganizationLevel ,EMP.JobTitle ,FullName = (P.FirstName + ' ' + P.LastName)
    FROM HumanResources.Employee EMP 
    JOIN Person.Person P 
    ON EMP.BusinessEntityID = P.BusinessEntityID
)
GO

-- Get Single Node where organization node = '/3/3/'
SELECT *
FROM HumanResources.ufnGetHierarchyInformation()
WHERE [HierarchyID] = '/3/3/';

-- No need to use HierarchyID, OrganizationNode will get same result.
SELECT BusinessEntityID, OrganizationLevel, FullName
FROM HumanResources.ufnGetHierarchyInformation()
WHERE OrganizationNode = '/3/3/';

-- Check if CEO is at top
SELECT JobTitle, FullName, [HierarchyID]
FROM HumanResources.ufnGetHierarchyInformation()
WHERE OrganizationLevel IS NULL;
------------------------------------------------------------

-- Searching for Ancestors


/*
Hierarchy Method: IsDecendantof()
IF NodeY.IsDescendantof(NodeX) == True:
    Then NodeX is ancestor of NodeY
    or NodeY: childHierarchyID
*/

-- Get list of Employees who are descendant of Organization Node = '/3/3/'

DECLARE @EmpNode HIERARCHYID
SELECT @EmpNode = OrganizationNode
FROM HumanResources.Employee
WHERE OrganizationNode = '/3/3/'

SELECT BusinessEntityID, FullName, [HierarchyID], JobTitle
FROM HumanResources.ufnGetHierarchyInformation()
WHERE @EmpNode.IsDescendantOf(OrganizationNode) = 1 AND @EmpNode != OrganizationNode
GO

/*
results:
BusinessEntityID	JobTitle	                    FullName
25	                Vice President of Production	James Hamilton

-- James Hamilton is the Manager to whom Employee at Organization Node = '/3/3/' reports.
*/

-- Create procedure to Get Direct Reporting Manager of each Employee
USE AW2022;
GO

CREATE FUNCTION HumanResources.ufnGetDirectReportingManagerForOrganizationNode(
    @OrganizationNode HIERARCHYID
)
RETURNS INT
AS 
BEGIN
    DECLARE @EmpNode HIERARCHYID
    SELECT @EmpNode= OrganizationNode 
    FROM HumanResources.Employee
    WHERE OrganizationNode = @OrganizationNode

    DECLARE @ManagerID INT;
    SELECT @ManagerID = BusinessEntityID
    FROM HumanResources.ufnGetHierarchyInformation()
    WHERE @EmpNode.IsDescendantOf(OrganizationNode) = 1 AND @EmpNode != OrganizationNode

    RETURN @ManagerID
END;
GO 

-- Get Employee and their Manager's BusinessEntityID
SELECT h.BusinessEntityID ,m.ManagerID
FROM HumanResources.Employee h 
OUTER APPLY 
(SELECT ManagerID = HumanResources.ufnGetDirectReportingManagerForOrganizationNode(h.OrganizationNode)) m 

-- Get Employee and Their Manager's Name sorted by their Hierarchy asc

SELECT EMP.FullName, m.ManagerID,d.FullName as ManagerName 
FROM HumanResources.ufnGetHierarchyInformation() EMP
OUTER APPLY ( 
    SELECT ManagerID = HumanResources.ufnGetDirectReportingManagerForOrganizationNode(EMP.OrganizationNode)
) m 
LEFT JOIN HumanResources.ufnGetHierarchyInformation() d 
ON m.ManagerID = d.BusinessEntityID;

/* above query is calling one function twice:  it is redudancy 
Use CTE to call function once and reuse its records.
*/

WITH
    EmployeeHierarchy
    AS
    (
        SELECT BusinessEntityID, FullName, OrganizationNode
        FROM HumanResources.ufnGetHierarchyInformation()
    )
SELECT EMP.FullName AS EmployeeName, MEMP.FullName AS ManagerName
FROM EmployeeHierarchy EMP
OUTER APPLY (
    SELECT ManagerID = HumanResources.ufnGetDirectReportingManagerForOrganizationNode(EMP.OrganizationNode)
) MGR
    LEFT JOIN EmployeeHierarchy MEMP
    ON MEMP.BusinessEntityID = MGR.ManagerID;


-- Convert above query into Procedure 
USE AW2022;
GO 

CREATE PROCEDURE HumanResources.uspGetManagersName
AS 
BEGIN 
    WITH
    EmployeeHierarchy
    AS
    (
        SELECT BusinessEntityID, FullName, OrganizationNode
        FROM HumanResources.ufnGetHierarchyInformation()
    )
SELECT EMP.FullName AS EmployeeName, MEMP.FullName AS ManagerName
FROM EmployeeHierarchy EMP
OUTER APPLY (
    SELECT ManagerID = HumanResources.ufnGetDirectReportingManagerForOrganizationNode(EMP.OrganizationNode)
) MGR
    LEFT JOIN EmployeeHierarchy MEMP
    ON MEMP.BusinessEntityID = MGR.ManagerID;
END;
GO

EXEC HumanResources.uspGetManagersName


------------------------------------------------------------

-- Method 2: GetAncestor(x) where x is level of hierarchy

-- Find the list of employees who are reports directly to given manager 

DECLARE @ManagerID HIERARCHYID, @ManagerName VARCHAR(128);

SELECT 
    @ManagerID = OrganizationNode, 
    @ManagerName = FullName
FROM 
    HumanResources.ufnGetHierarchyInformation()
WHERE 
    OrganizationNode = '/5/';

SELECT 
    @ManagerName AS ManagerName;

SELECT 
    [HierarchyID], 
    FullName, 
    OrganizationLevel, 
    JobTitle
FROM 
    HumanResources.ufnGetHierarchyInformation()
WHERE 
    OrganizationNode.GetAncestor(1) = @ManagerID;
GO 

-- Get Manager Span of Control
-- Find out Manager Info who has wider span of control.


WITH 
    EmployeeHierarchy
    AS (
        SELECT 
            BusinessEntityID, FullName, JobTitle, OrganizationNode
        FROM 
            HumanResources.ufnGetHierarchyInformation()
    )
SELECT 
    ManagerName = MGR.FullName, 
    DirectReportsCount = COUNT(Distinct EMP.BusinessEntityID)
FROM
    EmployeeHierarchy MGR 
LEFT JOIN 
    EmployeeHierarchy EMP 
ON 
    EMP.OrganizationNode.GetAncestor(1) = MGR.OrganizationNode
    
GROUP BY 
    MGR.FullName 
HAVING 
    COUNT(Distinct EMP.BusinessEntityID) != 0
ORDER BY 
    DirectReportsCount DESC;

-- Create Table-valued function for above query
USE AW2022;
GO 

CREATE FUNCTION HumanResources.ufnGetDirectReports()
RETURNS TABLE AS 
RETURN (
    
WITH 
    EmployeeHierarchy
    AS (
        SELECT 
            BusinessEntityID, FullName, JobTitle, OrganizationNode
        FROM 
            HumanResources.ufnGetHierarchyInformation()
    )
SELECT 
    ManagerName = MGR.FullName, 
    DirectReportsCount = COUNT(Distinct EMP.BusinessEntityID)
FROM
    EmployeeHierarchy MGR 
LEFT JOIN 
    EmployeeHierarchy EMP 
ON 
    EMP.OrganizationNode.GetAncestor(1) = MGR.OrganizationNode
    
GROUP BY 
    MGR.FullName 
HAVING 
    COUNT(Distinct EMP.BusinessEntityID) != 0
-- ORDER BY 
--     DirectReportsCount DESC

);
GO

-- Find which manager has widest span of control
SELECT TOP 1 ManagerName, DirectReportsCount
FROM HumanResources.ufnGetDirectReports()
ORDER BY DirectReportsCount DESC;


/* 
HOTS:
Since I am using OrganizationNode most frequently, 
we can create it as UNIQUE INDEX
Also, it would be base on depth first indexing approach
for functions such as Getting direct report counts 
as managers and their direct reports are stored near each
other.
*/

-- Create OrganizationNode as unique index
USE AW2022;
GO
CREATE UNIQUE INDEX OrgNode_Breath_First
ON HumanResources.Employee(OrganizationNode);
GO 

------------------------------------------------------------

-- Method 3: GetLevel()

-- Return the value of how many levels down each row is in the hierarchy.

USE AW2022;
GO 

SELECT 
    [HierarchyID],
    EmpLevel = OrganizationNode.GetLevel(),
    FullName,
    JobTitle
FROM HumanResources.ufnGetHierarchyInformation()
GO;

