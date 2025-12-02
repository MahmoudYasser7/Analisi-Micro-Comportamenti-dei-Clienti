# Analisi Micro-Comportamenti dei Clienti

## 📐 Progetto SQL end-to-end

Questo progetto implementa una pipeline dati completa basata sull’architettura Medallion (Bronze, Silver, Gold).
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




## 🧬 Cuore del progetto

###  ⚙️ Parte tecnica:

• Estrazione dei CSV e caricamento nel layer Bronze mantenendo la struttura originale

• Creazione delle tabelle Bronze con schema coerente ai file sorgenti

• Modellazione relazionale delle entità (clienti, prenotazioni, ancillari)

• Organizzazione del layer Silver con strutture pulite, consistenti e pronte per le analisi

• Implementazione di chiavi primarie e indici per integrità e performance

• Costruzione del dataset analitico attraverso trasformazioni SQL mirate

• Applicazione della Medallion Architecture (Bronze -> Silver -> Gold) come pipeline modulare e scalabile

• Preparazione del layer Gold in maniera ottimizzata per analisi comportamentali e BI

### 🎯 Obiettivo tecnico: portare i dati da grezzi -> puliti -> interrogabili.


### 📈 Parte analitica:

• Calcolo delle metriche business fondamentali (ricorrenza, spesa totale, intervallo tra prenotazioni, revenue per booking)

• Analisi dei micro-comportamenti dei clienti: ricorrenza, frequenza, stagionalità e valore economico

• Segmentazione dei clienti in Standard / Medium / High Spender in base alle metriche consolidate

• Valutazione dell'attach rate degli ancillaries e identificazione dei prodotti extra più performanti

• Identificazione di destinazioni più redditizie e delle tratte con revenue sopra la media

• Analisi dei canali di prenotazione e valutazione delle loro performance

• Individuazione dei booking con revenue sopra media tramite aggregazioni avanzate

•  Costruzione del dataset Gold ottimizzato per BI e dashboard

• Utilizzo di join, aggregazioni e CTE per produrre dataset analitici complessi e coerenti

• Preparazione di dataset finali strutturati per insight immediati e decisioni data-driven

### 🎯 Obiettivo analitico: Estrarre pattern reali e segnali utili a comprendere come i clienti acquistano e quali leve generano maggior valore.




## 📦 Dataset utilizzati

Bookings.csv -> prenotazioni dei clienti

Ancillaries.csv -> acquisti extra collegati alla prenotazione

Customersup.csv -> informazioni anagrafiche dei clienti

📍 Le colonne complete e la descrizione dettagliata sono nel file:
Data_dictionary.md



## 📁 Struttura del Repository

• README.md -> descrizione completa del progetto

• Data_dictionary.md -> dizionario dati (colonne, tipi, significato)

• Customersup.csv, Bookings.csv, Ancillaries.csv -> dataset originali

/sql
- 01_bronze_raw_create_tables.sql
- 02_bronze_load_data.sql
- 03_silver_cleansing.sql
- 04_silver_constraints.sql
- 05_gold_base.sql
- 06_gold_kpi.sql
- 07_load_kpi.sql



## 🧩 Modellazione & Schema del Database
Ho modellato lo schema SQL partendo da zero: ho definito tabelle normalizzate, ho impostato PK e Indici mirati per assicurare integrità referenziale, e ho scelto tipi dato coerenti con il contenuto dei CSV.
Ho aggiunto Indici sulle colonne utilizzate nei join (customer_id, booking_id) per migliorare le query del layer Gold.
Il risultato è un modello solido che supporta analisi comportamentali senza duplicazioni né inconsistenze.


## 📍 Scelte di modellazione: PK, FK, Indici

### 📌 Customersup
Colonne reali: user_id, country, registration_date, age, gender

- Funzione: tabella anagrafica principale
- PK: user_id -> identifica in modo univoco ogni utente nel sistema.
- FK: Non ha FK perché è la tabella da cui partono tutte le relazioni: rappresenta l’entità principale e non dipende da altre tabelle.
- Indice: user_id
- Motivo: L’indice serve per rendere più veloci i join e le analisi che collegano i clienti alle loro prenotazioni.


### 📌 Bookings
Colonne reali: booking_id, user_id, booking_date, destination, nights, price_total, channel, currency

- Funzione: tabella principale delle prenotazioni
- PK: booking_id -> distingue ogni prenotazione dalle altre.
- FK: user_id -> Customersup.user_id
- Indici: booking_id, user_id
- Motivo: booking_id rappresenta ogni prenotazione e quindi è la chiave giusta.
  Il FK garantisce coerenza: ogni prenotazione deve riferirsi a un utente presente in Customersup.
  L’indice su user_id velocizza tutte le analisi per utente (numero prenotazioni, ricorrenza, spesa totale).
  L’indice su booking_id serve a collegare Bookings con Ancillaries in modo più efficiente.


### 📌 Ancillaries
Colonne reali: ancillary_id, booking_id, product_type, price, sold_date

- Funzione: tabella dei prodotti extra collegati alle prenotazioni
- PK: ancillary_id -> assegna un ID unico a ogni servizio aggiuntivo acquistabile.
- FK: booking_id -> Bookings.booking_id
- Indici: ancillary_id, booking_id
- Motivo: ancillary_id identifica in modo univoco ogni prodotto extra acquistato.
  Il FK mantiene il modello coerente: ogni extra fa riferimento al suo booking.
  L’indice su ancillary_id velocizza ricerche e controlli di integrità sulla tabella.
  L’indice su booking_id serve perché gli extra sono sempre collegati a una prenotazione.


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
 - 06_gold_kpi.sql
 - 07_load_kpi.sql



## 🎯 Strumenti e attività svolte: MS SQL Server (T-SQL), SQL Server Management Studio (SSMS), Modellazione tabelle reali da CSV, Data Cleansing, micro-analisi comportamentale, KPI business, Query avanzate, Pipeline ETL dati end-to-end, e Documentazione tecnica (README + Data dictionary).


## 🔦 Conclusione: il progetto ricostruisce un workflow ETL e mette in evidenza come i dati grezzi possano essere trasformati in insight davvero utili per supportare le decisioni aziendali.


## Autore
Mahmoud Yasser
