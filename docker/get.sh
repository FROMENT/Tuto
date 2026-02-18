#!/usr/bin/env bash
set -euo pipefail

MODELS=(
  "deepseek-coder:6.7b-instruct"
  "codellama:7b"
  "openhermes:2.5b"
  "llama3.2:3b"
)

pull_with_local_ollama() {
  for model in "${MODELS[@]}"; do
    echo "→ $model"
    ollama pull "$model"
  done
}

pull_with_docker() {
  if ! docker ps --format '{{.Names}}' | grep -qx 'ollama'; then
    echo "❌ Le conteneur 'ollama' n'est pas démarré. Lancez d'abord : docker compose -f docker/docker-compose.yml up -d"
    exit 1
  fi

  for model in "${MODELS[@]}"; do
    echo "→ $model"
    docker exec ollama ollama pull "$model"
  done
}

echo "📥 Téléchargement des modèles Ollama recommandés..."
if command -v ollama >/dev/null 2>&1; then
  pull_with_local_ollama
elif command -v docker >/dev/null 2>&1; then
  pull_with_docker
else
  echo "❌ Ni ollama CLI ni Docker ne sont disponibles sur cette machine."
  exit 1
fi

echo "✅ Téléchargement terminé."
