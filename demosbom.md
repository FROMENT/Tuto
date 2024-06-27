Voici le script complet pour `get_sbom.py`, incluant toutes les étapes nécessaires pour récupérer les SBOM de Nexus IQ, désérialiser les données et les stocker dans une base de données SQLite :

### get_sbom.py

```python
import nexus_iq_sdk
from nexus_iq_sdk.rest import ApiException
import sqlite3

# Configuration de l'API
configuration = nexus_iq_sdk.Configuration()
configuration.host = "https://your-nexus-iq-server.com"
configuration.username = "your_username"
configuration.password = "your_password"

# Création d'un client API
api_client = nexus_iq_sdk.ApiClient(configuration)
applications_api = nexus_iq_sdk.ApplicationsApi(api_client)
reports_api = nexus_iq_sdk.ReportsApi(api_client)

# Fonction pour récupérer les applications
def get_applications():
    try:
        applications = applications_api.get_applications()
        return applications.applications
    except ApiException as e:
        print(f"Exception when calling ApplicationsApi->get_applications: {e}")
        return []

# Fonction pour récupérer le SBOM d'une application
def get_sbom(application_id):
    try:
        reports = reports_api.get_reports(application_id)
        if reports.reports:
            latest_report_id = reports.reports[0].report_id
            sbom = reports_api.get_report_details(latest_report_id)
            return sbom
        else:
            return None
    except ApiException as e:
        print(f"Exception when calling ReportsApi->get_report_details: {e}")
        return None

# Fonction pour initialiser la base de données SQLite
def init_db():
    conn = sqlite3.connect('sbom.db')
    cursor = conn.cursor()
    cursor.execute('''CREATE TABLE IF NOT EXISTS components
                      (application_id TEXT, component_name TEXT, component_version TEXT, framework TEXT)''')
    conn.commit()
    conn.close()

# Fonction pour insérer les données dans la base de données
def insert_into_db(application_id, components):
    conn = sqlite3.connect('sbom.db')
    cursor = conn.cursor()
    for component in components:
        name = component['componentIdentifier']['coordinates'].get('name', 'Unknown')
        version = component['componentIdentifier']['coordinates'].get('version', 'Unknown')
        framework = component['componentIdentifier']['coordinates'].get('framework', 'Unknown')
        cursor.execute('''INSERT INTO components (application_id, component_name, component_version, framework)
                          VALUES (?, ?, ?, ?)''',
                       (application_id, name, version, framework))
    conn.commit()
    conn.close()

def main():
    init_db()
    applications = get_applications()
    for app in applications:
        sbom = get_sbom(app.id)
        if sbom:
            components = sbom.components
            insert_into_db(app.id, components)
        print(f"Processed SBOM for application {app.name}")

if __name__ == "__main__":
    main()
```

### Explication des Fonctions

- **get_applications()**: Récupère la liste des applications depuis le serveur Nexus IQ.
- **get_sbom(application_id)**: Récupère le dernier SBOM pour une application donnée en utilisant l'ID de l'application.
- **init_db()**: Initialise une base de données SQLite avec une table pour les composants.
- **insert_into_db(application_id, components)**: Insère les composants d'un SBOM dans la base de données SQLite.
- **main()**: Point d'entrée du script, qui initialise la base de données, récupère les applications, extrait les SBOM et insère les composants dans la base de données.

### Utilisation

1. **Configurer l'accès à l'API Nexus IQ**:
   - Remplissez les champs `configuration.host`, `configuration.username` et `configuration.password` avec les informations de votre serveur Nexus IQ.

2. **Exécuter le script**:
   - Activez votre environnement virtuel et exécutez le script.

```bash
source venv/bin/activate  # Sur Windows: venv\Scripts\activate
python get_sbom.py
```

Cela va récupérer les SBOM de toutes les applications, désérialiser les données JSON, et insérer les composants dans la base de données SQLite `sbom.db`.

Ce script est prêt à être utilisé et peut être étendu ou personnalisé selon vos besoins spécifiques.