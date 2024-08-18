# Analisi-di-un-sistema-bancario

Analisi di un Sistema Bancario

# Obiettivo del progetto
Creare una tabella denormalizzata che contenga indicatori comportamentali sul cliente, calcolati sulla base delle transazioni e del possesso prodotti. 
Lo scopo è creare le feature per un possibile modello di machine learning supervisionato.


# Database 
Il database è costituito dalle seguenti tabelle:
## cliente
| id_cliente  | nome | cognome | data_nascita |
| - | - | - | - |
| 0  | Giada  | Romano | 1958-07-12 |
| 1  | Stefano  | Rossi | 1958-07-12 |

## conto
| id_conto  | id_cliente | id_tipo_conto |
| - | - | - |
| 0  | 197  | 3 |
| 1  | 124  | 3 |

## tipo_conto
## tipo_transazione
## transazioni
| data  | id_tipo_trans | importo | id_conto |
| - | - | - | - |
| 1958-07-12 | 0  | 31.3495748573759 | 238 |
| 1958-07-12 | 2  | 216.463828474664 | 81 |

# Indicatori da creare

Ogni indicatore va riferito al singolo id_cliente.
- Età
- Numero di transazioni in uscita su tutti i conti
- Numero di transazioni in entrata su tutti i conti
- Importo transato in uscita su tutti i conti
- Importo transato in entrata su tutti i conti
- Numero totale di conti posseduti
- Numero di conti posseduti per tipologia (un indicatore per tipo)
- Numero di transazioni in uscita per tipologia (un indicatore per tipo)
- Numero di transazioni in entrata per tipologia (un indicatore per tipo)
- Importo transato in uscita per tipologia di conto (un indicatore per tipo)
- Importo transato in entrata per tipologia di conto (un indicatore per tipo)
