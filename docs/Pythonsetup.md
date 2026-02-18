

```markdown
# Créer un Package Python avec Analyse de Dépendance

Ce guide explique comment structurer un package Python, gérer les dépendances et effectuer des analyses de dépendance. Il inclut également des instructions sur la configuration des environnements virtuels et des paramètres Git essentiels.

## Introduction aux Environnements Virtuels

Les environnements virtuels Python sont un moyen de créer des environnements isolés pour vos projets, ce qui permet de gérer les dépendances spécifiques à chaque projet sans conflit avec les autres projets. C'est une bonne pratique de toujours utiliser un environnement virtuel pour chaque nouveau projet.

### Bonnes Pratiques

- **Créer un nouvel environnement virtuel pour chaque projet** afin d'éviter les conflits de dépendances.
- **Activer l'environnement virtuel avant de travailler sur le projet**.
- **Utiliser un fichier `requirements.txt`** pour suivre les dépendances de votre projet.

## Configuration des Environnements Virtuels et Gestion des Proxies/Certificats

### Création d'un Environnement Virtuel

1. **Créer un environnement virtuel** :
   ```bash
   python -m venv env
   ```

2. **Activer l'environnement virtuel** :
   - Sur Windows :
     ```bash
     .\env\Scripts\activate
     ```
   - Sur macOS et Linux (avec zsh) :
     ```bash
     source env/bin/activate
     ```

### Configuration de `pip` avec un Proxy

1. **Configurer le proxy pour `pip`** :
   ```bash
   pip config set global.proxy http://proxy.example.com:8080
   ```

2. **Configurer le proxy dans un fichier `pip.ini` (Windows)** ou `pip.conf` (macOS/Linux) :
   - Sur Windows :
     Créez/modifiez le fichier `C:\Users\<VotreNomUtilisateur>\AppData\Roaming\pip\pip.ini` :
     ```ini
     [global]
     proxy = http://proxy.example.com:8080
     ```

   - Sur macOS/Linux :
     Créez/modifiez le fichier `~/.pip/pip.conf` ou `~/.config/pip/pip.conf` :
     ```ini
     [global]
     proxy = http://proxy.example.com:8080
     ```

### Gestion des Certificats d'Entreprise

1. **Ajouter un certificat d'entreprise** :
   Si vous avez besoin d'ajouter un certificat d'entreprise, placez le fichier du certificat (par exemple, `company.crt`) dans un répertoire accessible.

2. **Configurer `pip` pour utiliser le certificat** :
   - Ajoutez la ligne suivante à votre fichier `pip.ini` (Windows) ou `pip.conf` (macOS/Linux) :
     ```ini
     [global]
     cert = /path/to/company.crt
     ```

## Structure de Base du Projet

Votre projet doit suivre une structure de répertoires bien définie :

```
my_package/
│
├── my_package/
│   ├── __init__.py
│   ├── module1.py
│   └── module2.py
│
├── tests/
│   ├── __init__.py
│   ├── test_module1.py
│   └── test_module2.py
│
├── setup.py
├── requirements.txt
└── README.md
```

## Fichier `setup.py`

Ce fichier est essentiel pour définir les informations du package et ses dépendances.

```python
from setuptools import setup, find_packages

setup(
    name="my_package",
    version="0.1",
    packages=find_packages(),
    install_requires=[
        "numpy",
        "pandas",
        # Ajoutez d'autres dépendances ici
    ],
    author="Votre Nom",
    author_email="votre.email@example.com",
    description="Une courte description de votre package",
    long_description=open("README.md").read(),
    long_description_content_type="text/markdown",
    url="https://github.com/votre_repo/my_package",
    classifiers=[
        "Programming Language :: Python :: 3",
        "License :: OSI Approved :: MIT License",
        "Operating System :: OS Independent",
    ],
    python_requires='>=3.6',
)
```

## Fichier `requirements.txt`

Ce fichier liste toutes les dépendances de votre projet. Il est utile pour les environnements de développement et de production.

```
numpy
pandas
# Ajoutez d'autres dépendances ici
```

## Analyse de Dépendance

Pour analyser les dépendances, vous pouvez utiliser des outils comme `pip-tools` ou `pipdeptree`.

### Utilisation de `pip-tools`

1. **Installation de `pip-tools`** :
   ```bash
   pip install pip-tools
   ```

2. **Création de `requirements.txt` depuis `setup.py`** :
   ```bash
   pip-compile setup.py
   ```

### Utilisation de `pipdeptree`

1. **Installation de `pipdeptree`** :
   ```bash
   pip install pipdeptree
   ```

2. **Visualisation de l'arbre de dépendances** :
   ```bash
   pipdeptree
   ```

## Exemple Complet

1. **Création du package** :
   - Créez la structure de répertoires comme indiqué ci-dessus.
   - Remplissez les fichiers `__init__.py`, `module1.py`, `module2.py` avec votre code.

2. **Remplissez le `setup.py`** avec les détails de votre package et ses dépendances.

3. **Ajoutez les dépendances dans `requirements.txt`**.

4. **Installez les dépendances** :
   ```bash
   pip install -r requirements.txt
   ```

5. **Vérifiez les dépendances avec `pipdeptree`** :
   ```bash
   pipdept
