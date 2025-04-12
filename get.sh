#!/bin/zsh

# Liste des modèles adaptés à un Mac M1 Pro avec 16 Go de RAM
MODELS=(
  "deepseek-coder:6.7b-instruct"
  "codellama:7b"
  "openhermes:2.5b"
  "llama4:17b"
)

echo "🚀 Téléchargement des modèles via Ollama..."

for model in "${MODELS[@]}"; do
  echo "📥 Téléchargement de $model..."
  ollama pull "$model"
done

echo "✅ Tous les modèles ont été téléchargés avec succès."