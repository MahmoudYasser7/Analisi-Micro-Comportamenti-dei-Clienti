# Analisi Micro-Comportamenti dei Clienti

## 📐 Progetto SQL end-to-end

Questo progetto implementa una pipeline dati completa basata sull’architettura Medallion.
Ho voluto replicare uno scenario realistico tipico delle piattaforme di e-commerce e booking, con l’obiettivo di analizzare il comportamento dei clienti.
Partendo da 3 CSV grezzi ho costruito uno schema SQL strutturato: tabelle normalizzate, relazioni, KPI per identificare micro-comportamenti, e un dataset Gold ottimizzato per analisi BI.

## 🔄 Flusso del progetto

1. Estrazione dei tre CSV nel layer Bronze

2. Creazione delle tabelle Bronze con schema coerente ai file sorgenti

3. Caricamento dati tramite BULK INSERT

4. Creazione tabelle Silver pulite e pronte per analisi

5. Aggiunta PK e Indici per garantire integrità e performance

6. Creazione della tabella Gold Base tramite join tra le entità

7. Calcolo KPI e micro-comportamenti

8. Preparazione dataset Gold ottimizzato per analisi e BI


## 🧱 Architettura del progetto

### 🥉 Bronze - Dati grezzi
In questa fase ho importato i CSV così come sono, senza modifiche. Ho definito lo schema iniziale rispettando le colonne reali e impostando le chiavi primarie.
###  Scopo: Extract - caricare i dati raw senza modificarli.


### 🥈 Silver - Pulizia e preparazione
In questa fase ho standardizzato i formati delle date, verificato tipi numerici e stringhe, controllato duplicati, verificato la coerenza tra Bookings e Ancillaries, preparato i dati per la fase analitica.
###  Scopo: Transform - preparare dati puliti e normalizzati.


### 🥇 Gold - Modello analitico finale e KPI  
In questa fase ho costruito i dataset analitici finali (Gold Base) e le principali metriche di business (Gold KPI), con il relativo processo di caricamento (KPI Load). È il layer pensato per l’utilizzo diretto: dashboard, analisi e reportistica.
###  Scopo: Analytics - dataset finale e KPI.

## 🧬Cuore del progetto

### ⚙️Parte tecnica:

• Estrazione dei CSV e caricamento nel layer Bronze mantenendo la struttura originale  

• Creazione delle tabelle Bronze con schema coerente ai file sorgenti

• Modellazione relazionale delle entità (clienti, prenotazioni, ancillaries)  

• Organizzazione del layer Silver con strutture pulite, consistenti e pronte per le analisi  

• Implementazione di chiavi primarie e indici per integrità e performance  

• Controllo duplicati e verifica coerenza tra Bookings e Ancillaries nel layer Silver 

• Costruzione del dataset analitico attraverso trasformazioni SQL mirate  

• Applicazione della Medallion Architecture (Bronze → Silver → Gold) come pipeline modulare e scalabile  

• Preparazione del layer Gold in maniera ottimizzata per analisi comportamentali e BI


### 🎯Obiettivo tecnico: portare i dati da grezzi → puliti → interrogabili.


### 📈 Parte analitica:

• Calcolo delle metriche business fondamentali (spesa totale, intervallo tra prenotazioni, revenue per booking)

• Analisi dei micro-comportamenti dei clienti: frequenza, stagionalità e valore economico

• Segmentazione dei clienti in Standard / Medium / High Spender in base alle metriche consolidate

• Valutazione dell'attach rate degli ancillaries e identificazione dei prodotti extra più performanti

• Identificazione di destinazioni più redditizie e delle tratte con revenue sopra la media

• Analisi dei canali di prenotazione e valutazione delle loro performance

• Individuazione dei booking con revenue sopra media tramite aggregazioni avanzate

•  Costruzione del dataset Gold ottimizzato per BI e dashboard

• Utilizzo di join, aggregazioni e CTE per produrre dataset analitici coerenti

• Preparazione di dataset finali strutturati per insight immediati e decisioni data-driven

### 🎯 Obiettivo analitico: Estrarre pattern reali e segnali utili a comprendere come i clienti acquistano e quali leve generano maggior valore.


## 📦Dataset utilizzati

Customersup.csv → informazioni anagrafiche dei clienti  
Bookings.csv → prenotazioni dei clienti  
Ancillaries.csv → acquisti extra collegati alla prenotazione  

📍Le colonne complete e la descrizione dettagliata sono nel file: Data_Dictionary.md

## 📁Struttura del Repository

• README.md → descrizione completa del progetto  
• Data_Dictionary.md → dizionario dati (colonne, tipi, significato)  
• Customersup.csv, Bookings.csv, Ancillaries.csv → dataset originali  

/sql  
- 01_bronze_raw_create_tables.sql  
- 02_bronze_load_data.sql  
- 03_silver_cleansing.sql  
- 04_silver_constraints.sql  
- 05_gold_base.sql  
- 06_load_kpi.sql  

## 🧩 Modellazione & Schema del Database
Ho modellato lo schema SQL partendo dai dati puliti del layer Silver, riorganizzando le tabelle del layer Gold per rendere le analisi più semplici e performanti.
Ho separato le metriche principali dalle informazioni descrittive, mantenendo le prenotazioni come evento centrale su cui si basano tutte le analisi.
Il modello è pensato per supportare KPI, aggregazioni e query analitiche senza duplicazioni e con join lineari.

## 📍Scelte di modellazione: PK, FK, Indici

### 📌Fact_Bookings

• Colonne principali: booking_id, user_id, booking_date, destination, channel, nights, price_total, currency  
• PK: booking_id  
• FK: user_id → Dim_Customersup.user_id  
• Indici: booking_id, user_id, booking_date  

• Motivo:

- booking_id rappresenta ogni prenotazione ed è la chiave primaria naturale.

- user_id collega il booking al cliente, garantendo coerenza tra le tabelle.

- gli indici velocizza join, aggregazioni e analisi temporali.

### 📌Fact_Ancillaries

• Colonne principali: ancillary_id, booking_id, product_type, price, sold_date  
• PK: ancillary_id  
• FK: booking_id → Fact_Bookings.booking_id  
• Indici: ancillary_id, booking_id  

• Motivo:

- ancillary_id è unico per ogni prodotto extra, quindi chiave primaria naturale.

- booking_id garantisce coerenza: ogni prodotto extra deve riferirsi a un booking esistente.

- gli indici velocizzano join con Fact_Bookings e aggregazioni per analisi di revenue addizionale.

### 📌Dim_Customersup

• Colonne principali: user_id, country, registration_date, age, gender  
• PK: user_id  
• FK: nessuna  
• Indici: solo PK

• Motivo:

- user_id è la chiave primaria naturale, identifica univocamente ogni cliente, evitando duplicazioni nei join.

- La tabella non ha FK perché contiene solo informazioni descrittive.


## ▶️ Come eseguire il progetto (MS SQL Server)

1- Apri SSMS

2- Crea il database:

CREATE DATABASE Analisi;
GO

 3- Esegui gli script nell’ordine:
  
- 01_bronze_raw_create_tables.sql
- 02_bronze_load_data.sql
- 03_silver_cleansing.sql
- 04_silver_constraints.sql
- 05_gold_base.sql
- 06_load_kpi.sql



## 🎯 Strumenti e attività svolte: MS SQL Server (T-SQL), SQL Server Management Studio (SSMS), Modellazione tabelle reali da CSV, Data Cleansing, micro-analisi comportamentale, KPI business, Pipeline ETL dati end-to-end, e Documentazione tecnica (README + Data Dictionary).

## Autore:
Mahmoud Yasser
