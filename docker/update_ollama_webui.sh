#!/bin/zsh
cd /Users/pascalfroment/ollama || exit 1

echo "📦 Mise à jour des images..."
docker compose pull

echo "🛑 Arrêt propre des conteneurs..."
docker compose down

echo "🚀 Redémarrage des services avec les nouvelles versions..."
docker compose up -d

echo "✅ Mise à jour terminée."