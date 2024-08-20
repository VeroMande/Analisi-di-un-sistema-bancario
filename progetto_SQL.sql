/*
CASO D'USO BANCARIO
Ogni indicatore va riferito al singolo id_cliente.
	- 1. Età
	- 2. Numero di transazioni in uscita su tutti i conti
	- 3. Numero di transazioni in entrata su tutti i conti
	- 4. Importo transato in uscita su tutti i conti
	- 5. Importo transato in entrata su tutti i conti
	- 6. Numero totale di conti posseduti
	- 7. Numero di conti posseduti per tipologia (un indicatore per tipo)
	- 8. Numero di transazioni in uscita per tipologia di transazione (un indicatore per tipo)
	- 9. Numero di transazioni in entrata per tipologia di transazione (un indicatore per tipo)
	- 10. Importo transato in uscita per tipologia di conto (un indicatore per tipo)
	- 11. Importo transato in entrata per tipologia di conto (un indicatore per tipo)
*/
USE banca;
SELECT * FROM banca.cliente;
SELECT * FROM banca.conto;
SELECT * FROM banca.transazioni;
SELECT * FROM banca.tipo_transazione;
SELECT * FROM banca.tipo_conto;

SELECT DISTINCT id_cliente
FROM banca.cliente;

/*
	1. eta
*/
DROP TABLE IF EXISTS banca.eta_temp;
CREATE TEMPORARY TABLE banca.eta_temp AS
SELECT 
    cli.id_cliente,
    cli.nome,
    cli.cognome,
    TIMESTAMPDIFF(YEAR, cli.data_nascita, CURDATE()) AS eta_cliente
FROM banca.cliente cli;
SELECT * FROM banca.eta_temp;

/*
	2. Numero di transazioni in uscita su tutti i conti
	3. Numero di transazioni in entrata su tutti i conti
	4. Importo transato in uscita su tutti i conti
	5. Importo transato in entrata su tutti i conti
*/
DROP TABLE IF EXISTS banca.mumero_transazioni_totali;
CREATE TEMPORARY TABLE mumero_transazioni_totali AS 
SELECT 
    cli.id_cliente,
	COUNT(CASE WHEN tipo_trans.segno = '-' THEN 1 END) AS n°_tot_transazioni_uscita,
    COUNT(CASE WHEN tipo_trans.segno = '+' THEN 1 END) AS n°_tot_transazioni_entrata,
	COALESCE(ROUND(SUM(CASE WHEN tipo_trans.segno = '+' THEN trans.importo ELSE 0 END), 2), 0) AS somma_importi_entrata,
	COALESCE(ROUND(SUM(CASE WHEN tipo_trans.segno = '-' THEN trans.importo ELSE 0 END), 2), 0) AS somma_importi_uscita
FROM banca.cliente cli 
LEFT JOIN banca.conto cont ON cli.id_cliente = cont.id_cliente
LEFT JOIN banca.transazioni trans ON cont.id_conto = trans.id_conto
LEFT JOIN banca.tipo_transazione tipo_trans ON trans.id_tipo_trans = tipo_trans.id_tipo_transazione
LEFT JOIN banca.tipo_conto tipo_cont ON cont.id_tipo_conto = tipo_cont.id_tipo_conto
GROUP BY cli.id_cliente
ORDER BY cli.id_cliente ASC;
SELECT * FROM banca.mumero_transazioni_totali;

/*
	6. Numero totale di conti posseduti # CONTEGGIO CONTI ASSOCIATI AL SINGOLO CLIENTE
*/
DROP TABLE IF EXISTS banca.tot_conti_posseduti;
CREATE TEMPORARY TABLE tot_conti_posseduti AS 
SELECT 
	cli.id_cliente,
	count(cont.id_conto) AS n°_conti_totali_posseduti
FROM banca.cliente cli 
LEFT JOIN banca.conto cont ON cli.id_cliente = cont.id_cliente
GROUP BY cli.id_cliente
ORDER BY cli.id_cliente ASC;
SELECT * FROM banca.tot_conti_posseduti;

/*
	7. Numero di conti posseduti per tipologia (un indicatore per tipo)
*/
SELECT DISTINCT id_tipo_conto, desc_tipo_conto
FROM banca.tipo_conto;

DROP TABLE IF EXISTS banca.n_conti_posseduti;
CREATE TEMPORARY TABLE n_conti_posseduti AS
SELECT 
cli.id_cliente,
SUM(CASE WHEN tipo_cont.desc_tipo_conto = 'Conto Base' THEN 1 ELSE 0 END) AS n°_conti_base,
SUM(CASE WHEN tipo_cont.desc_tipo_conto = 'Conto Business' THEN 1 ELSE 0 END) AS n°_conti_business,
SUM(CASE WHEN tipo_cont.desc_tipo_conto = 'Conto Privati' THEN 1 ELSE 0 END) AS n°_conti_privati,
SUM(CASE WHEN tipo_cont.desc_tipo_conto = 'Conto Famiglie' THEN 1 ELSE 0 END) AS n°_conti_famiglie
from banca.cliente cli
LEFT JOIN banca.conto cont ON cli.id_cliente = cont.id_cliente
LEFT JOIN banca.tipo_conto tipo_cont ON cont.id_tipo_conto = tipo_cont.id_tipo_conto
GROUP BY cli.id_cliente;
SELECT * FROM banca.n_conti_posseduti;

/*
	8. Numero di transazioni in uscita per tipologia di transazione (un indicatore per tipo)
*/
SELECT DISTINCT id_tipo_transazione, desc_tipo_trans
FROM banca.tipo_transazione;

DROP TABLE IF EXISTS banca.trans_tipo_transazione_neg;
CREATE TEMPORARY TABLE trans_tipo_transazione_neg AS
SELECT 
    cli.id_cliente,
	COALESCE(SUM(CASE WHEN tipo_trans.desc_tipo_trans = 'Stipendio' AND tipo_trans.segno = '-' THEN 1 ELSE 0 END), 0) AS Stipendio_uscita,
    COALESCE(SUM(CASE WHEN tipo_trans.desc_tipo_trans = 'Pensione' AND tipo_trans.segno = '-' THEN 1 ELSE 0 END), 0) AS Pensione_uscita,
    COALESCE(SUM(CASE WHEN tipo_trans.desc_tipo_trans = 'Dividendi' AND tipo_trans.segno = '-' THEN 1 ELSE 0 END), 0) AS Dividendi_uscita,
    COALESCE(SUM(CASE WHEN tipo_trans.desc_tipo_trans = 'Acquisto su amazon' AND tipo_trans.segno = '-' THEN 1 ELSE 0 END), 0) AS Acquisto_su_amazon_uscita,
    COALESCE(SUM(CASE WHEN tipo_trans.desc_tipo_trans = 'Rata mutuo' AND tipo_trans.segno = '-' THEN 1 ELSE 0 END), 0) AS rata_mutuo_uscita,
    COALESCE(SUM(CASE WHEN tipo_trans.desc_tipo_trans = 'Hotel' AND tipo_trans.segno = '-' THEN 1 ELSE 0 END), 0) AS hotel_uscita,
    COALESCE(SUM(CASE WHEN tipo_trans.desc_tipo_trans = 'Biglietto aereo' AND tipo_trans.segno = '-' THEN 1 ELSE 0 END), 0) AS biglietto_aereo_uscita,
    COALESCE(SUM(CASE WHEN tipo_trans.desc_tipo_trans = 'Supermercato' AND tipo_trans.segno = '-' THEN 1 ELSE 0 END), 0) AS supermercato_uscita
FROM banca.cliente cli
LEFT JOIN banca.conto cont ON cli.id_cliente = cont.id_cliente
LEFT JOIN banca.transazioni trans ON cont.id_conto = trans.id_conto
LEFT JOIN banca.tipo_transazione tipo_trans ON tipo_trans.id_tipo_transazione = trans.id_tipo_trans
/*WHERE tipo_trans.segno = '-'*/
GROUP BY cli.id_cliente
ORDER BY cli.id_cliente ASC;
SELECT * FROM banca.trans_tipo_transazione_neg;

/*
	9. Numero di transazioni in entrata per tipologia di transazione (un indicatore per tipo)
*/
DROP TABLE IF EXISTS banca.trans_tipo_transazione_pos;
CREATE TEMPORARY TABLE trans_tipo_transazione_pos AS
SELECT 
    cli.id_cliente,
	COALESCE(SUM(CASE WHEN tipo_trans.desc_tipo_trans = 'Stipendio' AND tipo_trans.segno = '+' THEN 1 ELSE 0 END), 0) AS Stipendio_entrata,
    COALESCE(SUM(CASE WHEN tipo_trans.desc_tipo_trans = 'Pensione' AND tipo_trans.segno = '+' THEN 1 ELSE 0 END), 0) AS Pensione_entrata,
    COALESCE(SUM(CASE WHEN tipo_trans.desc_tipo_trans = 'Dividendi' AND tipo_trans.segno = '+' THEN 1 ELSE 0 END), 0) AS Dividendi_entrata,
    COALESCE(SUM(CASE WHEN tipo_trans.desc_tipo_trans = 'Acquisto su amazon' AND tipo_trans.segno = '+' THEN 1 ELSE 0 END), 0) AS Acquisto_su_amazon_entrata,
    COALESCE(SUM(CASE WHEN tipo_trans.desc_tipo_trans = 'Rata mutuo' AND tipo_trans.segno = '+' THEN 1 ELSE 0 END), 0) AS rata_mutuo_entrata,
    COALESCE(SUM(CASE WHEN tipo_trans.desc_tipo_trans = 'Hotel' AND tipo_trans.segno = '+' THEN 1 ELSE 0 END), 0) AS hotel_entrata,
    COALESCE(SUM(CASE WHEN tipo_trans.desc_tipo_trans = 'Biglietto aereo' AND tipo_trans.segno = '+' THEN 1 ELSE 0 END), 0) AS biglietto_aereo_entrata,
    COALESCE(SUM(CASE WHEN tipo_trans.desc_tipo_trans = 'Supermercato' AND tipo_trans.segno = '+' THEN 1 ELSE 0 END), 0) AS supermercato_entrata
FROM banca.cliente cli
LEFT JOIN banca.conto cont ON cli.id_cliente = cont.id_cliente
LEFT JOIN banca.transazioni trans ON cont.id_conto = trans.id_conto
LEFT JOIN banca.tipo_transazione tipo_trans ON tipo_trans.id_tipo_transazione = trans.id_tipo_trans
/*WHERE tipo_trans.segno = '+'*/
GROUP BY cli.id_cliente
ORDER BY cli.id_cliente ASC;
SELECT * FROM banca.trans_tipo_transazione_pos;

/*
	10. Importo transato in uscita per tipologia di conto (un indicatore per tipo)
*/
DROP TABLE IF EXISTS banca.importo_uscita_conto;
CREATE TEMPORARY TABLE importo_uscita_conto AS
SELECT 
    cli.id_cliente,
    COALESCE(ROUND(SUM(CASE WHEN tipo_cont.desc_tipo_conto = 'Conto Base' AND tipo_trans.segno = '-' THEN trans.importo ELSE 0 END), 2), 0) AS importo_uscita_base,
    COALESCE(ROUND(SUM(CASE WHEN tipo_cont.desc_tipo_conto = 'Conto Business' AND tipo_trans.segno = '-' THEN trans.importo ELSE 0 END), 2), 0) AS importo_uscita_business,
    COALESCE(ROUND(SUM(CASE WHEN tipo_cont.desc_tipo_conto = 'Conto Privati' AND tipo_trans.segno = '-' THEN trans.importo ELSE 0 END), 2), 0) AS importo_uscita_privati,
    COALESCE(ROUND(SUM(CASE WHEN tipo_cont.desc_tipo_conto = 'Conto Famiglie' AND tipo_trans.segno = '-' THEN trans.importo ELSE 0 END), 2), 0) AS importo_uscita_famiglie
FROM banca.cliente cli
LEFT JOIN banca.conto cont ON cli.id_cliente = cont.id_cliente
LEFT JOIN banca.tipo_conto tipo_cont ON cont.id_tipo_conto = tipo_cont.id_tipo_conto
LEFT JOIN banca.transazioni trans ON cont.id_conto = trans.id_conto
LEFT JOIN banca.tipo_transazione tipo_trans ON trans.id_tipo_trans = tipo_trans.id_tipo_transazione
/*WHERE tipo_trans.segno = '-'*/
GROUP BY cli.id_cliente
ORDER BY cli.id_cliente;
SELECT * FROM banca.importo_uscita_conto;

/*
	11. Importo transato in entrata per tipologia di conto (un indicatore per tipo)
*/
DROP TABLE IF EXISTS banca.importo_entrata_conto;
CREATE TEMPORARY TABLE importo_entrata_conto AS
SELECT 
    cli.id_cliente,
    COALESCE(ROUND(SUM(CASE WHEN tipo_cont.desc_tipo_conto = 'Conto Base' AND tipo_trans.segno = '+' THEN trans.importo ELSE 0 END), 2), 0) AS importo_entrata_base,
    COALESCE(ROUND(SUM(CASE WHEN tipo_cont.desc_tipo_conto = 'Conto Business' AND tipo_trans.segno = '+' THEN trans.importo ELSE 0 END), 2), 0) AS importo_entrata_business,
    COALESCE(ROUND(SUM(CASE WHEN tipo_cont.desc_tipo_conto = 'Conto Privati' AND tipo_trans.segno = '+' THEN trans.importo ELSE 0 END), 2), 0) AS importo_entrata_privati,
    COALESCE(ROUND(SUM(CASE WHEN tipo_cont.desc_tipo_conto = 'Conto Famiglie' AND tipo_trans.segno = '+' THEN trans.importo ELSE 0 END), 2), 0) AS importo_entrata_famiglie
FROM banca.cliente cli
LEFT JOIN banca.conto cont ON cli.id_cliente = cont.id_cliente
LEFT JOIN banca.tipo_conto tipo_cont ON cont.id_tipo_conto = tipo_cont.id_tipo_conto
LEFT JOIN banca.transazioni trans ON cont.id_conto = trans.id_conto
LEFT JOIN banca.tipo_transazione tipo_trans ON trans.id_tipo_trans = tipo_trans.id_tipo_transazione
/*WHERE tipo_trans.segno = '+'*/
GROUP BY cli.id_cliente
ORDER BY cli.id_cliente;
SELECT * FROM banca.importo_entrata_conto;
    
/*
	UNISCO TUTTE LE TEMPORARY TABLE PER OTTENERE QUELLA FINALE
*/
DROP TABLE IF EXISTS banca.tabella_finale;
CREATE TEMPORARY TABLE tabella_finale AS
SELECT 
	cli.*,
    eta_temp.eta_cliente,
    tot_trans.n°_tot_transazioni_uscita,
    tot_trans.n°_tot_transazioni_entrata,
    tot_trans.somma_importi_uscita,
    tot_trans.somma_importi_entrata,
    tot_conti.n°_conti_totali_posseduti,
    conti_poss.n°_conti_base,
	conti_poss.n°_conti_business,
	conti_poss.n°_conti_privati,
	conti_poss.n°_conti_famiglie,
    tipo_trans_neg.Stipendio_uscita,
    tipo_trans_neg.Pensione_uscita,
    tipo_trans_neg.Dividendi_uscita,
    tipo_trans_neg.Acquisto_su_amazon_uscita,
    tipo_trans_neg.rata_mutuo_uscita,
    tipo_trans_neg.hotel_uscita,
    tipo_trans_neg.biglietto_aereo_uscita,
    tipo_trans_neg.supermercato_uscita,
    tipo_trans_pos.Stipendio_entrata,
    tipo_trans_pos.Pensione_entrata,
    tipo_trans_pos.Dividendi_entrata,
    tipo_trans_pos.Acquisto_su_amazon_entrata,
    tipo_trans_pos.rata_mutuo_entrata,
    tipo_trans_pos.hotel_entrata,
    tipo_trans_pos.biglietto_aereo_entrata,
    tipo_trans_pos.supermercato_entrata,
    imp_uscita_conto.importo_uscita_base,
    imp_uscita_conto.importo_uscita_business,
    imp_uscita_conto.importo_uscita_privati,
    imp_uscita_conto.importo_uscita_famiglie,
    imp_entrata_conto.importo_entrata_base,
    imp_entrata_conto.importo_entrata_business,
    imp_entrata_conto.importo_entrata_privati,
    imp_entrata_conto.importo_entrata_famiglie
FROM banca.cliente cli
LEFT JOIN banca.eta_temp eta_temp ON cli.id_cliente = eta_temp.id_cliente
LEFT JOIN banca.mumero_transazioni_totali tot_trans ON tot_trans.id_cliente = cli.id_cliente
LEFT JOIN banca.tot_conti_posseduti tot_conti ON tot_conti.id_cliente = cli.id_cliente
LEFT JOIN banca.n_conti_posseduti conti_poss ON conti_poss.id_cliente = cli.id_cliente
LEFT JOIN banca.trans_tipo_transazione_neg tipo_trans_neg ON tipo_trans_neg.id_cliente = cli.id_cliente
LEFT JOIN banca.trans_tipo_transazione_pos tipo_trans_pos ON tipo_trans_pos.id_cliente = cli.id_cliente
LEFT JOIN banca.importo_uscita_conto imp_uscita_conto ON imp_uscita_conto.id_cliente = cli.id_cliente
LEFT JOIN banca.importo_entrata_conto imp_entrata_conto ON imp_entrata_conto.id_cliente = cli.id_cliente;
SELECT * FROM banca.tabella_finale;


