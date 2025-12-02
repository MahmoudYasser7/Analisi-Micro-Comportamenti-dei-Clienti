USE Analisi;
GO

IF OBJECT_ID('dbo.[bronze customersup]', 'U') IS NOT NULL
    DROP TABLE dbo.[bronze customersup];
GO

CREATE TABLE dbo.[bronze customersup] (
    [user id] BIGINT NULL,
    [country] VARCHAR(50) NULL,
    [registration date] DATETIME NULL,
    [age] INT NULL,
    [gender] VARCHAR(10) NULL
);
GO


IF OBJECT_ID('dbo.[bronze bookings]', 'U') IS NOT NULL
    DROP TABLE dbo.[bronze bookings];
GO

CREATE TABLE dbo.[bronze bookings] (
    [booking id] BIGINT NULL,
    [user id] BIGINT NULL,
    [booking date] DATETIME NULL,
    [destination] VARCHAR(100) NULL,
    [nights] INT NULL,
    [price total] DECIMAL(10,2) NULL,
    [channel] VARCHAR(50) NULL,
    [currency] VARCHAR(10) NULL
);
GO


IF OBJECT_ID('dbo.[bronze ancillaries]', 'U') IS NOT NULL
    DROP TABLE dbo.[bronze ancillaries];
GO

CREATE TABLE dbo.[bronze ancillaries] (
    [ancillary id] BIGINT NULL,
    [booking id] BIGINT NULL,
    [product type] VARCHAR(50) NULL,
    [price] DECIMAL(10,2) NULL,
    [sold date] DATETIME NULL
);
GO
