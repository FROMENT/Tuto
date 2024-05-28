"""
# Automatisation CI/CD avec Python et SQLite sur GitLab

Ce tutoriel décrit les étapes nécessaires pour configurer un pipeline CI/CD sur GitLab afin d'exécuter un script Python qui interagit avec une base de données SQLite.

## Pré-requis

- Un compte GitLab avec un projet configuré
- Git installé sur votre machine locale
- Python 3.9 installé sur votre machine locale

## Étapes de Mise en Place

### 1. Configurer le Fichier `.gitlab-ci.yml`

Le fichier `.gitlab-ci.yml` définit le pipeline CI/CD pour votre projet GitLab. Voici un exemple de configuration pour exécuter un script Python qui interagit avec une base de données SQLite.

```yaml
stages:
  - build
  - test

variables:
  PYTHON_VERSION: "3.9"

build:
  stage: build
  image: python:${PYTHON_VERSION}
  before_script:
    - pip install -r requirements.txt
  script:
    - python script.py

test:
  stage: test
  image: python:${PYTHON_VERSION}
  before_script:
    - pip install -r requirements.txt
  script:
    - python -m unittest discover -s tests

2. Préparer le Script Python

Votre script Python doit inclure le code nécessaire pour interagir avec une base de données SQLite. Voici un exemple de script (script.py) qui crée une table et insère des données.

import sqlite3

# Connect to SQLite database (or create it if it doesn't exist)
conn = sqlite3.connect('example.db')
c = conn.cursor()

# Create table
c.execute('''CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY, name TEXT, age INTEGER)''')

# Insert a row of data
c.execute("INSERT INTO users (name, age) VALUES ('Alice', 30)")

# Save (commit) the changes
conn.commit()

# Close the connection
conn.close()

3. Définir les Dépendances

Créez un fichier requirements.txt pour spécifier les dépendances Python. Pour SQLite, vous n’avez pas besoin de dépendances supplémentaires car il est inclus dans la bibliothèque standard de Python.

# requirements.txt

4. Ajouter des Tests Unitaires (Facultatif)

Si vous souhaitez ajouter des tests unitaires, vous pouvez le faire en créant des tests dans un répertoire tests/. Par exemple, un fichier de test tests/test_db.py :

import unittest
import sqlite3

class TestDatabase(unittest.TestCase):
    def test_insert_user(self):
        conn = sqlite3.connect('example.db')
        c = conn.cursor()
        c.execute("INSERT INTO users (name, age) VALUES ('Bob', 25)")
        conn.commit()
        c.execute("SELECT * FROM users WHERE name='Bob'")