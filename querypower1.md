# Solution Power Query complète

## Étape 1 : Ouvrir Power Query

Dans Excel : **Données → Obtenir des données → À partir d’autres sources → Requête vide**

Puis cliquez sur **Éditeur avancé**.

-----

## Étape 2 : Requête de découverte des champs personnalisés

Créez d’abord cette requête pour identifier vos champs personnalisés :

```powerquery
let
    // ============================================================
    // CONFIGURATION - MODIFIER CES VALEURS
    // ============================================================
    JIRA_BASE_URL = "https://votre-instance.atlassian.net",
    JIRA_EMAIL = "pascal.froment@entreprise.com",
    JIRA_TOKEN = "votre_api_token_ici",
    
    // ============================================================
    // AUTHENTIFICATION
    // ============================================================
    Credentials = Text.ToBinary(JIRA_EMAIL & ":" & JIRA_TOKEN),
    AuthHeader = "Basic " & Binary.ToText(Credentials, BinaryEncoding.Base64),
    
    // ============================================================
    // APPEL API
    // ============================================================
    Source = Web.Contents(
        JIRA_BASE_URL & "/rest/api/3/field",
        [
            Headers = [
                #"Authorization" = AuthHeader,
                #"Content-Type" = "application/json"
            ]
        ]
    ),
    
    JsonResponse = Json.Document(Source),
    ToTable = Table.FromList(JsonResponse, Splitter.SplitByNothing(), {"Field"}),
    ExpandField = Table.ExpandRecordColumn(ToTable, "Field", {"id", "name", "custom", "schema"}, {"id", "name", "custom", "schema"}),
    CustomFieldsOnly = Table.SelectRows(ExpandField, each [custom] = true),
    SortByName = Table.Sort(CustomFieldsOnly, {{"name", Order.Ascending}})
in
    SortByName
```

Nommez cette requête **“JIRA_CustomFields”** et chargez-la. Notez les IDs des champs qui vous intéressent (ex: `customfield_10234`).

-----

## Étape 3 : Requête principale d’extraction

Créez une nouvelle requête vide et collez :

```powerquery
let
    // ============================================================
    // CONFIGURATION - MODIFIER CES VALEURS
    // ============================================================
    JIRA_BASE_URL = "https://votre-instance.atlassian.net",
    JIRA_PROJECT = "URLC",
    JIRA_EMAIL = "pascal.froment@entreprise.com",
    JIRA_TOKEN = "votre_api_token_ici",
    
    // ============================================================
    // AUTHENTIFICATION
    // ============================================================
    Credentials = Text.ToBinary(JIRA_EMAIL & ":" & JIRA_TOKEN),
    AuthHeader = "Basic " & Binary.ToText(Credentials, BinaryEncoding.Base64),
    
    Headers = [
        #"Authorization" = AuthHeader,
        #"Content-Type" = "application/json"
    ],
    
    // ============================================================
    // FONCTION : RÉCUPÉRER UNE PAGE
    // ============================================================
    GetPage = (startAt as number) as record =>
        let
            Url = JIRA_BASE_URL 
                & "/rest/api/3/search?jql=project=" & JIRA_PROJECT 
                & "&startAt=" & Text.From(startAt) 
                & "&maxResults=100",
            Response = Web.Contents(Url, [Headers = Headers]),
            Json = Json.Document(Response)
        in
            Json,
    
    // ============================================================
    // PAGINATION : RÉCUPÉRER TOUS LES TICKETS
    // ============================================================
    FirstPage = GetPage(0),
    TotalIssues = FirstPage[total],
    
    // Générer liste de toutes les pages
    PageNumbers = List.Generate(
        () => 0,
        each _ < TotalIssues,
        each _ + 100
    ),
    
    // Récupérer toutes les issues
    AllPages = List.Transform(PageNumbers, each GetPage(_)[issues]),
    AllIssues = List.Combine(AllPages),
    
    // ============================================================
    // TRANSFORMATION EN TABLE
    // ============================================================
    IssuesTable = Table.FromList(AllIssues, Splitter.SplitByNothing(), {"Issue"}),
    
    // Expansion de base
    Step1 = Table.ExpandRecordColumn(IssuesTable, "Issue", {"key", "self", "fields"}, {"key", "self", "fields"}),
    
    // Ajouter URL cliquable
    Step2 = Table.AddColumn(Step1, "ticket_url", each JIRA_BASE_URL & "/browse/" & [key], type text),
    
    // ============================================================
    // EXPANSION DES CHAMPS STANDARDS
    // ============================================================
    Step3 = Table.ExpandRecordColumn(Step2, "fields", {
        "summary", 
        "issuetype", 
        "status", 
        "resolution", 
        "priority",
        "reporter", 
        "assignee", 
        "created", 
        "updated", 
        "labels",
        "components",
        "description",
        // === CHAMPS PERSONNALISÉS - ADAPTER SELON VOTRE INSTANCE ===
        // Décommentez et modifiez après avoir consulté JIRA_CustomFields
        "customfield_10100",  // Project code ?
        "customfield_10101",  // PAO Status ?
        "customfield_10102",  // Country ?
        "customfield_10103",  // Department ?
        "customfield_10104",  // Application Trigram ?
        "customfield_10105",  // URL ?
        "customfield_10106",  // Domain name ?
        "customfield_10107",  // Environment ?
        "customfield_10108",  // WASS Date ?
        "customfield_10109"   // Date asset review ?
    }),
    
    // Expansion issuetype
    Step4 = Table.ExpandRecordColumn(Step3, "issuetype", {"name"}, {"type"}),
    
    // Expansion status
    Step5 = Table.ExpandRecordColumn(Step4, "status", {"name"}, {"status"}),
    
    // Expansion resolution (peut être null)
    Step6 = Table.ExpandRecordColumn(Step5, "resolution", {"name"}, {"resolution"}),
    
    // Expansion priority
    Step7 = Table.ExpandRecordColumn(Step6, "priority", {"name"}, {"priority"}),
    
    // Expansion reporter
    Step8 = Table.ExpandRecordColumn(Step7, "reporter", {"displayName", "emailAddress"}, {"reporter", "reporter_email"}),
    
    // Expansion assignee (peut être null)
    Step9 = Table.ExpandRecordColumn(Step8, "assignee", {"displayName"}, {"assignee"}),
    
    // ============================================================
    // TRAITEMENT DES LABELS ET COMPONENTS
    // ============================================================
    Step10 = Table.TransformColumns(Step9, {
        {"labels", each if _ is list then Text.Combine(_, ", ") else null, type text}
    }),
    
    Step11 = Table.TransformColumns(Step10, {
        {"components", each if _ is list then Text.Combine(List.Transform(_, each Record.FieldOrDefault(_, "name", "")), ", ") else null, type text}
    }),
    
    // ============================================================
    // FORMATAGE DES DATES
    // ============================================================
    Step12 = Table.TransformColumns(Step11, {
        {"created", each if _ <> null and Text.Length(_) >= 10 then Text.Start(_, 10) else null, type text},
        {"updated", each if _ <> null and Text.Length(_) >= 10 then Text.Start(_, 10) else null, type text}
    }),
    
    // ============================================================
    // TRAITEMENT CHAMPS PERSONNALISÉS (valeur ou record)
    // ============================================================
    ExtractCustomValue = (value) => 
        if value is record then 
            Record.FieldOrDefault(value, "value", Record.FieldOrDefault(value, "name", ""))
        else if value is list then
            Text.Combine(List.Transform(value, each 
                if _ is record then Record.FieldOrDefault(_, "value", Record.FieldOrDefault(_, "name", ""))
                else Text.From(_)
            ), ", ")
        else if value <> null then 
            Text.From(value)
        else 
            null,
    
    Step13 = Table.TransformColumns(Step12, {
        {"customfield_10100", each ExtractCustomValue(_), type text},
        {"customfield_10101", each ExtractCustomValue(_), type text},
        {"customfield_10102", each ExtractCustomValue(_), type text},
        {"customfield_10103", each ExtractCustomValue(_), type text},
        {"customfield_10104", each ExtractCustomValue(_), type text},
        {"customfield_10105", each ExtractCustomValue(_), type text},
        {"customfield_10106", each ExtractCustomValue(_), type text},
        {"customfield_10107", each ExtractCustomValue(_), type text},
        {"customfield_10108", each ExtractCustomValue(_), type text},
        {"customfield_10109", each ExtractCustomValue(_), type text}
    }),
    
    // ============================================================
    // RENOMMAGE DES COLONNES
    // ============================================================
    Step14 = Table.RenameColumns(Step13, {
        {"customfield_10100", "project_code"},
        {"customfield_10101", "pao_status"},
        {"customfield_10102", "country"},
        {"customfield_10103", "department"},
        {"customfield_10104", "application_trigram"},
        {"customfield_10105", "url"},
        {"customfield_10106", "domain_name"},
        {"customfield_10107", "environment"},
        {"customfield_10108", "wass_date"},
        {"customfield_10109", "date_asset_review"}
    }),
    
    // Supprimer colonne self (inutile)
    Step15 = Table.RemoveColumns(Step14, {"self"}),
    
    // ============================================================
    // RÉORGANISATION FINALE
    // ============================================================
    FinalTable = Table.ReorderColumns(Step15, {
        "ticket_url",
        "key",
        "summary",
        "type",
        "status",
        "resolution",
        "priority",
        "reporter",
        "assignee",
        "created",
        "updated",
        "project_code",
        "pao_status",
        "country",
        "department",
        "application_trigram",
        "url",
        "domain_name",
        "environment",
        "wass_date",
        "date_asset_review",
        "labels",
        "components"
    })
    
in
    FinalTable
```

Nommez cette requête **“JIRA_Extract”**.

-----

## Étape 4 : Rendre les liens cliquables

Après chargement dans Excel, ajoutez une colonne avec cette formule :

```excel
=LIEN_HYPERTEXTE([@[ticket_url]];[@[key]])
```

Ou en anglais :

```excel
=HYPERLINK([@[ticket_url]],[@[key]])
```

-----

## Étape 5 : Fusionner avec votre fichier existant

Si vous avez déjà un fichier Excel avec des données complémentaires :

1. **Données → Obtenir des données → À partir d’un fichier → À partir d’un classeur Excel**
1. Sélectionnez votre fichier existant
1. Nommez la requête **“Inventaire_Existant”**

Puis créez une requête de fusion :

```powerquery
let
    // Charger les deux tables
    JIRA = JIRA_Extract,
    Existant = Inventaire_Existant,
    
    // Extraire la clé JIRA de l'URL dans l'existant
    ExistantAvecCle = Table.AddColumn(Existant, "key_extract", each 
        let 
            url = [#"Identification de la fiche"],  // Adapter le nom de colonne
            match = Text.AfterDelimiter(url, "/browse/")
        in 
            if match <> null then Text.BeforeDelimiter(match, "?") else null
    ),
    
    // Fusion LEFT JOIN : JIRA + colonnes existantes
    Fusion = Table.NestedJoin(
        JIRA, {"key"},
        ExistantAvecCle, {"key_extract"},
        "Existant",
        JoinKind.LeftOuter
    ),
    
    // Expansion des colonnes de l'existant à conserver
    Expanded = Table.ExpandTableColumn(Fusion, "Existant", {
        "Recommandation NT",
        "Responsable applicatif",
        "Société partenaire",
        "Contrat DIN",
        "Notes"
        // Ajouter les autres colonnes à conserver
    })
in
    Expanded
```

-----

## Utilisation quotidienne

1. Ouvrez le fichier Excel
1. **Données → Actualiser tout** (ou Ctrl+Alt+F5)
1. Les données JIRA sont mises à jour automatiquement

-----

## Gestion du token sécurisé (optionnel)

Pour éviter d’avoir le token en clair dans la requête :

1. **Données → Obtenir des données → Paramètres de la source de données**
1. Sélectionnez votre source JIRA
1. **Modifier les autorisations → Modifier les informations d’identification**
1. Choisissez **Base** et entrez email / token

Puis modifiez la requête pour retirer l’authentification manuelle :

```powerquery
// Remplacer Web.Contents avec Headers par :
Source = Web.Contents(
    JIRA_BASE_URL & "/rest/api/3/search?jql=project=" & JIRA_PROJECT,
    [
        Headers = [#"Content-Type" = "application/json"]
        // L'auth est gérée par Excel
    ]
)
```

-----

Souhaitez-vous que je vous aide à identifier les IDs exacts de vos champs personnalisés une fois la requête de découverte exécutée ?​​​​​​​​​​​​​​​​