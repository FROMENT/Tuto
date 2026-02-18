# Tuto
Tuto divers (starter) 
# 🛠️ Tuto Divers – Boîte à outils Pascal

Collection de tutoriels, scripts et notes techniques (VBA, Python, Docker, Ollama, CI/CD, Jira…).

## 📁 Structure du dépôt
- `vba/` → Macros Outlook/Excel
- `python/` → Scripts Fortify, setup, etc.
- `docker/` → docker-compose + scripts Ollama
- `docs/` → Tous les .md
- `scripts/` → Shell divers

## 🚀 Scripts principaux

### Docker + Ollama
- `docker-compose.yml` → Ollama + Open WebUI + Watchtower
- `update_ollama_webui.sh` → Mise à jour en 1 clic
- `get.sh` → Téléchargement modèles légers M1/M2

### VBA Emailing
- `sendmail.vba` → Envoi en masse avec HTML + pièces jointes depuis tableaux Excel

### Python
- `demo.py` → Rapport hebdo vulnérabilités Fortify → CSV

## Installation rapide
```bash
git clone https://github.com/FROMENT/Tuto.git
cd Tuto
