USE Analisi;
GO

IF OBJECT_ID('dbo.[gold kpi]', 'U') IS NOT NULL
    DROP TABLE dbo.[gold kpi];
GO

CREATE TABLE dbo.[gold kpi] (
    [KPI Date] DATE,
    [Total Revenue] DECIMAL(18,2),
    [Booking Revenue] DECIMAL(18,2),
    [Ancillary Revenue] DECIMAL(18,2),
    [Avg Booking Value] DECIMAL(18,2),
    [Conversion Rate] DECIMAL(10,4),
    [Ancillary Attach Rate] DECIMAL(10,4),
    [Total Bookings] INT,
    [Total Users] INT
);
GO




1. Variazione mensile del fatturato

USE Analisi;
GO

WITH [Fatturato Mensile] AS (
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
ORDER BY [Anno], [Mese];
GO



2. Fatturato totale per canale di vendita
    
USE Analisi;
GO

SELECT
    channel AS [Canale di Vendita],
    SUM([booking revenue]) AS [Fatturato Ticket],
    SUM(ISNULL([ancillary revenue], 0)) AS [Fatturato Ancillary],
    SUM([booking revenue] + ISNULL([ancillary revenue], 0)) AS [Fatturato Totale]
FROM dbo.[gold base]
GROUP BY channel
ORDER BY [Fatturato Totale] DESC;
GO


    
    
3. Ricavo medio per destinazione
    
USE Analisi;
GO

SELECT
    destination AS [Destinazione],
    AVG([booking revenue] + ISNULL([ancillary revenue], 0)) AS [Ricavo Medio Destinazione]
FROM dbo.[gold base]
GROUP BY destination
ORDER BY [Ricavo Medio Destinazione] DESC;
GO

    
4. Utenti con più prenotazioni

USE Analisi;
GO

SELECT
    [user id] AS [ID Cliente],
    COUNT(DISTINCT [booking id]) AS [Numero Prenotazioni]
FROM dbo.[gold base]
GROUP BY [user id]
ORDER BY [Numero Prenotazioni] DESC;
GO


5. Ricavo totale per paese

USE Analisi;
GO

SELECT
    country AS [Paese],
    SUM([booking revenue]) AS [Ricavo Ticket],
    SUM(ISNULL([ancillary revenue], 0)) AS [Ricavo Ancillary],
    SUM([booking revenue]) + SUM(ISNULL([ancillary revenue], 0)) AS [Totale Paese]
FROM dbo.[gold base]
GROUP BY country
ORDER BY [Totale Paese] DESC;
GO

    

6. Percentuale Ancillary vs Ticket per utente

USE Analisi;
GO

SELECT
    [user id] AS [ID Cliente],
    SUM(ISNULL([ancillary revenue],0)) AS [Totale Ancillary],
    SUM([booking revenue]) AS [Totale Ticket],
    CASE
        WHEN SUM([booking revenue]) = 0 THEN 0
        ELSE ROUND(
                SUM(ISNULL([ancillary revenue],0)) * 100.0 
                / SUM([booking revenue]),
            2)
    END AS [Percentuale Ancillary]
FROM dbo.[gold base]
GROUP BY [user id]
ORDER BY [Percentuale Ancillary] DESC;
GO


7. Numero medio di notti per destinazione

USE Analisi;
GO

SELECT
    destination AS [Destinazione],
    AVG(nights) AS [Notti Medie]
FROM dbo.[gold base]
GROUP BY destination
ORDER BY [Notti Medie] DESC;
GO



    
8. Prodotti Ancillary più venduti

USE Analisi;
GO
    
SELECT 
    [product type] AS [Prodotto],
    COUNT(*) AS [Numero Vendite],
    SUM([price]) AS [Ricavo Totale]
FROM dbo.[silver ancillaries]
GROUP BY [product type]
ORDER BY [Numero Vendite] DESC;
GO
    

9. Stagionalità delle prenotazioni per mese

USE Analisi;
GO

SELECT
    DATENAME(MONTH, [booking date]) AS [Mese],
    COUNT(DISTINCT [booking id]) AS [Numero Prenotazioni]
FROM dbo.[gold base]
GROUP BY DATENAME(MONTH, [booking date]), MONTH([booking date])
ORDER BY MONTH([booking date]);
GO

    
10. Tempo medio tra una prenotazione e la successiva

USE Analisi;
GO

SELECT
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
ORDER BY [Giorni Medi Tra Prenotazioni];
GO

   

11. Destinazioni con più ricavo per stagione

USE Analisi;
GO

SELECT
    destination AS [Destinazione],
    CASE
        WHEN MONTH([booking date]) IN (12,1,2) THEN 'Inverno'
        WHEN MONTH([booking date]) IN (3,4,5) THEN 'Primavera'
        WHEN MONTH([booking date]) IN (6,7,8) THEN 'Estate'
        ELSE 'Autunno'
    END AS [Stagione],
    SUM([booking revenue] + ISNULL([ancillary revenue],0)) AS [Ricavo Totale]
FROM dbo.[gold base]
GROUP BY
    destination,
    CASE
        WHEN MONTH([booking date]) IN (12,1,2) THEN 'Inverno'
        WHEN MONTH([booking date]) IN (3,4,5) THEN 'Primavera'
        WHEN MONTH([booking date]) IN (6,7,8) THEN 'Estate'
        ELSE 'Autunno'
    END
ORDER BY [Stagione], [Ricavo Totale] DESC;
GO


12. Booking con durata superiore alla media

USE Analisi;
GO

SELECT
    [booking id] AS [ID Prenotazione],
    [user id] AS [ID Cliente],
    [destination] AS [Destinazione],
    [nights] AS [Notti]
FROM dbo.[gold base]
WHERE [nights] > (SELECT AVG([nights]) FROM dbo.[gold base])
ORDER BY [Notti] DESC;
GO

    
13. Prenotazioni con prezzo sopra la media della destinazione
    
USE Analisi;
GO

SELECT
    g.[booking id] AS [ID Prenotazione],
    g.[destination] AS [Destinazione],
    g.[booking revenue] AS [Prezzo Prenotazione]
FROM dbo.[gold base] g
WHERE g.[booking revenue] >
      (SELECT AVG([booking revenue])
       FROM dbo.[gold base]
       WHERE [destination] = g.[destination])
ORDER BY [Prezzo Prenotazione] DESC;
GO


    
14. Top 7 utenti per valore economico totale (2024)

USE Analisi;
GO
    
SELECT TOP 7
    [user id] AS [ID Cliente],
    SUM([booking revenue]) + SUM(ISNULL([ancillary revenue],0)) AS [Valore Economico Totale]
FROM dbo.[gold base]
WHERE YEAR([booking date]) = 2024
GROUP BY [user id]
ORDER BY [Valore Economico Totale] DESC;
GO

    

    
15. Fatturato e prenotazioni per anno 2023 & 2024
    
USE Analisi;
GO

SELECT
    YEAR([booking date]) AS [Anno],
    COUNT(DISTINCT [booking id]) AS [Prenotazioni],
    SUM([booking revenue]) AS [Fatturato Ticket],
    SUM(ISNULL([ancillary revenue],0)) AS [Fatturato Ancillary],
    SUM([booking revenue]) + SUM(ISNULL([ancillary revenue],0)) AS [Totale Complessivo]
FROM dbo.[gold base]
WHERE YEAR([booking date]) IN (2023, 2024)
GROUP BY YEAR([booking date])
ORDER BY [Totale Complessivo] DESC;
GO


    
    
16. Clienti italiani con spesa totale > 1000€ e numero prenotazioni

USE Analisi;
GO

SELECT
    g.[user id] AS [ID Cliente],
    SUM(g.[booking revenue]) AS [Totale Ticket],
    SUM(ISNULL(g.[ancillary revenue],0)) AS [Totale Ancillary],
    SUM(g.[booking revenue]) + SUM(ISNULL(g.[ancillary revenue],0)) AS [Totale Speso],
    COUNT(DISTINCT g.[booking id]) AS [Numero Prenotazioni]
FROM dbo.[gold base] g
JOIN dbo.[silver customersup] c ON g.[user id] = c.[user id]
WHERE c.[country] = 'IT'
GROUP BY g.[user id]
HAVING SUM(g.[booking revenue]) + SUM(ISNULL(g.[ancillary revenue],0)) > 1000
ORDER BY [Totale Speso] DESC;
GO

    
17. Fatturato medio per prenotazione per canale anno 2023

USE Analisi;
GO

SELECT
    channel AS [Canale],
    AVG([booking revenue] + ISNULL([ancillary revenue],0)) AS [Fatturato Medio]
FROM dbo.[gold base]
WHERE YEAR([booking date]) = 2023
GROUP BY channel
ORDER BY [Fatturato Medio] DESC;
GO


18. Spesa media per utente per canale anno 2024

USE Analisi;
GO

SELECT
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
ORDER BY [Spesa Media Utente] DESC;
GO

    
19. Ricavo totale per canale anno 2023 & 2024

USE Analisi;
GO

SELECT
    channel AS [Canale],
    YEAR([booking date]) AS [Anno],
    SUM([booking revenue] + ISNULL([ancillary revenue],0)) AS [Ricavo Totale]
FROM dbo.[gold base]
WHERE YEAR([booking date]) IN (2023, 2024)
GROUP BY channel, YEAR([booking date])
ORDER BY channel, [Anno];
GO

    

    
20. Segmentazione clienti in base alla spesa totale
    
USE Analisi;
GO

SELECT
    [user id] AS [ID Cliente],
    SUM([booking revenue]) + SUM(ISNULL([ancillary revenue],0)) AS [Spesa Totale],
    CASE
        WHEN SUM([booking revenue]) + SUM(ISNULL([ancillary revenue],0)) > 1000 THEN 'VIP'
        WHEN SUM([booking revenue]) + SUM(ISNULL([ancillary revenue],0)) BETWEEN 500 AND 1000 THEN 'Premium'
        ELSE 'Standard'
    END AS [Segmento Cliente]
FROM dbo.[gold base]
GROUP BY [user id]
ORDER BY [Spesa Totale] DESC;
GO


    
21. Frequenza media di prenotazione per cliente

USE Analisi;
GO

SELECT
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
ORDER BY [Frequenza Media Giorni];
GO

    
22. Destinazioni sopra il fatturato medio globale

USE Analisi;
GO

WITH [Media Globale] AS (
    SELECT AVG([booking revenue] + ISNULL([ancillary revenue],0)) AS media
    FROM dbo.[gold base]
)
SELECT
    destination AS [Destinazione],
    AVG([booking revenue] + ISNULL([ancillary revenue],0)) AS [Ricavo Medio Destinazione]
FROM dbo.[gold base]
CROSS JOIN [Media Globale]
GROUP BY destination
HAVING AVG([booking revenue] + ISNULL([ancillary revenue],0)) > media
ORDER BY [Ricavo Medio Destinazione] DESC;
GO


    
23. Percentuale utenti che comprano almeno 1 ancillary

USE Analisi;
GO

SELECT
    ROUND(
        (
            COUNT(DISTINCT CASE WHEN ISNULL([ancillary revenue],0) > 0 THEN [user id] END) * 100.0
        ) /
        COUNT(DISTINCT [user id])
    , 2) AS [Tasso Conversione Ancillary (%)]
FROM dbo.[gold base];
GO
