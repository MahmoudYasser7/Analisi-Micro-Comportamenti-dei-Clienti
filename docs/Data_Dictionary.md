# 📘 Data Dictionary - Struttura dei dati del progetto

Questo documento descrive in modo semplice e diretto la struttura dei tre dataset (Bookings, Ancillaries, Customersup) e come vengono interpretati all’interno del flusso Bronze → Silver → Gold.
L’obiettivo è capire cosa rappresenta ogni colonna, come viene utilizzata e che ruolo ha nel modello analitico.


## 🧩 1. Customersup - Anagrafica Cliente

È il dataset che contiene le informazioni fondamentali dei clienti.
È la tabella da cui parte tutto: registrazione, età, paese, profilo.

### 📍 Campi:

• user_id → identificatore univoco del cliente (PK).

• country → paese del cliente.

• registration_date → data in cui il cliente si è registrato.

• age → età dichiarata.

• gender → genere dichiarato.

### 🔎 In breve: è la tabella dimensionale di riferimento, da cui partono le relazioni verso le fact table.


## 🧩 2. Bookings - Prenotazioni

Contiene tutte le prenotazioni fatte dai clienti.
È il cuore del progetto perché permette di analizzare comportamento, ricorrenza e micro-pattern.

### 📍 Campi:

• booking_id → ID unico della prenotazione (PK).

• user_id → collega il booking al cliente (FK verso Customersup.user_id).

• booking_date → quando è stata fatta la prenotazione.

• destination → destinazione della prenotazione.

• nights → numero notti.

• price_total → importo totale della prenotazione.

• channel → Web / Mobile App / Call center.

• currency → valuta della prenotazione.

### 🔎 In breve: è la fact table centrale del modello: contiene le informazioni essenziali su quando, come e dove i clienti prenotano.


## 🧩 3. Ancillaries - Prodotti Extra

Contiene tutti gli acquisti ancillari collegati a una prenotazione.

### 📍 Campi:

• ancillary_id → identificatore dell’extra (PK).

• booking_id → collega ogni extra alla prenotazione da cui nasce (FK verso Bookings.booking_id).

• product_type → tipologia di prodotto.

• price → quanto è stato pagato l’extra.

• sold_date → giorno in cui l’extra è stato acquistato.

### 🔎 In breve: è una fact table collegata alle prenotazioni: permette di analizzare il comportamento sugli acquisti extra e quanto contribuiscono al totale.


## 🔁 Evoluzione dei dati: Bronze → Silver → Gold

Bronze: caricamento dei file così come sono, mantenendo la struttura originale senza trasformazioni.

Silver: pulizia, uniformazione dei formati, standardizzazione del testo, conversioni di tipo, rimozione delle incoerenze.

Gold: la fase finale in cui preparo la Gold Base, calcolo i KPI nella tabella Gold KPI e li carico tramite KPI Load.


## 📚 Utilità del Dizionario

Grazie a una struttura chiara e pulita:

• si capisce come navigare i dataset

• è più facile scrivere query coerenti

• si riducono errori e duplicazioni

• si ha una base solida per analisi avanzate
