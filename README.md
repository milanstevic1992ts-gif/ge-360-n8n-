# GE360 n8n Orchestrator

Repository centrale per l'automazione GE360 con n8n.

## Installazione rapida su Debian 13

```bash
cd ~
git clone https://github.com/milanstevic1992ts-gif/ge-360-n8n-.git
cd ge-360-n8n-
sudo bash install.sh
```

Al termine n8n è disponibile localmente su:

```text
http://127.0.0.1:5678
```

Il runtime usa **n8n + PostgreSQL**. Ollama non viene duplicato: se è già installato sul Debian,
n8n può raggiungerlo tramite `http://host.docker.internal:11434`.

Guida completa: [docs/INSTALL-DEBIAN.md](docs/INSTALL-DEBIAN.md)

## Plug-and-play: GE360 Packs

```bash
ge360ctl pack list
ge360ctl pack enable crm
ge360ctl pack enable marketing
ge360ctl pack enable ai
ge360ctl pack enable wordpress
ge360ctl pack enable leadgen
ge360ctl pack enable analytics
ge360ctl pack enable social
```

Un pack può contenere:

- community nodes n8n;
- workflow JSON;
- requisiti e documentazione;
- integrazioni specifiche GE360.

Per aggiungere un modulo esterno:

```bash
ge360ctl pack add https://github.com/OWNER/REPO.git
ge360ctl pack enable ID_DEL_PACK
```

Il template per crearne di nuovi è in `pack-template/`.

## Libreria workflow

Non carichiamo migliaia di workflow dentro l'interfaccia di n8n. Restano disponibili come
libreria ricercabile:

```bash
ge360ctl flow search suitecrm
ge360ctl flow search mautic
ge360ctl flow search wordpress
ge360ctl flow search ollama
```

Poi importi solo quello che serve:

```bash
ge360ctl flow import 'PERCORSO/DEL/WORKFLOW.json'
```

## Gestione

```bash
ge360ctl status
ge360ctl logs -f
ge360ctl restart
ge360ctl backup
ge360ctl update
```

## Controllo da Jarvis Code

Jarvis Code ha due canali:

1. **n8n-mcp** — canale principale intelligente per ricerca nodi, validazione, patch parziali, autofix, test, versioni e rollback.
2. **n8n-agentctl / REST** — fallback deterministico per recovery e automazioni semplici.

Dopo aver creato una API key in **Settings → n8n API**:

```bash
ge360ctl jarvis configure
ge360ctl jarvis mcp start
ge360ctl jarvis mcp info
```

Il bridge MCP ascolta solo su:

```text
http://127.0.0.1:3001/mcp
```

La configurazione client pronta per Jarvis viene generata in:

```text
.secrets/jarvis-mcp-client.json
```

### Workflow Guard

```bash
ge360ctl jarvis guard managed-workflows/mio-workflow.json
```

Il guard esegue:

```text
n8nac validate --strict
        ↓
n8n-doctor
        ↓
controllo GE360
        ↓
PASS / STOP
```

Ogni create/update tramite fallback REST passa automaticamente da questo controllo.

### Workflow-as-code

```bash
ge360ctl jarvis as-code skills search "suitecrm lead"
ge360ctl jarvis as-code skills node-info httpRequest
```

I workflow gestiti da Jarvis possono essere conservati e versionati in `managed-workflows/`.

Componenti selezionati: `docs/UPSTREAM-AGENT-INTEGRATIONS.md`  
Contratto macchina: `jarvis/control-contract.json`  
Policy agente: `jarvis/policy.json`  
Documentazione: `docs/JARVIS-CODE-CONTROL.md`


## Obiettivo

Usare n8n come orchestratore fra:

- GE360 Prospex
- SuiteCRM
- Mautic
- GE360 Jarvis / Ollama
- WordPress
- Facebook / Instagram
- Google Business / Google Workspace
- GE360 Analitica
- email e campagne marketing
- raccolta e qualificazione lead

## Struttura

- `deploy/` — runtime Docker Compose
- `packs/` — moduli GE360 plug-and-play
- `packs-extra/` — pack esterni installati localmente
- `pack-template/` — modello per nuovi moduli
- `upstream/` — sorgenti open-source e raccolte workflow selezionate
- `integrations/` — nodi n8n e connettori utili a GE360
- `references/` — progetti mantenuti come riferimenti
- `bin/ge360ctl` — controller del runtime
- `bin/n8n-agentctl` — superficie di controllo n8n per Jarvis Code
- `bin/workflow-guard` — validazione nativa + lint semantico prima del deploy
- `managed-workflows/` — sorgente Git dei workflow gestiti da Jarvis
- `deploy/compose.jarvis.yml` — runtime MCP/toolbox opzionale
- `jarvis/control-contract.json` — contratto macchina per l'integrazione Jarvis
- `scripts/` — sincronizzazione delle sorgenti
- `docs/` — architettura e installazione
- `.github/workflows/` — validazione e aggiornamenti automatici

## Sicurezza

`.env`, backup, stato locale e pack aggiunti localmente sono esclusi da Git.
Non inserire credenziali, password, token o API key nei workflow versionati.

## Pipeline GE360

```text
Prospex
  -> n8n
  -> deduplica / normalizzazione
  -> SuiteCRM
  -> Jarvis/Ollama classifica il lead
  -> Mautic assegna segmento/campagna
  -> eventi apertura/click/risposta
  -> n8n aggiorna SuiteCRM
  -> GE360 Analitica
```

La lista completa delle sorgenti upstream è in `upstream/sources.tsv`.
