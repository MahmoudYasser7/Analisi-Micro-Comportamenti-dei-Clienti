USE Analisi;
GO

BULK INSERT dbo.[bronze bookings]
FROM './data/Bookings.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\r\n',
    TABLOCK,
    ERRORFILE = './data/Bookings_error.log'
);
GO

BULK INSERT dbo.[bronze customersup]
FROM './data/Customersup.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\r\n',
    TABLOCK,
    ERRORFILE = './data/Customersup_error.log'
);
GO

BULK INSERT dbo.[bronze ancillaries]
FROM './data/Ancillaries.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\r\n',
    TABLOCK,
    ERRORFILE = './data/Ancillaries_error.log'
);
GO
