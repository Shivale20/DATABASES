# DATABASES
Repo for the Databases courses along with its project files.

## Usage

### Folder Structure

Below is the folder structure of the current project:

- [DATABASES](/DATABASES)

  - [DB01_Microsoft_SQL_Server_2022](./DB01_Microsoft_SQL_Server_2022)

    - [SQL_01_Designing_a_Relational_Database_Schema](./DB01_Microsoft_SQL_Server_2022/SQL_01_Designing_a_Relational_Database_Schema)

    - [SQL_02_Creating_Indexes](./DB01_Microsoft_SQL_Server_2022/SQL_02_Creating_Indexes)

    - [SQL_03_Best_Practices_in_Index_Creation](./DB01_Microsoft_SQL_Server_2022/SQL_03_Best_Practices_in_Index_Creation)

    - [SQL_04_Creating_Columnstore_Indexes](./DB01_Microsoft_SQL_Server_2022/SQL_04_Creating_Columnstore_Indexes)

    - [SQL_05_Maintaining_Columnstore_Indexes](./DB01_Microsoft_SQL_Server_2022/SQL_05_Maintaining_Columnstore_Indexes)

    - [SQL_06_Creating_Constraints](./DB01_Microsoft_SQL_Server_2022/SQL_06_Creating_Constraints)

    - [SQL_07_Effects_of_constraint](./DB01_Microsoft_SQL_Server_2022/SQL_07_Effects_of_constraint)

    - [SQL_08_Creating_Stored_Procedures](./DB01_Microsoft_SQL_Server_2022/SQL_08_Creating_Stored_Procedures)

    - [SQL_09_Creating_Triggers](./DB01_Microsoft_SQL_Server_2022/SQL_09_Creating_Triggers)

    - [SQL_10_Creating_Functions](./DB01_Microsoft_SQL_Server_2022/SQL_10_Creating_Functions)

    - [SQL_11_Working_With_Hierarchies](./DB01_Microsoft_SQL_Server_2022/SQL_11_Working_With_Hierarchies)

    - [SQL_12_Windowing_And_Ranking](./DB01_Microsoft_SQL_Server_2022/SQL_12_Windowing_And_Ranking)

    - [SQL_13_Analyze_Schema_With_Queries](./DB01_Microsoft_SQL_Server_2022/SQL_13_Analyze_Schema_With_Queries)

      - [Schema0](./DB01_Microsoft_SQL_Server_2022/SQL_13_Analyze_Schema_With_Queries/Schema0)

      - [Schema1_HumanResources](./DB01_Microsoft_SQL_Server_2022/SQL_13_Analyze_Schema_With_Queries/Schema1_HumanResources)

    - [SQL_14_DataTypes](./DB01_Microsoft_SQL_Server_2022/SQL_14_DataTypes)

  - [DB02_SQL_Server_Analysis_Services_2022](./DB02_SQL_Server_Analysis_Services_2022)



## Database Source

The data used in this project is sourced from the AdventureWorks database, which is a sample database provided by Microsoft for learning and demonstration purposes. 

The AdventureWorks database contains a wide range of tables representing various aspects of a fictional company's operations, including sales, products, employees, and customers.

## Data Source Link

You can download the AdventureWorks database from the official Microsoft documentation for your scenario. [here](https://learn.microsoft.com/en-us/sql/samples/adventureworks-install-configure?view=sql-server-ver16&tabs=ssms).

## Restore to SQL Server

Before you can start working with the sample database, you'll need to restore it to your SQL Server instance. Follow these steps:

1. Download the .bak file provided.
2. Move the .bak file to the following directory: `C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\Backup`
3. Open SQL Server Management Studio (SSMS).
4. Connect to your SQL Server instance.
5. Right-click on Databases in Object Explorer.
6. Select Restore Database...
7. Choose Device and then select the .bak file.
8. Click OK to restore the database.


## Tools Used

- [Visual Studio Code](https://code.visualstudio.com/)

- [SQL Server 2022](https://www.microsoft.com/en-us/sql-server/sql-server-downloads)

- [SQL Server Management Studio](https://docs.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms)

