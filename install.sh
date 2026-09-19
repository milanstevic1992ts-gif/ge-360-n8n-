#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$ROOT/.env"
COMPOSE_FILE="$ROOT/deploy/compose.yml"

log(){ printf '\033[1;36m[GE360]\033[0m %s\n' "$*"; }
die(){ printf '\033[1;31m[GE360 ERROR]\033[0m %s\n' "$*" >&2; exit 1; }

if [[ ! -f "$ROOT/.env.example" || ! -f "$COMPOSE_FILE" ]]; then
  die "Esegui install.sh dalla repository GE360 n8n completa."
fi

if [[ -r /etc/os-release ]]; then
  . /etc/os-release
  if [[ "${ID:-}" != "debian" ]]; then
    log "Sistema rilevato: ${PRETTY_NAME:-sconosciuto}. L'installer è ottimizzato per Debian 13."
  fi
fi

if [[ "${EUID}" -eq 0 ]]; then
  SUDO=""
  TARGET_USER="${SUDO_USER:-root}"
else
  command -v sudo >/dev/null 2>&1 || die "Serve sudo per installare Docker e i pacchetti."
  SUDO="sudo"
  TARGET_USER="$USER"
fi

log "Installazione dipendenze Debian..."
$SUDO apt-get update
$SUDO apt-get install -y ca-certificates curl git jq openssl python3

# Non mischiare i pacchetti Docker Debian con Docker CE/plugin ufficiali.
# Debian 13 può avere docker-compose/docker-buildx che collidono con
# docker-compose-plugin/docker-buildx-plugin già installati.
if command -v docker >/dev/null 2>&1; then
  log "Docker già presente: non reinstallo docker.io/docker-compose."
else
  log "Docker non trovato: installo lo stack Debian senza pacchetti raccomandati in conflitto."
  $SUDO apt-get install -y --no-install-recommends docker.io
fi

$SUDO systemctl enable --now docker

if ! docker compose version >/dev/null 2>&1 && ! $SUDO docker compose version >/dev/null 2>&1; then
  die "Docker Compose v2 non disponibile. Installa/riattiva docker-compose-plugin e rilancia install.sh."
fi

if id "$TARGET_USER" >/dev/null 2>&1 && [[ "$TARGET_USER" != "root" ]]; then
  $SUDO usermod -aG docker "$TARGET_USER" || true
fi

mkdir -p "$ROOT/.state" "$ROOT/backups" "$ROOT/packs-extra" "$ROOT/.secrets"

if [[ ! -f "$ENV_FILE" ]]; then
  log "Genero configurazione e segreti locali..."
  cp "$ROOT/.env.example" "$ENV_FILE"
  PG_PASS="$(openssl rand -hex 24)"
  ENC_KEY="$(openssl rand -hex 32)"
  python3 - "$ENV_FILE" "$PG_PASS" "$ENC_KEY" <<'PY'
from pathlib import Path
import sys
p=Path(sys.argv[1])
pg=sys.argv[2]
enc=sys.argv[3]
text=p.read_text()
text=text.replace("POSTGRES_PASSWORD=CHANGE_ME", f"POSTGRES_PASSWORD={pg}")
text=text.replace("N8N_ENCRYPTION_KEY=CHANGE_ME", f"N8N_ENCRYPTION_KEY={enc}")
p.write_text(text)
PY
  chmod 600 "$ENV_FILE"
else
  log ".env esistente: non modifico password o chiave di cifratura."
fi

if [[ ! -f "$ROOT/.state/enabled-packs.txt" ]]; then
  printf 'core\n' > "$ROOT/.state/enabled-packs.txt"
fi

$SUDO ln -sf "$ROOT/bin/ge360ctl" /usr/local/bin/ge360ctl
$SUDO ln -sf "$ROOT/bin/n8n-agentctl" /usr/local/bin/n8n-agentctl
chmod +x "$ROOT/bin/ge360ctl" "$ROOT/bin/n8n-agentctl" "$ROOT/bin/workflow-guard" "$ROOT/install.sh"

log "Avvio PostgreSQL + n8n..."
"$ROOT/bin/ge360ctl" start

log "Attendo healthcheck..."
for _ in $(seq 1 90); do
  if "$ROOT/bin/ge360ctl" health >/dev/null 2>&1; then
    break
  fi
  sleep 2
done

"$ROOT/bin/ge360ctl" health >/dev/null 2>&1 || {
  "$ROOT/bin/ge360ctl" logs --tail 100 || true
  die "n8n non risponde al healthcheck."
}

"$ROOT/bin/ge360ctl" pack sync
"$ROOT/bin/ge360ctl" pack import core || true
"$ROOT/bin/ge360ctl" flow index || true

if [[ "$TARGET_USER" != "root" ]]; then
  TARGET_GROUP="$(id -gn "$TARGET_USER")"
  chown "$TARGET_USER:$TARGET_GROUP" "$ENV_FILE" || true
  chown -R "$TARGET_USER:$TARGET_GROUP" "$ROOT/.state" "$ROOT/backups" "$ROOT/packs-extra" "$ROOT/.secrets" || true
fi

PORT="$(awk -F= '$1=="N8N_PORT"{print $2}' "$ENV_FILE" | tail -1)"
BIND="$(awk -F= '$1=="N8N_BIND_ADDRESS"{print $2}' "$ENV_FILE" | tail -1)"

log "Installazione completata."
echo
echo "n8n locale: http://127.0.0.1:${PORT:-5678}"
echo "Comandi:"
echo "  ge360ctl status"
echo "  ge360ctl pack list"
echo "  ge360ctl flow search suitecrm"
echo "  ge360ctl pack enable crm"
echo "  ge360ctl jarvis configure   # collega Jarvis Code alla Public API n8n"
echo
if [[ "$BIND" == "127.0.0.1" ]]; then
  echo "Per sicurezza n8n ascolta solo in locale. Puoi pubblicarlo tramite Tailscale/reverse proxy."
fi
if [[ "$TARGET_USER" != "root" ]]; then
  echo "L'utente $TARGET_USER è stato aggiunto al gruppo docker; al prossimo login potrà usare Docker senza sudo."
fi
