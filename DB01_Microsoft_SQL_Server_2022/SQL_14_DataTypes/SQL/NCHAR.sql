DROP TABLE IF EXISTS #Employee
-- Create the Employee table
CREATE TABLE #Employee (
    Name_Char CHAR(10),
    Name_NChar NCHAR(10)
);

-- Insert data into the table
INSERT INTO #Employee (Name_Char, Name_NChar)
VALUES
    ('John', N'John'),  -- Using 'John' for CHAR and N'John' for NCHAR
    ('Élise', N'Élise');  -- Using 'Élise' for CHAR and N'Élise' for NCHAR

-- Display the hexadecimal representation and byte length of each value
SELECT 
    Name_Char,
    CONVERT(VARBINARY(20), Name_Char) AS Name_Char_Hex,
    LEN(CONVERT(VARBINARY(20), Name_Char)) / 2 AS Name_Char_Bytes,
    Name_NChar,
    CONVERT(VARBINARY(20), Name_NChar) AS Name_NChar_Hex,
    LEN(CONVERT(VARBINARY(20), Name_NChar)) / 2 AS Name_NChar_Bytes
    
FROM #Employee;



