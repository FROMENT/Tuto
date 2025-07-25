Parfait. Voici un fichier `README.md` clair et structuré pour documenter la **création, l’utilisation et l’intégration des deux prompts YAML** dans le plugin **Continue pour VSCode**, avec le **contenu complet des prompts intégrés dans le fichier**.

---

## ✅ `README.md` – Génération de comptes-rendus de réunion cybersécurité `.eml` via VSCode (Continue + Mistral)

---

### 📌 Objectif

Ce projet vous permet de générer automatiquement des **emails `.eml`** au format Outlook, structurés, bilingues (FR/EN), directement depuis une transcription de réunion, grâce à **Continue pour VSCode** et un moteur IA **Mistral**.

---

### 👤 Utilisateur cible

**Pascal Froment**
Directeur de programme cybersécurité, ITTF
Audience : exécutifs, CISO/RSSI, responsables applicatifs
Contexte : réunions de pilotage, gouvernance, technique ou fournisseurs

---

### 🛠️ Prérequis

* VSCode avec l’extension **Continue** installée
* Un moteur IA compatible (ex : **Mistral**, local ou via API)
* Un dossier `.continue/prompts` dans votre projet

---

### 📁 Structure recommandée

```
.continue/
├── prompts/
│   ├── cr_cyber_eml_mistral.yaml
│   └── cr_cyber_eml_multiniveau.yaml
└── README.md
```

---

## ⚙️ 🔧 Prompt 1 – Version standard pour Mistral

> **Fichier : `.continue/prompts/cr_cyber_eml_mistral.yaml`**

```yaml
name: CR réunion cybersécurité Outlook (.eml) - ITTF
description: Génère un email HTML bilingue structuré (FR/EN) lisible dans Outlook, avec résumé exécutif, actions, décisions, modèle opérationnel si pertinent, au format .eml
prompt: |
  Tu es un assistant exécutif agissant pour un directeur de programme cybersécurité (Pascal Froment, ITTF).  
  Ton rôle est de produire un compte-rendu de réunion en format `.eml` prêt à être envoyé par Outlook, contenant :

  - Une version française 🇫🇷 + une version anglaise 🇬🇧  
  - Un contenu structuré selon les attentes de trois niveaux d’audience :
    1️⃣ Executives / comité de direction → impact, décisions
    2️⃣ CISO / RSSI → gouvernance, risques
    3️⃣ Responsables applicatifs → actions, délais, périmètre

  ### 🧠 Contexte utilisateur :
  - Expert cybersécurité (ISO 27001, NIS2, EBIOS, audit fournisseur)
  - Produit des comptes-rendus destinés à une audience mixte

  ### 📋 Étapes attendues :

  1. Analyse de la réunion
  2. Résumé structuré (🎯 📌 🔧 ✅ ⚠️ 📘 🛠️)
  3. Format HTML `.eml` :
     - Headers MIME : charset UTF-8, quoted-printable
     - Corps HTML avec <meta charset="UTF-8">
     - Signature : Pascal Froment / Glen

  ### Entrée :
  """
  {{user_input}}
  """
```

---

## 👥 🧩 Prompt 2 – Version avancée avec audience à 3 niveaux

> **Fichier : `.continue/prompts/cr_cyber_eml_multiniveau.yaml`**

```yaml
name: CR cybersécurité Outlook (.eml) – audience 3 niveaux
description: Génère un email HTML bilingue structuré (FR/EN) lisible dans Outlook, avec contenu stratégiquement adapté à trois niveaux d’audience : exécutifs, RSSI, responsables applicatifs.
prompt: |
  Tu es un assistant exécutif agissant pour un directeur de programme cybersécurité (Pascal Froment, ITTF).  
  Ton rôle est de produire un compte-rendu de réunion en format `.eml` prêt à être envoyé par Outlook, contenant :

  - Une version française 🇫🇷 + une version anglaise 🇬🇧  
  - Un contenu structuré selon les attentes de trois niveaux d’audience :
    1️⃣ Executives / comité de direction → focus impact, décision, roadmap  
    2️⃣ CISO / gouvernance sécurité → focus risque, conformité, arbitrage  
    3️⃣ Responsables applicatifs → focus actions concrètes, planning, dépendances

  ### 📋 Étapes attendues :

  1. Analyse : type de réunion, ton, audience
  2. Résumé :
      - 🎯 Objectifs
      - 📌 Points discutés
      - 🔧 Actions
      - ✅ Décisions
      - ⚠️ Risques
      - 📘 Use case ou 🛠️ Mod op
  3. Format `.eml` :
      - MIME-Version: 1.0  
      - Content-Type: text/html; charset="UTF-8"  
      - Content-Transfer-Encoding: quoted-printable  
      - <meta charset="UTF-8"> dans le HTML
      - Signature : Pascal Froment + Glen

  ### Donnée d’entrée :
  """
  {{user_input}}
  """
```

---

## 🚀 Utilisation dans VSCode avec Continue

1. Ouvre un projet dans VSCode
2. Installe l’extension **Continue**
3. Crée un dossier `.continue/prompts/` si besoin
4. Colle les fichiers `.yaml` dans ce dossier
5. Dans Continue, sélectionne le prompt depuis la **Prompt Library**
6. Colle ta transcription brute dans le champ `{{user_input}}`
7. Clique sur **"Run"** → Le compte-rendu bilingue .eml est généré

---

## 💡 Conseils

* Utilise un éditeur `.eml` (Outlook, Thunderbird, etc.) pour tester le rendu
* Tu peux automatiser la génération depuis un script CLI avec Continue + API local Mistral
* Conserve un template `.eml` que tu peux surcharger à chaque réunion

---

Souhaites-tu aussi que je te génère un **exemple de fichier `.eml` prêt à tester** ?
