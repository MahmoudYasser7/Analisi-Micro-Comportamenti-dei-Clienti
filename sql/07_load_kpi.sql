USE Analisi;
GO

IF OBJECT_ID('dbo.[gold kpi]', 'U') IS NOT NULL
    DROP TABLE dbo.[gold kpi];
GO

CREATE TABLE dbo.[gold kpi] (
    [KPI ID] INT,
    [KPI Name] VARCHAR(200),
    [KPI Description] VARCHAR(500),
    [SQL Query] NVARCHAR(MAX)
);
GO

ALTER TABLE dbo.[gold kpi]
ADD CONSTRAINT PK_gold_kpi PRIMARY KEY ([KPI ID]);
GO

INSERT INTO dbo.[gold kpi]
([KPI ID], [KPI Name], [KPI Description], [SQL Query])
VALUES

(1, 'Variazione Mensile del Fatturato', 'Variazione mese su mese del fatturato (booking + ancillari).',
N'WITH [Fatturato Mensile] AS (
    SELECT
        YEAR([booking date]) AS [Anno],
        MONTH([booking date]) AS [Mese],
        SUM([booking revenue] + ISNULL([ancillary revenue],0)) AS [Fatturato]
    FROM dbo.[gold base]
    GROUP BY YEAR([booking date]), MONTH([booking date])
)
SELECT
    [Anno],
    [Mese],
    [Fatturato],
    [Fatturato] - LAG([Fatturato]) OVER (ORDER BY [Anno], [Mese]) AS [Variazione Mensile]
FROM [Fatturato Mensile]
ORDER BY [Anno], [Mese];'),

(2, 'Fatturato per Canale', 'Fatturato totale suddiviso per canale (booking / ancillary / totale).',
N'SELECT
    [channel] AS [Canale di Vendita],
    SUM([booking revenue]) AS [Fatturato Ticket],
    SUM(ISNULL([ancillary revenue],0)) AS [Fatturato Ancillary],
    SUM([booking revenue] + ISNULL([ancillary revenue],0)) AS [Fatturato Totale]
FROM dbo.[gold base]
GROUP BY [channel]
ORDER BY [Fatturato Totale] DESC;'),

(3, 'Ricavo Medio per Destinazione', 'Ricavo medio (booking + ancillary) per destinazione.',
N'SELECT
    [destination] AS [Destinazione],
    AVG([booking revenue] + ISNULL([ancillary revenue],0)) AS [Ricavo Medio Destinazione]
FROM dbo.[gold base]
GROUP BY [destination]
ORDER BY [Ricavo Medio Destinazione] DESC;'),

(4, 'Utenti con più Prenotazioni', 'Numero prenotazioni per utente (ordinato discendente).',
N'SELECT
    [user id] AS [ID Cliente],
    COUNT(DISTINCT [booking id]) AS [Numero Prenotazioni]
FROM dbo.[gold base]
GROUP BY [user id]
ORDER BY [Numero Prenotazioni] DESC;'),

(5, 'Ricavo Totale per Paese', 'Ricavo per paese (booking / ancillary / totale).',
N'SELECT
    [country] AS [Paese],
    SUM([booking revenue]) AS [Ricavo Ticket],
    SUM(ISNULL([ancillary revenue],0)) AS [Ricavo Ancillary],
    SUM([booking revenue] + ISNULL([ancillary revenue],0)) AS [Totale Paese]
FROM dbo.[gold base]
GROUP BY [country]
ORDER BY [Totale Paese] DESC;'),

(6, 'Percentuale Ancillary vs Ticket per Utente', 'Percentuale ancillari rispetto al ticket per ogni utente.',
N'SELECT
    [user id] AS [ID Cliente],
    SUM(ISNULL([ancillary revenue],0)) AS [Totale Ancillary],
    SUM([booking revenue]) AS [Totale Ticket],
    CASE
        WHEN SUM([booking revenue]) = 0 THEN 0
        ELSE ROUND(SUM(ISNULL([ancillary revenue],0)) * 100.0 / SUM([booking revenue]),2)
    END AS [Percentuale Ancillary]
FROM dbo.[gold base]
GROUP BY [user id]
ORDER BY [Percentuale Ancillary] DESC;'),

(7, 'Notti Medie per Destinazione', 'Numero medio di notti per destinazione.',
N'SELECT
    [destination] AS [Destinazione],
    AVG([nights]) AS [Notti Medie]
FROM dbo.[gold base]
GROUP BY [destination]
ORDER BY [Notti Medie] DESC;'),

(8, 'Prodotti Ancillary per Destinazione', 'Numero prenotazioni con ancillary e ricavo ancillary per destinazione.',
N'SELECT
    [destination] AS [Destinazione],
    COUNT(*) AS [Prenotazioni Con Ancillary],
    SUM(ISNULL([ancillary revenue],0)) AS [Ricavo Totale Ancillary]
FROM dbo.[gold base]
WHERE ISNULL([ancillary revenue],0) > 0
GROUP BY [destination]
ORDER BY [Ricavo Totale Ancillary] DESC;'),

(9, 'Stagionalità Prenotazioni (Mese)', 'Conteggio prenotazioni per mese (nome mese, ordinato per numero mese).',
N'SELECT
    DATENAME(MONTH, [booking date]) AS [Mese],
    COUNT(DISTINCT [booking id]) AS [Numero Prenotazioni]
FROM dbo.[gold base]
GROUP BY DATENAME(MONTH, [booking date]), MONTH([booking date])
ORDER BY MONTH([booking date]);'),

(10, 'Giorni Medi Tra Prenotazioni', 'Tempo medio (giorni) fra una prenotazione e la successiva per utente.',
N'SELECT
    [user id] AS [ID Cliente],
    AVG(
        DATEDIFF(
            DAY,
            [booking date],
            LEAD([booking date]) OVER (PARTITION BY [user id] ORDER BY [booking date])
        )
    ) AS [Giorni Medi Tra Prenotazioni]
FROM dbo.[gold base]
GROUP BY [user id]
ORDER BY [Giorni Medi Tra Prenotazioni];'),

(11, 'Ricavo per Stagione e Destinazione', 'Ricavo totale (booking + ancillary) per destinazione e stagione.',
N'SELECT
    [destination] AS [Destinazione],
    CASE
        WHEN MONTH([booking date]) IN (12,1,2) THEN ''Inverno''
        WHEN MONTH([booking date]) IN (3,4,5) THEN ''Primavera''
        WHEN MONTH([booking date]) IN (6,7,8) THEN ''Estate''
        ELSE ''Autunno''
    END AS [Stagione],
    SUM([booking revenue] + ISNULL([ancillary revenue],0)) AS [Ricavo Totale]
FROM dbo.[gold base]
GROUP BY
    [destination],
    CASE
        WHEN MONTH([booking date]) IN (12,1,2) THEN ''Inverno''
        WHEN MONTH([booking date]) IN (3,4,5) THEN ''Primavera''
        WHEN MONTH([booking date]) IN (6,7,8) THEN ''Estate''
        ELSE ''Autunno''
    END
ORDER BY [Stagione], [Ricavo Totale] DESC;'),

(12, 'Booking > Media Notti', 'Prenotazioni con durata superiore alla media delle notti.',
N'SELECT
    [booking id] AS [ID Prenotazione],
    [user id] AS [ID Cliente],
    [destination] AS [Destinazione],
    [nights] AS [Notti]
FROM dbo.[gold base]
WHERE [nights] > (SELECT AVG([nights]) FROM dbo.[gold base])
ORDER BY [Notti] DESC;'),

(13, 'Prezzi sopra la media per Destinazione', 'Prenotazioni con prezzo sopra la media della rispettiva destinazione.',
N'SELECT
    g.[booking id] AS [ID Prenotazione],
    g.[destination] AS [Destinazione],
    g.[booking revenue] AS [Prezzo Prenotazione]
FROM dbo.[gold base] g
WHERE g.[booking revenue] >
      (SELECT AVG([booking revenue])
       FROM dbo.[gold base]
       WHERE [destination] = g.[destination])
ORDER BY [Prezzo Prenotazione] DESC;'),

(14, 'Top 7 Utenti per Valore (2024)', 'Top 7 utenti per valore economico totale in anno 2024 (booking + ancillary).',
N'SELECT TOP 7
    [user id] AS [ID Cliente],
    SUM([booking revenue]) + SUM(ISNULL([ancillary revenue],0)) AS [Valore Economico Totale]
FROM dbo.[gold base]
WHERE YEAR([booking date]) = 2024
GROUP BY [user id]
ORDER BY [Valore Economico Totale] DESC;'),

(15, 'Fatturato e Prenotazioni 2023-2024', 'Fatturato ticket, ancillary e totale per anno 2023 e 2024.',
N'SELECT
    YEAR([booking date]) AS [Anno],
    COUNT(DISTINCT [booking id]) AS [Prenotazioni],
    SUM([booking revenue]) AS [Fatturato Ticket],
    SUM(ISNULL([ancillary revenue],0)) AS [Fatturato Ancillary],
    SUM([booking revenue]) + SUM(ISNULL([ancillary revenue],0)) AS [Totale Complessivo]
FROM dbo.[gold base]
WHERE YEAR([booking date]) IN (2023, 2024)
GROUP BY YEAR([booking date])
ORDER BY [Totale Complessivo] DESC;'),

(16, 'Clienti IT con Spesa > 1000', 'Clienti italiani con spesa totale > 1000 e numero prenotazioni.',
N'SELECT
    g.[user id] AS [ID Cliente],
    SUM(g.[booking revenue]) AS [Totale Ticket],
    SUM(ISNULL(g.[ancillary revenue],0)) AS [Totale Ancillary],
    SUM(g.[booking revenue]) + SUM(ISNULL(g.[ancillary revenue],0)) AS [Totale Speso],
    COUNT(DISTINCT g.[booking id]) AS [Numero Prenotazioni]
FROM dbo.[gold base] g
JOIN dbo.[silver customersup] c ON g.[user id] = c.[user id]
WHERE c.[country] = ''IT''
GROUP BY g.[user id]
HAVING SUM(g.[booking revenue]) + SUM(ISNULL(g.[ancillary revenue],0)) > 1000
ORDER BY [Totale Speso] DESC;'),

(17, 'Fatturato Medio per Prenotazione (2023)', 'Fatturato medio per prenotazione per canale nell''anno 2023.',
N'SELECT
    [channel] AS [Canale],
    AVG([booking revenue] + ISNULL([ancillary revenue],0)) AS [Fatturato Medio]
FROM dbo.[gold base]
WHERE YEAR([booking date]) = 2023
GROUP BY [channel]
ORDER BY [Fatturato Medio] DESC;'),

(18, 'Spesa Media Cliente per Canale (2024)', 'Spesa media per utente per canale nell''anno 2024.',
N'SELECT
    channel AS [Canale],
    AVG([Spesa Totale Utente]) AS [Spesa Media Utente]
FROM (
    SELECT
        channel,
        [user id],
        SUM([booking revenue] + ISNULL([ancillary revenue],0)) AS [Spesa Totale Utente]
    FROM dbo.[gold base]
    WHERE YEAR([booking date]) = 2024
    GROUP BY channel, [user id]
) AS t
GROUP BY channel
ORDER BY [Spesa Media Utente] DESC;'),

(19, 'Ricavo Totale per Canale 2023-2024', 'Ricavo totale per canale per gli anni 2023 e 2024.',
N'SELECT
    [channel] AS [Canale],
    YEAR([booking date]) AS [Anno],
    SUM([booking revenue] + ISNULL([ancillary revenue],0)) AS [Ricavo Totale]
FROM dbo.[gold base]
WHERE YEAR([booking date]) IN (2023, 2024)
GROUP BY [channel], YEAR([booking date])
ORDER BY [channel], [Anno];'),

(20, 'Segmentazione Clienti per Spesa', 'Segmentazione clienti in VIP/Premium/Standard in base alla spesa totale.',
N'SELECT
    [user id] AS [ID Cliente],
    SUM([booking revenue]) + SUM(ISNULL([ancillary revenue],0)) AS [Spesa Totale],
    CASE
        WHEN SUM([booking revenue]) + SUM(ISNULL([ancillary revenue],0)) > 1000 THEN ''VIP''
        WHEN SUM([booking revenue]) + SUM(ISNULL([ancillary revenue],0)) BETWEEN 500 AND 1000 THEN ''Premium''
        ELSE ''Standard''
    END AS [Segmento Cliente]
FROM dbo.[gold base]
GROUP BY [user id]
ORDER BY [Spesa Totale] DESC;'),

(21, 'Frequenza Media di Prenotazione', 'Giorni medi tra prenotazioni per cliente.',
N'SELECT
    [user id] AS [ID Cliente],
    AVG(
        DATEDIFF(
            DAY,
            [booking date],
            LEAD([booking date]) OVER (
                PARTITION BY [user id]
                ORDER BY [booking date]
            )
        )
    ) AS [Frequenza Media Giorni]
FROM dbo.[gold base]
GROUP BY [user id]
ORDER BY [Frequenza Media Giorni];'),

(22, 'Destinazioni sopra la media globale', 'Destinazioni con ricavo medio sopra la media globale.',
N'WITH [Media Globale] AS (
    SELECT AVG([booking revenue] + ISNULL([ancillary revenue],0)) AS media
    FROM dbo.[gold base]
)
SELECT
    [destination] AS [Destinazione],
    AVG([booking revenue] + ISNULL([ancillary revenue],0)) AS [Ricavo Medio Destinazione]
FROM dbo.[gold base]
CROSS JOIN [Media Globale]
GROUP BY [destination]
HAVING AVG([booking revenue] + ISNULL([ancillary revenue],0)) > media
ORDER BY [Ricavo Medio Destinazione] DESC;'),

(23, 'Tasso Conversione Ancillary', 'Percentuale di utenti che comprano almeno 1 ancillary.',
N'SELECT
    ROUND(
        (
            COUNT(DISTINCT CASE WHEN ISNULL([ancillary revenue],0) > 0 THEN [user id] END) * 100.0
        ) /
        COUNT(DISTINCT [user id])
    , 2) AS [Tasso Conversione Ancillary (%)]
FROM dbo.[gold base];');
GO
