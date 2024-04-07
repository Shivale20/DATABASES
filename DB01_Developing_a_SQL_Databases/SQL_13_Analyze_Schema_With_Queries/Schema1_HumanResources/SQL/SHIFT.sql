-- SHIFT DISTRIBUTION ANALYSIS

USE AW2022;
GO

-- Retrieve different shifts for workforce.
SELECT *
FROM HumanResources.Shift;
GO


-- Employee count per shift

SELECT s.Name AS ShiftName, COUNT(e.BusinessEntityID) AS EmployeeCount
FROM HumanResources.EmployeeDepartmentHistory e
    INNER JOIN HumanResources.Shift s
    ON s.ShiftID = e.ShiftID
GROUP BY s.Name
GO


-- Staff distribution across departments and shift schedules

    -- The "ProportionPerShift" column offers insights into the proportion of employees working during each shift relative to the total number of employees assigned to that shift

SELECT s.Name AS ShiftName, COUNT(e.BusinessEntityID) AS EmployeeCount
INTO #TotalEmployeesPerShift
FROM HumanResources.EmployeeDepartmentHistory e
    INNER JOIN HumanResources.Shift s
    ON s.ShiftID = e.ShiftID
GROUP BY s.Name
GO

SELECT
    d.Name as DepartmentName,
    s.Name as ShiftName,
    COUNT(e.BusinessEntityID) AS EmployeeCount,
    FORMAT((COUNT(BusinessEntityID) *100.0/t.EmployeeCount),'N2') 
    + '% out of ' 
    + CAST(t.EmployeeCount AS varchar(10)) 
    + ' during ' 
    + s.Name
    AS ProportionPerShift
FROM HumanResources.EmployeeDepartmentHistory e
    INNER JOIN HumanResources.Department d
    ON d.DepartmentID = e.DepartmentID
    INNER JOIN HumanResources.Shift s
    ON e.ShiftID = s.ShiftID
    INNER JOIN #TotalEmployeesPerShift t
    ON t.ShiftName = s.Name
GROUP BY d.Name, s.Name, t.EmployeeCount
ORDER BY EmployeeCount DESC
GO

DROP TABLE IF EXISTS #TotalEmployeesPerShift;
GO



-- Shift-Based Pay Disparities
DROP TABLE IF EXISTS #PayDisparityByShift;
GO

-- Create a temporary table to store shift-based pay disparities

SELECT 
        edh.BusinessEntityID,
        e.OrganizationLevel,
        e.JobTitle,
        e.Gender ,
        s.Name as ShiftName, 
        eph.Rate, 
        eph.PayFrequency
INTO #PayDisparityByShift
FROM HumanResources.EmployeePayHistory eph
INNER JOIN HumanResources.EmployeeDepartmentHistory edh
ON edh.BusinessEntityID = eph.BusinessEntityID
INNER JOIN HumanResources.Employee e 
ON e.BusinessEntityID = eph.BusinessEntityID
INNER JOIN HumanResources.Shift s 
ON s.ShiftID = edh.ShiftID

-- Retrieve all data from #PayDisparityByShift
SELECT *
FROM #PayDisparityByShift
ORDER BY OrganizationLevel;
go


-- Shift Distribution by Gender

SELECT ShiftName, Gender ,COUNT(*) AS EmployeeCount
FROM #PayDisparityByShift
GROUP BY ShiftName, Gender;
GO

-- Query to calculate average pay rate disparities for employees with organization level 4

SELECT 
    ShiftName, 
    Gender, 
    COUNT(*) AS EmployeeCount,
    AVG(Rate) as AvgPayRateOrgLevel4,
    
    CAST(COUNT(*) AS varchar) + ' '+ Gender + ' at organization level 4' +' are working during ' + ShiftName + ' shift schedule at average pay rate of ' + CAST(AVG(Rate) AS varchar)
    AS Remark

FROM #PayDisparityByShift 
WHERE OrganizationLevel = 4
GROUP BY ShiftName, Gender
GO 

DROP TABLE IF EXISTS #PayDisparityByShift;
GO

-- 