-- Create a new database
CREATE DATABASE SampleDB;
GO

-- Switch to the new database
USE SampleDB;
GO

-- Create a sample table
CREATE TABLE Users (
    Id INT PRIMARY KEY IDENTITY,
    Name NVARCHAR(50),
    Email NVARCHAR(100)
);
GO

-- Insert a sample record
INSERT INTO Users (Name, Email) VALUES ('John Doe', 'john.doe@example.com');
GO
