USE Analisi;
GO

IF OBJECT_ID('dbo.[gold base]', 'U') IS NOT NULL
    DROP TABLE dbo.[gold base];
GO

CREATE TABLE dbo.[gold base] (
    [user id] BIGINT,
    [country] VARCHAR(100),
    [registration date] DATE,
    [age] INT,
    [gender] VARCHAR(10),

    [booking id] BIGINT,
    [booking date] DATE,
    [destination] VARCHAR(200),
    [nights] INT,
    [booking revenue] DECIMAL(10,2),
    [channel] VARCHAR(50),
    [currency] VARCHAR(10),

    [ancillary revenue] DECIMAL(10,2),
    [first ancillary date] DATE,
    [last ancillary date] DATE
);
GO

INSERT INTO dbo.[gold base] (
    [user id],
    [country],
    [registration date],
    [age],
    [gender],
    [booking id],
    [booking date],
    [destination],
    [nights],
    [booking revenue],
    [channel],
    [currency],
    [ancillary revenue],
    [first ancillary date],
    [last ancillary date]
)
SELECT
    c.[user id]                   AS [user id],
    c.[country]                   AS [country],
    c.[registration date]         AS [registration date],
    c.[age]                       AS [age],
    c.[gender]                    AS [gender],

    b.[booking id]                AS [booking id],
    b.[booking date]              AS [booking date],
    b.[destination]               AS [destination],
    b.[nights]                    AS [nights],
    b.[price total]               AS [booking revenue],
    b.[channel]                   AS [channel],
    b.[currency]                  AS [currency],

    a.[ancillary revenue]         AS [ancillary revenue],
    a.[first sold date]           AS [first ancillary date],
    a.[last sold date]            AS [last ancillary date]
FROM dbo.[silver bookings] b
LEFT JOIN dbo.[silver customersup] c
    ON b.[user id] = c.[user id]
LEFT JOIN (
    SELECT
        [booking id],
        SUM([price])            AS [ancillary revenue],
        MIN([sold date])        AS [first sold date],
        MAX([sold date])        AS [last sold date]
    FROM dbo.[silver ancillaries]
    GROUP BY [booking id]
) a
    ON b.[booking id] = a.[booking id];
GO
