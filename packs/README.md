# GE360 Pack System

I pack sono moduli plug-and-play per n8n.

Ogni cartella contiene un `pack.json` e, opzionalmente, una cartella `workflows/`.

Comandi:

```bash
ge360ctl pack list
ge360ctl pack enable crm
ge360ctl pack enable ai
ge360ctl pack disable social
ge360ctl pack add https://github.com/OWNER/REPO.git
```

Quando abiliti un pack, GE360:
1. aggiorna la lista dei community nodes;
2. riavvia n8n se necessario;
3. importa i workflow del pack;
4. lascia le credenziali da configurare solo dentro n8n.

I pack disabilitati non cancellano automaticamente i workflow già importati: è una scelta intenzionale per evitare perdita di dati.
