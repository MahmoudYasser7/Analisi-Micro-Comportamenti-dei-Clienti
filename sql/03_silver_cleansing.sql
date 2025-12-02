USE Analisi;
GO

    
IF OBJECT_ID('dbo.[silver customersup]', 'U') IS NOT NULL
    DROP TABLE dbo.[silver customersup];
GO

CREATE TABLE dbo.[silver customersup] (
    [user id] BIGINT,
    [country] VARCHAR(100),
    [registration date] DATE,
    [age] INT,
    [gender] VARCHAR(10)
);
GO

WITH Clean AS (
    SELECT
        TRY_CAST([user id] AS BIGINT)                 AS [user id],
        NULLIF(UPPER(TRIM([country])), '')            AS [country],
        TRY_CAST([registration date] AS DATE)         AS [registration date],

        CASE 
            WHEN TRY_CAST([age] AS INT) BETWEEN 0 AND 120
                THEN TRY_CAST([age] AS INT)
            ELSE NULL
        END                                           AS [age],

        CASE
            WHEN LOWER([gender]) IN ('m','male') THEN 'M'
            WHEN LOWER([gender]) IN ('f','female') THEN 'F'
            ELSE 'OTHER'
        END                                           AS [gender]
    FROM dbo.[bronze customersup]
)
INSERT INTO dbo.[silver customersup]
SELECT *
FROM Clean
WHERE [user id] IS NOT NULL;
GO


    
IF OBJECT_ID('dbo.[silver bookings]', 'U') IS NOT NULL
    DROP TABLE dbo.[silver bookings];
GO

CREATE TABLE dbo.[silver bookings] (
    [booking id] BIGINT,
    [user id] BIGINT,
    [booking date] DATE,
    [destination] VARCHAR(200),
    [nights] INT,
    [price total] DECIMAL(10,2),
    [channel] VARCHAR(50),
    [currency] VARCHAR(10)
);
GO

WITH Clean AS (
    SELECT
        TRY_CAST([booking id] AS BIGINT)             AS [booking id],
        TRY_CAST([user id] AS BIGINT)                AS [user id],
        TRY_CAST([booking date] AS DATE)             AS [booking date],

        NULLIF(UPPER(TRIM([destination])), '')       AS [destination],

        CASE 
            WHEN TRY_CAST([nights] AS INT) >= 0 THEN TRY_CAST([nights] AS INT)
            ELSE NULL
        END                                           AS [nights],

        CASE 
            WHEN TRY_CAST([price total] AS DECIMAL(10,2)) >= 0 
                THEN TRY_CAST([price total] AS DECIMAL(10,2))
            ELSE NULL
        END                                           AS [price total],

        NULLIF(UPPER(TRIM([channel])), '')           AS [channel],
        NULLIF(UPPER(TRIM([currency])), '')          AS [currency]
    FROM dbo.[bronze bookings]
)
INSERT INTO dbo.[silver bookings]
SELECT *
FROM Clean
WHERE [booking id] IS NOT NULL;
GO



IF OBJECT_ID('dbo.[silver ancillaries]', 'U') IS NOT NULL
    DROP TABLE dbo.[silver ancillaries];
GO

CREATE TABLE dbo.[silver ancillaries] (
    [ancillary id] BIGINT,
    [booking id] BIGINT,
    [product type] VARCHAR(200),
    [price] DECIMAL(10,2),
    [sold date] DATE
);
GO

WITH Clean AS (
    SELECT
        TRY_CAST([ancillary id] AS BIGINT)           AS [ancillary id],
        TRY_CAST([booking id] AS BIGINT)             AS [booking id],

        NULLIF(UPPER(TRIM([product type])), '')      AS [product type],

        CASE 
            WHEN TRY_CAST([price] AS DECIMAL(10,2)) >= 0
                THEN TRY_CAST([price] AS DECIMAL(10,2))
            ELSE NULL
        END                                           AS [price],

        TRY_CAST([sold date] AS DATE)                 AS [sold date]
    FROM dbo.[bronze ancillaries]
)
INSERT INTO dbo.[silver ancillaries]
SELECT *
FROM Clean
WHERE [ancillary id] IS NOT NULL;
GO
