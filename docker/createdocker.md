Pour construire une image Docker en se connectant de façon non anonyme à un Artifactory, il est nécessaire de suivre plusieurs étapes incluant la configuration des identifiants de connexion et l'utilisation de ces identifiants lors de la construction de l'image. Voici un guide détaillé pour ce processus.

### 1. Pré-requis

- Docker installé sur votre machine.
- Accès à un Artifactory configuré pour stocker des images Docker.
- Identifiants de connexion (nom d'utilisateur et mot de passe ou token) pour accéder à l'Artifactory.

### 2. Configurer Docker pour utiliser vos identifiants

Docker permet de configurer des identifiants de connexion via son fichier de configuration `config.json`. Voici comment procéder :

#### A. Connexion à Artifactory avec Docker CLI

1. **Utiliser Docker login** :
   ```sh
   docker login your.artifactory.url
   ```
   Vous serez invité à entrer votre nom d'utilisateur et votre mot de passe.

   Alternativement, vous pouvez utiliser un token d'authentification si votre Artifactory le supporte :
   ```sh
   docker login your.artifactory.url -u your-username -p your-token
   ```

2. **Vérification de la configuration** :
   Après cette commande, vos identifiants seront stockés dans le fichier `~/.docker/config.json`. Vous pouvez vérifier que vos identifiants ont été correctement enregistrés en consultant ce fichier :
   ```json
   {
     "auths": {
       "your.artifactory.url": {
         "auth": "base64encodedcredentials"
       }
     }
   }
   ```

### 3. Créer un Dockerfile

Créez un fichier `Dockerfile` pour définir votre image Docker. Voici un exemple simple :

```dockerfile
# Utiliser une image de base
FROM python:3.8-slim

# Ajouter des fichiers au conteneur
ADD . /app

# Définir le répertoire de travail
WORKDIR /app

# Installer les dépendances
RUN pip install -r requirements.txt

# Définir la commande par défaut
CMD ["python", "app.py"]
```

### 4. Construire l'image Docker

Construisez l'image Docker en utilisant la commande suivante, tout en spécifiant le dépôt Artifactory comme destination de l'image :

```sh
docker build -t your.artifactory.url/repository/image-name:tag .
```

### 5. Pousser l'image vers Artifactory

Une fois l'image construite, vous pouvez la pousser vers Artifactory :

```sh
docker push your.artifactory.url/repository/image-name:tag
```

### 6. Utilisation d’un fichier Docker Config Secrets (Optionnel)

Pour une sécurité accrue, vous pouvez utiliser un fichier de configuration Docker `config.json` pour stocker les identifiants de manière sécurisée. Voici comment le créer et l'utiliser :

1. **Créer le fichier `config.json`** :
   ```json
   {
     "auths": {
       "your.artifactory.url": {
         "auth": "base64encodedcredentials"
       }
     }
   }
   ```

2. **Utiliser ce fichier lors de la construction** :
   ```sh
   docker --config /path/to/config.json build -t your.artifactory.url/repository/image-name:tag .
   ```

### Conclusion

En suivant ces étapes, vous serez en mesure de construire et de pousser des images Docker vers un Artifactory en utilisant des identifiants de connexion non anonymes. Cette méthode assure que seules les personnes autorisées peuvent accéder et publier des images sur votre Artifactory, garantissant ainsi la sécurité et l'intégrité de vos images Docker.

Pour plus d'informations et des exemples pratiques, n'hésitez pas à consulter la documentation officielle de Docker et celle de votre fournisseur Artifactory.