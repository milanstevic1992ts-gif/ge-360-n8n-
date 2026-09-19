# Template pack GE360

1. Copia questa cartella dentro `packs/` oppure crea una repository Git dedicata.
2. Modifica `pack.json`.
3. Metti i workflow n8n JSON dentro `workflows/`.
4. Attiva con:

```bash
ge360ctl pack enable my-pack
```

Per distribuire un pack come repository separata, lascia `pack.json` nella root e installalo con:

```bash
ge360ctl pack add https://github.com/OWNER/REPO.git
```
