# Jarvis Code ↔ GE360 n8n

GE360 n8n è predisposto per essere controllato da un agente esterno come Jarvis Code tramite la **Public REST API ufficiale di n8n**, senza accesso diretto al database PostgreSQL.

## Architettura

```text
Jarvis Code
   |
   |  n8n-agentctl / REST API
   v
http://127.0.0.1:5678/api/v1
   |
   v
n8n
   |
   +--> PostgreSQL
   +--> SuiteCRM
   +--> Mautic
   +--> WordPress
   +--> Prospex
   +--> Ollama / Jarvis
```

## Cosa può controllare Jarvis Code

Con la chiave API corretta può:

- elencare e leggere workflow;
- creare workflow;
- modificare workflow;
- pubblicare/attivare e disattivare workflow;
- eliminare workflow;
- leggere esecuzioni e relativi errori/dati;
- ritentare o fermare esecuzioni;
- eseguire l'audit di sicurezza;
- usare qualsiasi altro endpoint disponibile nella Public API tramite `request`.

## Primo collegamento

Dopo aver creato l'account owner n8n:

1. Apri n8n.
2. Vai in **Settings → n8n API**.
3. Crea una API key con etichetta, per esempio `Jarvis Code`.
4. Salvala sul Debian:

```bash
ge360ctl jarvis configure
```

La chiave viene salvata in:

```text
.secrets/jarvis-n8n.env
```

con permessi locali e la cartella è esclusa da Git.

## Verifica

```bash
ge360ctl jarvis test
```

## Comandi principali per Jarvis Code

```bash
n8n-agentctl workflow list
n8n-agentctl workflow get WORKFLOW_ID
n8n-agentctl workflow create /percorso/workflow.json
n8n-agentctl workflow update WORKFLOW_ID /percorso/workflow.json
n8n-agentctl workflow activate WORKFLOW_ID
n8n-agentctl workflow deactivate WORKFLOW_ID
n8n-agentctl workflow delete WORKFLOW_ID
```

Esecuzioni:

```bash
n8n-agentctl execution list 'limit=50&status=error'
n8n-agentctl execution get EXECUTION_ID true
n8n-agentctl execution retry EXECUTION_ID
n8n-agentctl execution stop EXECUTION_ID
```

Audit:

```bash
n8n-agentctl audit
```

Accesso completo alla Public API:

```bash
n8n-agentctl request GET 'tags?limit=100'
n8n-agentctl request GET 'credentials'
```

Per richieste POST/PUT/PATCH con body:

```bash
n8n-agentctl request POST 'endpoint' body.json
```

## Snapshot automatici

Prima di ogni modifica o eliminazione eseguita tramite il controller, il workflow corrente viene salvato sotto:

```text
backups/jarvis/YYYYMMDD-HHMMSS/
```

Questo permette a Jarvis Code di ripristinare rapidamente una versione precedente.

## API key e permessi

Su n8n Enterprise la chiave può essere limitata con scope. Per il controllo workflow servono almeno:

```text
workflow:create
workflow:read
workflow:list
workflow:update
workflow:delete
workflow:activate
execution:read
execution:list
execution:retry
execution:stop
securityAudit:generate
```

Aggiungi altri scope solo quando servono, ad esempio community packages o credentials.

Sulle installazioni non-Enterprise le API key hanno i permessi dell'account che le ha create.

## Regola GE360

Jarvis Code deve controllare n8n tramite API/CLI, **non modificando direttamente PostgreSQL**.

Questo mantiene:
- validazione n8n;
- gestione versioni;
- log delle esecuzioni;
- possibilità di rollback;
- compatibilità con futuri aggiornamenti.
