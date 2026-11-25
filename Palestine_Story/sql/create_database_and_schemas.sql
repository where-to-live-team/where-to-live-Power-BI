USE master;
GO
IF DB_ID('PalestineStory') IS NULL CREATE DATABASE PalestineStory;
GO
USE PalestineStory;
GO
IF SCHEMA_ID('dim')  IS NULL EXEC('CREATE SCHEMA dim');
IF SCHEMA_ID('fact') IS NULL EXEC('CREATE SCHEMA fact');
IF SCHEMA_ID('ml')   IS NULL EXEC('CREATE SCHEMA ml');
GO