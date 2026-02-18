# Version optimisée pour moins de 2000 tickets

Avec 2000 tickets maximum, il faut 2 appels API (1000 + 1000). Voici la version propre :

```powerquery
let
    // ============================================================
    // CONFIGURATION
    // ============================================================
    JIRA_BASE_URL = "https://reman.intra.corp",
    JQL = "project=URLC AND created >= 2025-01-01 ORDER BY created DESC",
    
    // ============================================================
    // RÉCUPÉRATION EN 2 APPELS
    // ============================================================
    Page1 = Json.Document(
        Web.Contents(
            JIRA_BASE_URL & "/rest/api/2/search?jql=" & Uri.EscapeDataString(JQL) 
            & "&startAt=0&maxResults=1000"
        )
    ),
    
    Page2 = Json.Document(
        Web.Contents(
            JIRA_BASE_URL & "/rest/api/2/search?jql=" & Uri.EscapeDataString(JQL) 
            & "&startAt=1000&maxResults=1000"
        )
    ),
    
    AllIssues = List.Combine({Page1[issues], Page2[issues]}),
    
    // ============================================================
    // CONVERSION EN TABLE
    // ============================================================
    IssuesTable = Table.FromList(AllIssues, Splitter.SplitByNothing(), {"Issue"}),
    
    Step1 = Table.ExpandRecordColumn(IssuesTable, "Issue", {"key", "fields"}),
    
    Step2 = Table.AddColumn(Step1, "ticket_url", each JIRA_BASE_URL & "/browse/" & [key], type text),
    
    // ============================================================
    // EXPANSION CHAMPS
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
        "customfield_10989",
        "customfield_10104",
        "customfield_19173",
        "customfield_12681",
        "customfield_13566",
        "customfield_13567",
        "customfield_24571",
        "customfield_26974",
        "customfield_13691"
    }),
    
    Step4 = Table.ExpandRecordColumn(Step3, "issuetype", {"name"}, {"type"}),
    Step5 = Table.ExpandRecordColumn(Step4, "status", {"name"}, {"status"}),
    Step6 = Table.ExpandRecordColumn(Step5, "resolution", {"name"}, {"resolution"}),
    Step7 = Table.ExpandRecordColumn(Step6, "priority", {"name"}, {"priority"}),
    Step8 = Table.ExpandRecordColumn(Step7, "reporter", {"displayName"}, {"reporter"}),
    Step9 = Table.ExpandRecordColumn(Step8, "assignee", {"displayName"}, {"assignee"}),
    
    // ============================================================
    // TRAITEMENT LISTES
    // ============================================================
    Step10 = Table.TransformColumns(Step9, {
        {"labels", each if _ is list then Text.Combine(_, ", ") else null, type text},
        {"components", each if _ is list then Text.Combine(List.Transform(_, each Record.FieldOrDefault(_, "name", "")), ", ") else null, type text}
    }),
    
    // ============================================================
    // FORMATAGE DATES
    // ============================================================
    Step11 = Table.TransformColumns(Step10, {
        {"created", each if _ <> null then Text.Start(Text.From(_), 10) else null, type text},
        {"updated", each if _ <> null then Text.Start(Text.From(_), 10) else null, type text}
    }),
    
    // ============================================================
    // EXTRACTION VALEURS CUSTOM FIELDS
    // ============================================================
    ExtractValue = (val) => 
        if val is record then 
            Record.FieldOrDefault(val, "value", Record.FieldOrDefault(val, "name", ""))
        else if val is list then
            Text.Combine(List.Transform(val, each 
                if _ is record then Record.FieldOrDefault(_, "value", Record.FieldOrDefault(_, "name", "")) 
                else Text.From(_)
            ), ", ")
        else if val <> null then 
            Text.From(val)
        else 
            null,
    
    Step12 = Table.TransformColumns(Step11, {
        {"customfield_10989", each ExtractValue(_), type text},
        {"customfield_10104", each ExtractValue(_), type text},
        {"customfield_19173", each ExtractValue(_), type text},
        {"customfield_12681", each ExtractValue(_), type text},
        {"customfield_13566", each ExtractValue(_), type text},
        {"customfield_13567", each ExtractValue(_), type text},
        {"customfield_24571", each ExtractValue(_), type text},
        {"customfield_26974", each ExtractValue(_), type text},
        {"customfield_13691", each ExtractValue(_), type text}
    }),
    
    // ============================================================
    // RÉORGANISATION FINALE
    // ============================================================
    FinalTable = Table.ReorderColumns(Step12, {
        "ticket_url", "key", "summary", "type", "status", "resolution",
        "priority", "reporter", "assignee", "created", "updated",
        "customfield_10989", "customfield_10104", "customfield_19173",
        "customfield_12681", "customfield_13566", "customfield_13567",
        "customfield_24571", "customfield_26974", "customfield_13691",
        "labels", "components"
    })
    
in
    FinalTable
```

-----

## Résumé des colonnes

|Colonne          |À renommer en   |
|-----------------|----------------|
|ticket_url       |(lien cliquable)|
|key              |Clé JIRA        |
|summary          |Résumé          |
|type             |Type            |
|status           |Statut          |
|resolution       |Résolution      |
|priority         |Priorité        |
|reporter         |Rapporteur      |
|assignee         |Assigné         |
|created          |Créé le         |
|updated          |Mis à jour      |
|customfield_10989|Country         |
|customfield_10104|Department      |
|customfield_19173|Domain          |
|customfield_12681|Environment     |
|customfield_13566|Begin Date      |
|customfield_13567|End Date        |
|customfield_24571|Business Domain |
|customfield_26974|Link            |
|customfield_13691|Notes           |

Testez et dites-moi si ça fonctionne.​​​​​​​​​​​​​​​​