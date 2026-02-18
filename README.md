# Tuto

Boîte à outils technique regroupant des scripts et notes pratiques autour de **VBA**, **Python**, **Docker**, **CI/CD** et divers sujets d'automatisation.

## Structure du dépôt

```text
.
├── docker/   # Stack Docker/Ollama + scripts shell et notes associées
├── docs/     # Documentation technique et tutoriels Markdown
├── python/   # Scripts Python et configurations YAML
├── vba/      # Macros VBA (Outlook, Excel, Word)
├── LICENSE
└── README.md
```

## Utilisation rapide

### 1) Cloner le dépôt

```bash
git clone https://github.com/FROMENT/Tuto.git
cd Tuto
```

### 2) Démarrer la stack Docker (Ollama + Open WebUI)

Depuis la racine du dépôt :

```bash
docker compose -f docker/docker-compose.yml up -d
```

Services exposés :
- **Open WebUI** : http://localhost:3000
- **Ollama API** : http://localhost:11434

### 3) Télécharger des modèles Ollama recommandés

```bash
./docker/get.sh
```

> Le script détecte automatiquement si `ollama` est disponible en local, sinon il utilise le conteneur `ollama` (si démarré).

## Détails par dossier

### `docs/`
Contient les notes et tutoriels (Jira, CI/CD, pagination, SDK, mail, Spring, etc.).

### `vba/`
Contient les macros VBA pour automatiser des envois mail et documents Office.

### `python/`
Contient :
- `demo.py` (script Python de démonstration),
- des fichiers YAML de configuration (`expertsset*.yaml`, `myprompts.yaml`, etc.).

### `docker/`
Contient :
- `docker-compose.yml` : stack locale prête à l'emploi,
- `get.sh` : téléchargement automatisé de modèles Ollama,
- `update_ollama_webui.sh` : script de mise à jour,
- `createdocker.md` : notes Docker/Artifactory.

## Prérequis

- Git
- Docker + Docker Compose plugin
- (optionnel) Ollama CLI installé localement

## Bonnes pratiques

- Conserver les tutoriels dans `docs/`.
- Ajouter les scripts shell liés à la stack dans `docker/`.
- Ajouter les macros Office dans `vba/`.
- Ajouter les scripts Python/configs dans `python/`.

## Licence

Ce projet est distribué sous la licence présente dans le fichier `LICENSE`.
