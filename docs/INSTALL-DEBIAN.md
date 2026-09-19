# Installazione GE360 n8n su Debian 13

## Installazione

```bash
cd ~
git clone https://github.com/milanstevic1992ts-gif/ge-360-n8n-.git
cd ge-360-n8n-
sudo bash install.sh
```

L'installer:

- installa Docker, Docker Compose, jq, git, curl, openssl e Python;
- genera automaticamente password PostgreSQL e chiave di cifratura n8n;
- avvia PostgreSQL + n8n;
- conserva dati e community nodes in volumi Docker persistenti;
- importa il pack `core`;
- crea l'indice della libreria di workflow;
- installa il comando globale `ge360ctl`.

## Comandi principali

```bash
ge360ctl status
ge360ctl logs -f
ge360ctl restart
ge360ctl backup
ge360ctl update
```

## Pack plug-and-play

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

I pack possono dichiarare community nodes in `pack.json`. GE360 aggiorna automaticamente
`N8N_COMMUNITY_PACKAGES`, riavvia n8n e importa i workflow presenti nel pack.

## Installare un pack da Git

```bash
ge360ctl pack add https://github.com/OWNER/REPO.git
ge360ctl pack enable ID_DEL_PACK
```

La repository deve avere `pack.json` nella root.

## Libreria workflow

Le migliaia di workflow importate dalle repository upstream non vengono caricate tutte in n8n.
Rimangono in una libreria ricercabile:

```bash
ge360ctl flow search suitecrm
ge360ctl flow search mautic
ge360ctl flow search wordpress
ge360ctl flow search ollama
```

Il risultato mostra il percorso relativo. Per importarne uno:

```bash
ge360ctl flow import 'PERCORSO/DEL/WORKFLOW.json'
```

Questo evita di riempire il database e l'interfaccia di n8n con migliaia di workflow inutilizzati.

## Ollama già installato sul Debian

Dal container n8n usa:

```text
http://host.docker.internal:11434
```

Non viene avviato un secondo Ollama.

## Accesso

Per impostazione predefinita n8n ascolta solo su:

```text
http://127.0.0.1:5678
```

È intenzionale. Per accesso remoto usa Tailscale o un reverse proxy HTTPS e aggiorna
`N8N_HOST`, `N8N_PROTOCOL` e `WEBHOOK_URL` nel file `.env`.

## Backup

```bash
ge360ctl backup
```

I workflow e le credenziali cifrate vengono salvati in `backups/`.

Non cancellare o cambiare `N8N_ENCRYPTION_KEY` dopo aver iniziato a salvare credenziali.
