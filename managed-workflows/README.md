# Managed Workflows

Questa cartella è la sorgente versionabile dei workflow GE360 gestiti da Jarvis Code.

Regola consigliata:

```text
Jarvis crea/modifica file qui
  -> workflow-guard
  -> diff Git
  -> deploy tramite n8n-mcp o n8n-agentctl
  -> test
  -> commit se il test passa
```

Non inserire segreti nei JSON. Le credenziali devono rimanere dentro n8n.

Per validare:

```bash
ge360ctl jarvis guard managed-workflows/mio-workflow.json
```

Per il fallback REST:

```bash
ge360ctl jarvis workflow create managed-workflows/mio-workflow.json
ge360ctl jarvis workflow update WORKFLOW_ID managed-workflows/mio-workflow.json
```

Per modifiche intelligenti e parziali, Jarvis Code deve preferire n8n-mcp.
