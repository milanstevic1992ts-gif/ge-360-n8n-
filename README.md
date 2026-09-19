# GE360 n8n Orchestrator

Repository centrale per l'automazione GE360 con n8n.

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

- `upstream/` — sorgenti open-source e raccolte workflow selezionate
- `integrations/` — nodi n8n e connettori utili a GE360
- `references/` — progetti utili non copiati per licenza, dimensione o perché mantenuti separatamente
- `scripts/` — sincronizzazione automatica delle sorgenti
- `docs/` — architettura e decisioni
- `.github/workflows/` — aggiornamento automatico delle sorgenti

## Regola di importazione

Le repository con licenza compatibile vengono sincronizzate nella repo.
Le raccolte molto grandi vengono filtrate conservando soprattutto workflow JSON, documentazione e licenze.
Le repository senza licenza esplicita o troppo grandi vengono mantenute come riferimenti esterni.

Non inserire credenziali, token, password o API key nei workflow versionati.

## Primo flusso GE360 previsto

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

La lista completa delle sorgenti è in `upstream/sources.tsv`.
