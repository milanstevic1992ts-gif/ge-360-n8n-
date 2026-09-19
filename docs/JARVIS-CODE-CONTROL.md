# Jarvis Code ↔ GE360 n8n

GE360 espone due livelli di controllo per Jarvis Code.

## 1. Canale principale: MCP

```text
http://127.0.0.1:3001/mcp
```

È fornito da `n8n-mcp` e consente a Jarvis di avere:
- conoscenza dei nodi n8n;
- ricerca di template;
- validazione di nodi e workflow;
- creazione workflow;
- aggiornamenti parziali/diff;
- autofix;
- test;
- lettura delle esecuzioni;
- versioni e rollback;
- accesso alla Public API n8n.

Avvio:

```bash
ge360ctl jarvis configure
ge360ctl jarvis mcp start
ge360ctl jarvis mcp info
```

Il file client pronto per Jarvis viene creato in:

```text
.secrets/jarvis-mcp-client.json
```

## 2. Canale fallback: REST

`n8n-agentctl` resta disponibile per operazioni deterministiche e recovery:

```bash
ge360ctl jarvis workflow list
ge360ctl jarvis workflow get ID
ge360ctl jarvis execution list
ge360ctl jarvis audit
```

## Workflow Guard

Ogni create/update via fallback REST viene validato prima del deploy.

Pipeline:

```text
JSON
  -> n8nac skills validate --strict
  -> n8n-doctor
  -> controllo struttura GE360
  -> deploy
```

Uso manuale:

```bash
ge360ctl jarvis guard managed-workflows/workflow.json
```

## Workflow-as-code

Il toolbox contiene `n8nac`:

```bash
ge360ctl jarvis as-code skills search "suitecrm lead"
ge360ctl jarvis as-code skills node-info httpRequest
```

## MCP ufficiale di n8n

n8n recente espone anche il proprio Instance-level MCP.

Dopo averlo abilitato nell'interfaccia n8n, puoi fornire il suo token al bridge:

```bash
ge360ctl jarvis mcp official-token
```

Questo abilita funzioni che la sola Public API non espone, incluse alcune operazioni di test e versioning native.

## Sicurezza

- MCP GE360 ascolta solo su `127.0.0.1`.
- API key e token restano in `.secrets/`.
- Jarvis non accede direttamente a PostgreSQL.
- Prima di update/delete REST viene creato uno snapshot.
- Le modifiche agentiche devono preferire patch parziali MCP.
- I workflow versionabili vivono in `managed-workflows/`.
