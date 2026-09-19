# Componenti agentici integrati

GE360 usa alcuni componenti open source selezionati invece di reinventare funzionalità già mature.

## n8n-mcp

- Upstream: `czlonkowski/n8n-mcp`
- Licenza: MIT
- Versione GE360: `2.87.0`
- Uso: MCP per Jarvis Code, conoscenza nodi, validazione, patch parziali, autofix, test, versioni e controllo n8n.

Viene eseguito come container opzionale e ascolta solo su `127.0.0.1`.

## n8n-workflow-validator

- Upstream: `yigitkonur/n8n-workflow-validator`
- Licenza: MIT
- Versione GE360: `1.4.2`
- Uso: validazione dei workflow usando il motore nativo n8n.

## n8n-doctor

- Upstream: `Vojtaupan/n8n-doctor`
- Licenza: MIT
- Versione GE360: `0.1.0`
- Uso: analisi statica di difetti logici e production-readiness che possono superare la validazione schema.

## n8n-as-code / n8nac

- Upstream: `EtienneLescot/n8n-as-code`
- Licenza: MIT
- Versione CLI GE360: `2.7.0`
- Uso: workflow-as-code, conoscenza dei nodi, diff/sync e strumenti agent-friendly.

## GitOps

Abbiamo adottato i pattern migliori di `n8n-gitops/n8n-gitops` (MIT): validazione prima del deploy,
dry-run concettuale, versionamento Git e rollback. Non viene installato come secondo orchestratore:
GE360 mantiene un solo controller, `ge360ctl`, per evitare due fonti di verità.

## Principio

```text
Jarvis Code
  -> n8n-mcp (intelligente)
  -> workflow-guard (validator + doctor)
  -> n8n
  -> execution/test
  -> version/snapshot/rollback

n8n-agentctl rimane fallback deterministico REST.
```
