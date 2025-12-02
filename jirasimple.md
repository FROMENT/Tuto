# Script Shell pur sans Python

Compris, voici une version 100% shell/bash compatible Git Bash sur VS Code.

```bash
#!/bin/bash
# extract_jira.sh - Extraction JIRA vers CSV (shell pur)

set -euo pipefail

# ============================================================
# CONFIGURATION
# ============================================================
JIRA_BASE_URL="${JIRA_BASE_URL:-https://votre-instance.atlassian.net}"
JIRA_PROJECT="${JIRA_PROJECT:-URLC}"
JIRA_TOKEN="${JIRA_TOKEN:-}"
JIRA_EMAIL="${JIRA_EMAIL:-}"
EXISTING_CSV="${EXISTING_CSV:-}"
OUTPUT_DIR="./jira_export"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# ============================================================
# FONCTIONS UTILITAIRES
# ============================================================
log_info() { echo "[INFO] $1"; }
log_error() { echo "[ERROR] $1" >&2; }
log_warn() { echo "[WARN] $1"; }

validate_config() {
    local error=0
    [[ -z "$JIRA_BASE_URL" ]] && log_error "JIRA_BASE_URL manquant" && error=1
    [[ -z "$JIRA_PROJECT" ]] && log_error "JIRA_PROJECT manquant" && error=1
    [[ -z "$JIRA_TOKEN" ]] && log_error "JIRA_TOKEN manquant" && error=1
    [[ -z "$JIRA_EMAIL" ]] && log_error "JIRA_EMAIL manquant" && error=1
    
    if [[ $error -eq 1 ]]; then
        echo ""
        echo "Usage: source .env && ./extract_jira.sh"
        exit 1
    fi
    
    # Vérifier jq
    if ! command -v jq &> /dev/null; then
        log_error "jq requis. Installation:"
        echo "  Windows/Git Bash: télécharger depuis https://stedolan.github.io/jq/"
        echo "  Linux: sudo apt install jq"
        exit 1
    fi
}

get_auth_header() {
    # Base64 compatible Git Bash Windows
    echo -n "${JIRA_EMAIL}:${JIRA_TOKEN}" | base64 | tr -d '\n\r'
}

# ============================================================
# EXTRACTION JIRA
# ============================================================
fetch_issues() {
    local start_at=0
    local max_results=100
    local total=999999
    local temp_file="${OUTPUT_DIR}/.issues_temp.json"
    
    echo "[]" > "$temp_file"
    
    while [[ $start_at -lt $total ]]; do
        log_info "Récupération tickets $start_at..."
        
        local response
        response=$(curl -s -X GET \
            -H "Authorization: Basic $(get_auth_header)" \
            -H "Content-Type: application/json" \
            "${JIRA_BASE_URL}/rest/api/3/search?jql=project=${JIRA_PROJECT}&startAt=${start_at}&maxResults=${max_results}")
        
        # Vérifier erreur
        if echo "$response" | jq -e '.errorMessages' > /dev/null 2>&1; then
            log_error "Erreur API JIRA:"
            echo "$response" | jq -r '.errorMessages[]'
            exit 1
        fi
        
        total=$(echo "$response" | jq '.total')
        
        # Fusionner les issues
        local current
        current=$(cat "$temp_file")
        echo "$current" | jq --argjson new "$(echo "$response" | jq '.issues')" '. + $new' > "$temp_file"
        
        start_at=$((start_at + max_results))
    done
    
    local count
    count=$(jq 'length' "$temp_file")
    log_info "Total: $count tickets extraits"
    
    cat "$temp_file"
}

# ============================================================
# CONVERSION JSON -> CSV
# ============================================================
json_to_csv() {
    local json_file="$1"
    local csv_file="$2"
    
    log_info "Conversion JSON vers CSV..."
    
    # En-têtes CSV (séparateur point-virgule pour Excel FR)
    echo "ticket_url;key;summary;type;status;resolution;priority;reporter;assignee;created;updated;labels;project_code;pao_status;country;department;application_trigram;url;domain_name;environment;protection_level_ddos;vip_creation" > "$csv_file"
    
    # Extraction avec jq
    jq -r --arg base_url "$JIRA_BASE_URL" '
    .[] | 
    [
        ($base_url + "/browse/" + .key),
        .key,
        (.fields.summary // "" | gsub(";"; ",") | gsub("\n"; " ") | gsub("\r"; "")),
        (.fields.issuetype.name // ""),
        (.fields.status.name // ""),
        (.fields.resolution.name // ""),
        (.fields.priority.name // ""),
        (.fields.reporter.displayName // ""),
        (.fields.assignee.displayName // ""),
        ((.fields.created // "")[:10]),
        ((.fields.updated // "")[:10]),
        ((.fields.labels // []) | join(", ")),
        # Champs personnalisés - adapter les IDs selon votre instance
        (if .fields.customfield_10100 then 
            (if .fields.customfield_10100 | type == "object" then .fields.customfield_10100.value 
             elif .fields.customfield_10100 | type == "string" then .fields.customfield_10100 
             else "" end) 
         else "" end),
        (if .fields.customfield_10101 then 
            (if .fields.customfield_10101 | type == "object" then .fields.customfield_10101.value 
             else (.fields.customfield_10101 | tostring) end) 
         else "" end),
        (if .fields.customfield_10102 then 
            (if .fields.customfield_10102 | type == "object" then .fields.customfield_10102.value 
             else (.fields.customfield_10102 | tostring) end) 
         else "" end),
        (if .fields.customfield_10103 then 
            (if .fields.customfield_10103 | type == "object" then .fields.customfield_10103.value 
             else (.fields.customfield_10103 | tostring) end) 
         else "" end),
        (if .fields.customfield_10104 then 
            (if .fields.customfield_10104 | type == "object" then .fields.customfield_10104.value 
             else (.fields.customfield_10104 | tostring) end) 
         else "" end),
        (if .fields.customfield_10105 then 
            (if .fields.customfield_10105 | type == "object" then .fields.customfield_10105.value 
             else (.fields.customfield_10105 | tostring) end) 
         else "" end),
        (if .fields.customfield_10106 then 
            (if .fields.customfield_10106 | type == "object" then .fields.customfield_10106.value 
             else (.fields.customfield_10106 | tostring) end) 
         else "" end),
        (if .fields.customfield_10107 then 
            (if .fields.customfield_10107 | type == "object" then .fields.customfield_10107.value 
             else (.fields.customfield_10107 | tostring) end) 
         else "" end),
        (if .fields.customfield_10108 then 
            (if .fields.customfield_10108 | type == "object" then .fields.customfield_10108.value 
             else (.fields.customfield_10108 | tostring) end) 
         else "" end)
    ] | @csv | gsub(","; ";")
    ' "$json_file" >> "$csv_file"
    
    local count
    count=$(($(wc -l < "$csv_file") - 1))
    log_info "CSV généré: $csv_file ($count lignes)"
}

# ============================================================
# DÉCOUVERTE DES CHAMPS PERSONNALISÉS
# ============================================================
discover_fields() {
    local output_file="${OUTPUT_DIR}/custom_fields.txt"
    
    log_info "Découverte des champs personnalisés..."
    
    curl -s -X GET \
        -H "Authorization: Basic $(get_auth_header)" \
        -H "Content-Type: application/json" \
        "${JIRA_BASE_URL}/rest/api/3/field" | \
        jq -r '.[] | select(.custom == true) | "\(.id)\t\(.name)"' | \
        sort > "$output_file"
    
    log_info "Liste des champs: $output_file"
    echo ""
    echo "=== CHAMPS PERSONNALISÉS DISPONIBLES ==="
    cat "$output_file"
    echo ""
}

# ============================================================
# FUSION AVEC CSV EXISTANT
# ============================================================
merge_csv() {
    local jira_csv="$1"
    local existing_csv="$2"
    local output_csv="$3"
    
    if [[ ! -f "$existing_csv" ]]; then
        log_warn "CSV existant non trouvé: $existing_csv"
        cp "$jira_csv" "$output_csv"
        return
    fi
    
    log_info "Fusion avec CSV existant..."
    
    # Créer fichier temporaire pour la fusion
    local temp_merged="${OUTPUT_DIR}/.merged_temp.csv"
    
    # Copier en-tête du CSV existant
    head -1 "$existing_csv" > "$temp_merged"
    
    # Créer un fichier d'index des URLs JIRA extraites
    local jira_urls="${OUTPUT_DIR}/.jira_urls.txt"
    tail -n +2 "$jira_csv" | cut -d';' -f1 | sed 's/"//g' > "$jira_urls"
    
    # Parcourir le CSV existant et mettre à jour ou conserver
    tail -n +2 "$existing_csv" | while IFS= read -r line; do
        # Extraire l'URL de la première colonne
        local url
        url=$(echo "$line" | cut -d';' -f1 | sed 's/"//g')
        
        # Extraire la clé JIRA de l'URL
        local key
        key=$(echo "$url" | grep -oE 'URLC-[0-9]+' || echo "")
        
        if [[ -n "$key" ]]; then
            # Chercher la ligne correspondante dans l'export JIRA
            local jira_line
            jira_line=$(grep ";\"*${key}\"*;" "$jira_csv" 2>/dev/null | head -1 || echo "")
            
            if [[ -n "$jira_line" ]]; then
                # Utiliser les données JIRA fraîches
                echo "$jira_line" >> "$temp_merged"
            else
                # Conserver la ligne existante
                echo "$line" >> "$temp_merged"
            fi
        else
            # Pas de clé JIRA, conserver
            echo "$line" >> "$temp_merged"
        fi
    done
    
    # Ajouter les nouveaux tickets JIRA non présents dans l'existant
    tail -n +2 "$jira_csv" | while IFS= read -r line; do
        local key
        key=$(echo "$line" | cut -d';' -f2 | sed 's/"//g')
        
        if ! grep -q "$key" "$existing_csv" 2>/dev/null; then
            echo "$line" >> "$temp_merged"
            log_info "Nouveau ticket ajouté: $key"
        fi
    done
    
    mv "$temp_merged" "$output_csv"
    
    local count
    count=$(($(wc -l < "$output_csv") - 1))
    log_info "CSV fusionné: $output_csv ($count lignes)"
    
    # Nettoyage
    rm -f "$jira_urls"
}

# ============================================================
# GÉNÉRATION CSV AVEC HYPERLINKS EXCEL
# ============================================================
generate_hyperlink_csv() {
    local input_csv="$1"
    local output_csv="${input_csv%.csv}_hyperlinks.csv"
    
    log_info "Génération CSV avec formules HYPERLINK..."
    
    # En-tête
    head -1 "$input_csv" > "$output_csv"
    
    # Transformer les URLs en formules Excel
    tail -n +2 "$input_csv" | while IFS= read -r line; do
        local url key
        url=$(echo "$line" | cut -d';' -f1 | sed 's/"//g')
        key=$(echo "$line" | cut -d';' -f2 | sed 's/"//g')
        
        if [[ "$url" == http* ]]; then
            # Remplacer l'URL par la formule HYPERLINK
            local formula="\"=HYPERLINK(\"\"${url}\"\";\"\"${key}\"\")\""
            echo "$line" | sed "s|^\"*[^;]*\"*;|${formula};|" >> "$output_csv"
        else
            echo "$line" >> "$output_csv"
        fi
    done
    
    log_info "CSV hyperlinks: $output_csv"
}

# ============================================================
# MAIN
# ============================================================
main() {
    echo "=============================================="
    echo "  EXTRACTION JIRA - Projet $JIRA_PROJECT"
    echo "=============================================="
    echo ""
    
    validate_config
    mkdir -p "$OUTPUT_DIR"
    
    # Option: découvrir les champs personnalisés
    if [[ "${1:-}" == "--discover" ]]; then
        discover_fields
        exit 0
    fi
    
    # Extraction
    local json_file="${OUTPUT_DIR}/${JIRA_PROJECT}_${TIMESTAMP}.json"
    local csv_file="${OUTPUT_DIR}/${JIRA_PROJECT}_${TIMESTAMP}.csv"
    local final_csv="${OUTPUT_DIR}/${JIRA_PROJECT}_final.csv"
    
    log_info "Extraction depuis: $JIRA_BASE_URL"
    fetch_issues > "$json_file"
    
    # Conversion
    json_to_csv "$json_file" "$csv_file"
    
    # Fusion si CSV existant
    if [[ -n "$EXISTING_CSV" && -f "$EXISTING_CSV" ]]; then
        merge_csv "$csv_file" "$EXISTING_CSV" "$final_csv"
    else
        cp "$csv_file" "$final_csv"
    fi
    
    # Générer version avec hyperlinks
    generate_hyperlink_csv "$final_csv"
    
    # Nettoyage fichiers temporaires
    rm -f "${OUTPUT_DIR}/.issues_temp.json"
    
    echo ""
    echo "=============================================="
    echo "  EXTRACTION TERMINÉE"
    echo "=============================================="
    echo ""
    echo "Fichiers générés:"
    ls -la "$OUTPUT_DIR"/*.csv "$OUTPUT_DIR"/*.json 2>/dev/null
    echo ""
    echo "Pour découvrir les IDs des champs personnalisés:"
    echo "  ./extract_jira.sh --discover"
}

main "$@"
```

## Fichier `.env`

```bash
# .env
JIRA_BASE_URL=https://votre-instance.atlassian.net
JIRA_EMAIL=pascal.froment@arval.com
JIRA_TOKEN=votre_api_token_ici
JIRA_PROJECT=URLC
EXISTING_CSV=./FICHIER_INVENTAIRE_URLC.csv
```

## Utilisation

```bash
# 1. Découvrir les champs personnalisés de votre instance
source .env && ./extract_jira.sh --discover

# 2. Extraction complète
source .env && ./extract_jira.sh
```

## Prérequis

|Outil |Installation Git Bash Windows                                                                           |
|------|--------------------------------------------------------------------------------------------------------|
|curl  |Inclus dans Git Bash                                                                                    |
|jq    |Télécharger depuis [stedolan.github.io/jq](https://stedolan.github.io/jq/), placer `jq.exe` dans le PATH|
|base64|Inclus dans Git Bash                                                                                    |

## Fichiers générés

```
jira_export/
├── URLC_20241202_143022.json      # Export brut JSON
├── URLC_20241202_143022.csv       # Export CSV
├── URLC_final.csv                 # CSV fusionné
├── URLC_final_hyperlinks.csv      # CSV avec =HYPERLINK()
└── custom_fields.txt              # Mapping des champs personnalisés
```

L’étape `--discover` vous donnera les IDs exacts des champs personnalisés de votre instance JIRA pour adapter le mapping dans le script.​​​​​​​​​​​​​​​​