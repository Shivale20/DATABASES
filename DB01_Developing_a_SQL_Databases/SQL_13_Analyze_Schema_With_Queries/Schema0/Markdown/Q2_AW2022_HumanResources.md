# TABLE: SHIFT

```json
  {
    "TABLE_NAME": "Shift",
    "COLUMN_NAMES": "ShiftID, 
                    Name, 
                    StartTime, 
                    EndTime, 
                    ModifiedDate"
  }
```

# TABLE: DEPARTMENT

```json
  {
    "TABLE_NAME": "Department",
    "COLUMN_NAMES": " DepartmentID, Name, GroupName, ModifiedDate"
  }
```
# TABLE: EMPLOYEE

```json
  {
    "TABLE_NAME": "Employee",
    "COLUMN_NAMES": " BusinessEntityID, NationalIDNumber, LoginID, OrganizationNode, OrganizationLevel, JobTitle, BirthDate, MaritalStatus, Gender, HireDate, SalariedFlag, VacationHours, SickLeaveHours, CurrentFlag, rowguid, ModifiedDate"
  }
```

# TABLE: EMPLOYEE DEPARTMENT HISTORY

```json
  {
    "TABLE_NAME": "EmployeeDepartmentHistory",
    "COLUMN_NAMES": " BusinessEntityID, DepartmentID, ShiftID, StartDate, EndDate, ModifiedDate"
  }
```

# TABLE: EMPLOYEE PAY HISTORY

```json
  {
    "TABLE_NAME": "EmployeePayHistory",
    "COLUMN_NAMES": " BusinessEntityID, RateChangeDate, Rate, PayFrequency, ModifiedDate"
  }
```

# TABLE: JOB CANDIDATE

```json
  {
    "TABLE_NAME": "JobCandidate",
    "COLUMN_NAMES": " JobCandidateID, BusinessEntityID, Resume, ModifiedDate"
  }
```

### Insights from Human Resources Tables

#### Table: Shift
- **Shift Patterns Analysis**:
  - Analyze the distribution of shifts (Day, Evening, Night).
  - Identify peak times and durations for different shifts.
- **Shift Management**:
  - Monitor shift start and end times for adherence to schedules.
  - Track modifications to shift details for auditing purposes.

#### Table: Department
- **Department Performance**:
  - Evaluate the performance of different departments based on their activities.
  - Analyze departmental trends over time.
- **Department Structure**:
  - Understand the organizational hierarchy by examining department groupings.
  - Track modifications to departmental details for organizational changes.

#### Table: Employee
- **Employee Demographics**:
  - Analyze the demographics of the workforce (gender distribution, marital status).
  - Track employee tenure and hiring trends based on hire dates.
- **Workforce Management**:
  - Monitor employee job titles, organizational levels, and roles.
  - Track employee leave balances (vacation hours, sick leave hours) for resource planning.

#### Table: Employee Department History
- **Employee Deployment Analysis**:
  - Track the movement of employees across different departments over time.
  - Analyze historical staffing patterns for resource allocation optimization.
- **Shift Assignment**:
  - Associate employees with specific shifts to ensure proper scheduling.
  - Track changes in shift assignments over time.

#### Table: Employee Pay History
- **Payroll Analysis**:
  - Analyze changes in employee pay rates over time.
  - Track pay frequency and identify trends in compensation adjustments.
- **Financial Planning**:
  - Estimate future payroll expenses based on historical pay rate changes.
  - Analyze the impact of pay rate adjustments on employee retention.

#### Table: Job Candidate
- **Recruitment Insights**:
  - Track candidate applications and recruitment efforts.
  - Analyze candidate qualifications and resume details for hiring decisions.
- **Talent Pipeline Management**:
  - Monitor the flow of candidates through the recruitment process.
  - Analyze modifications to candidate profiles and recruitment strategies.
