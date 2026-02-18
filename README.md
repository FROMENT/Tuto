# Tuto — Dépôt réorganisé

Ce dépôt regroupe des ressources de démonstration (documentation, scripts VBA, exemples Python/YAML et éléments Docker) avec une structure claire et maintenable.

## Structure

```text
.
├── docs/      # Documentation Markdown
├── vba/       # Macros et scripts VBA
├── python/    # Scripts Python et jeux de configuration YAML
├── docker/    # Stack Docker, scripts d'initialisation et doc associée
├── LICENSE
└── README.md
```

## Utilisation rapide

### 1) Documentation
- Consultez les guides dans `docs/`.
- Les anciens fichiers mal nommés ont été corrigés (ex: `contrat.hml` → `docs/contrat.md`).

### 2) Python
```bash
python3 python/demo.py
```

### 3) Docker
```bash
cd docker
./get.sh
```

Le script `docker/get.sh` valide les prérequis et lance la stack définie dans `docker/docker-compose.yml`.

## Conventions de contenu

- **Documentation** : tous les fichiers `.md` (hors README racine) sont centralisés dans `docs/`.
- **VBA** : tous les `.vba` sont dans `vba/`.
- **Python/YAML** : scripts et configurations de démonstration sont dans `python/`.
- **Docker** : orchestration et scripts systèmes dans `docker/`.

## Objectif de cette réorganisation

- Améliorer la lisibilité du dépôt.
- Réduire le bruit à la racine.
- Faciliter l'onboarding et l'automatisation CI/CD.

## Licence

Voir le fichier `LICENSE`.
0d62d937efe06bf563d02ba0d23680be10f7fb81
