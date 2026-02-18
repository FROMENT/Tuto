#!/bin/zsh
# Liste des modèles légers pour Mac M1/M2 16 Go

MODELS=(
  "deepseek-coder:6.7b-instruct"
  "codellama:7b"
  "openhermes:2.5b"
  "llama3.2:3b"          # remplacé llama4 inexistant
)

echo "📥 Téléchargement des modèles via Ollama..."
for model in "${MODELS[@]}"; do
  echo "→ $model"
  ollama pull "$model" || echo "❌ Erreur sur $model"
done
echo "✅ Tous les modèles téléchargés !"
