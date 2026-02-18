#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_FILE="${SCRIPT_DIR}/docker-compose.yml"

if ! command -v docker >/dev/null 2>&1; then
  echo "Erreur: Docker n'est pas installé ou n'est pas dans le PATH." >&2
  exit 1
fi

if docker compose version >/dev/null 2>&1; then
  COMPOSE_CMD=(docker compose)
elif command -v docker-compose >/dev/null 2>&1; then
  COMPOSE_CMD=(docker-compose)
else
  echo "Erreur: Docker Compose n'est pas disponible (docker compose ou docker-compose)." >&2
  exit 1
fi

echo "[INFO] Fichier compose: ${COMPOSE_FILE}"
echo "[INFO] Commande compose: ${COMPOSE_CMD[*]}"

"${COMPOSE_CMD[@]}" -f "${COMPOSE_FILE}" pull
"${COMPOSE_CMD[@]}" -f "${COMPOSE_FILE}" up -d

cat <<MSG
[OK] Stack lancée.
- Open WebUI: http://localhost:3000
- Ollama API: http://localhost:11434
MSG
