# Architettura GE360 + n8n

## Ruolo di n8n

n8n e l'orchestratore. Non deve sostituire SuiteCRM, Mautic, Prospex o Jarvis: deve collegarli e governare gli eventi fra i servizi.

## Pipeline prioritaria

1. Prospex genera o aggiorna un contatto.
2. n8n normalizza email, telefono, ragione sociale e categoria.
3. n8n controlla i duplicati.
4. SuiteCRM riceve il lead come fonte dati principale.
5. Jarvis/Ollama classifica lead, settore, priorita e prossimo passo.
6. Mautic assegna segmento e campagna.
7. Eventi email e interazioni ritornano a n8n.
8. SuiteCRM viene aggiornato.
9. GE360 Analitica riceve KPI e stato funnel.

## Pipeline sito

WordPress / quiz / form -> webhook n8n -> SuiteCRM -> Jarvis -> Mautic -> follow-up.

## Pipeline social

Contenuto -> Jarvis -> approvazione -> n8n -> social publisher -> Meta/social -> metriche -> GE360 Analitica.

## Principi

- credenziali solo nelle Credentials di n8n o secret manager;
- nessuna API key nei JSON versionati;
- idempotenza e deduplica prima della scrittura CRM;
- log di esecuzione e gestione errori;
- retry controllati;
- webhook firmati dove possibile;
- ogni workflow deve avere proprietario, scopo e versione.
