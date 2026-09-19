#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
MANIFEST="$ROOT/upstream/sources.tsv"
TMP_ROOT="$(mktemp -d)"
trap 'rm -rf "$TMP_ROOT"' EXIT

if [[ ! -f "$MANIFEST" ]]; then
  echo "Manifest non trovato: $MANIFEST" >&2
  exit 1
fi

sync_reference() {
  local repo="$1" dest="$2" license="$3" purpose="$4"
  mkdir -p "$ROOT/$dest"
  cat > "$ROOT/$dest/UPSTREAM.md" <<EOF
# Upstream reference

- Repository: https://github.com/$repo
- License/status: $license
- Uso previsto in GE360: $purpose

Questo progetto e mantenuto come riferimento e non viene copiato automaticamente nel monorepo.
EOF
}

sync_mirror() {
  local repo="$1" dest="$2"
  local src="$TMP_ROOT/$(echo "$repo" | tr "/" "-")"
  rm -rf "$src" "$ROOT/$dest"
  git clone --depth 1 --filter=blob:none "https://github.com/$repo.git" "$src"
  rm -rf "$src/.git"
  mkdir -p "$(dirname "$ROOT/$dest")"
  mv "$src" "$ROOT/$dest"
}

sync_workflows() {
  local repo="$1" dest="$2"
  local src="$TMP_ROOT/$(echo "$repo" | tr "/" "-")"
  rm -rf "$src" "$ROOT/$dest"
  git clone --depth 1 --filter=blob:none "https://github.com/$repo.git" "$src"
  mkdir -p "$ROOT/$dest"

  (
    cd "$src"
    find . -type f \(
      -iname '*.json' -o
      -iname '*.md' -o
      -iname '*.yml' -o
      -iname '*.yaml' -o
      -iname 'LICENSE' -o
      -iname 'LICENSE.*' -o
      -iname 'COPYING' -o
      -iname 'NOTICE'
    \) -print0 | rsync -a --from0 --files-from=- ./ "$ROOT/$dest/"
  )

  cat > "$ROOT/$dest/GE360-UPSTREAM.md" <<EOF
# GE360 upstream snapshot

Origine: https://github.com/$repo

Per contenere le dimensioni del repository, questa copia conserva workflow JSON,
documentazione, file YAML e informazioni di licenza. Asset e file non necessari
all'importazione n8n vengono esclusi.
EOF
}

tail -n +2 "$MANIFEST" | while IFS=$'\t' read -r mode upstream_repo destination license purpose; do
  [[ -z "${upstream_repo:-}" ]] && continue
  echo "==> $mode $upstream_repo -> $destination"

  case "$mode" in
    mirror)
      sync_mirror "$upstream_repo" "$destination"
      ;;
    workflows)
      sync_workflows "$upstream_repo" "$destination"
      ;;
    reference)
      sync_reference "$upstream_repo" "$destination" "$license" "$purpose"
      ;;
    *)
      echo "Modalita sconosciuta: $mode" >&2
      exit 1
      ;;
  esac
done

echo "Sincronizzazione completata."
