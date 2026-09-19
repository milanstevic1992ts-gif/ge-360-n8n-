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

n8n è predisposto per essere controllato da Jarvis Code tramite la Public REST API ufficiale,
senza modificare direttamente PostgreSQL.

Dopo aver creato una API key in **Settings → n8n API**:

```bash
ge360ctl jarvis configure
ge360ctl jarvis test
```

Jarvis Code potrà poi usare:

```bash
n8n-agentctl workflow list
n8n-agentctl workflow get ID
n8n-agentctl workflow create workflow.json
n8n-agentctl workflow update ID workflow.json
n8n-agentctl workflow activate ID
n8n-agentctl workflow deactivate ID
n8n-agentctl execution list
n8n-agentctl execution get ID true
n8n-agentctl execution retry ID
n8n-agentctl audit
```

Per gli endpoint non ancora coperti dal wrapper:

```bash
n8n-agentctl request GET 'tags?limit=100'
```

Prima di update/delete viene creato automaticamente uno snapshot in `backups/jarvis/`.
La chiave API resta sotto `.secrets/` ed è esclusa da Git.

Contratto macchina: `jarvis/control-contract.json`  
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
