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
        TRY_CAST([user id] AS BIGINT) AS [user id],
        NULLIF(UPPER(TRIM([country])), '') AS [country],
        TRY_CAST([registration date] AS DATE) AS [registration date],
        CASE WHEN TRY_CAST([age] AS INT) BETWEEN 0 AND 120 THEN TRY_CAST([age] AS INT) ELSE NULL END AS [age],
        CASE
            WHEN LOWER([gender]) IN ('m','male') THEN 'M'
            WHEN LOWER([gender]) IN ('f','female') THEN 'F'
            ELSE 'OTHER'
        END AS [gender],
        ROW_NUMBER() OVER(
            PARTITION BY TRY_CAST([user id] AS BIGINT)
            ORDER BY TRY_CAST([registration date] AS DATE) DESC
        ) AS rn
    FROM dbo.[bronze customersup]
    WHERE TRY_CAST([user id] AS BIGINT) IS NOT NULL
)
INSERT INTO dbo.[silver customersup]
SELECT [user id], [country], [registration date], [age], [gender]
FROM Clean
WHERE rn = 1;
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
        TRY_CAST([booking id] AS BIGINT) AS [booking id],
        TRY_CAST([user id] AS BIGINT) AS [user id],
        TRY_CAST([booking date] AS DATE) AS [booking date],
        NULLIF(UPPER(TRIM([destination])), '') AS [destination],
        CASE WHEN TRY_CAST([nights] AS INT) >= 0 THEN TRY_CAST([nights] AS INT) ELSE NULL END AS [nights],
        CASE WHEN TRY_CAST([price total] AS DECIMAL(10,2)) >= 0 THEN TRY_CAST([price total] AS DECIMAL(10,2)) ELSE NULL END AS [price total],
        NULLIF(UPPER(TRIM([channel])), '') AS [channel],
        NULLIF(UPPER(TRIM([currency])), '') AS [currency],
        ROW_NUMBER() OVER(
            PARTITION BY TRY_CAST([booking id] AS BIGINT)
            ORDER BY TRY_CAST([booking date] AS DATE) DESC
        ) AS rn
    FROM dbo.[bronze bookings]
    WHERE TRY_CAST([booking id] AS BIGINT) IS NOT NULL
)
INSERT INTO dbo.[silver bookings]
SELECT b.[booking id], b.[user id], b.[booking date], b.[destination],
       b.[nights], b.[price total], b.[channel], b.[currency]
FROM Clean b
INNER JOIN dbo.[silver customersup] c
    ON b.[user id] = c.[user id]
WHERE rn = 1;
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
        TRY_CAST([ancillary id] AS BIGINT) AS [ancillary id],
        TRY_CAST([booking id] AS BIGINT) AS [booking id],
        NULLIF(UPPER(TRIM([product type])), '') AS [product type],
        CASE WHEN TRY_CAST([price] AS DECIMAL(10,2)) >= 0 THEN TRY_CAST([price] AS DECIMAL(10,2)) ELSE NULL END AS [price],
        TRY_CAST([sold date] AS DATE) AS [sold date],
        ROW_NUMBER() OVER(
            PARTITION BY TRY_CAST([ancillary id] AS BIGINT)
            ORDER BY TRY_CAST([sold date] AS DATE) DESC
        ) AS rn
    FROM dbo.[bronze ancillaries]
    WHERE TRY_CAST([ancillary id] AS BIGINT) IS NOT NULL
)
INSERT INTO dbo.[silver ancillaries]
SELECT a.[ancillary id], a.[booking id], a.[product type],
       a.[price], a.[sold date]
FROM Clean a
INNER JOIN dbo.[silver bookings] b
    ON a.[booking id] = b.[booking id]
WHERE rn = 1;
GO
