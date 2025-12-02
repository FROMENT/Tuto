# Script d’extraction JIRA vers CSV avec mise à jour

Compris : extraction JIRA → mise à jour du CSV existant, jointure sur l’URL du ticket, avec liens cliquables.

## Script complet

```bash
#!/bin/bash
# extract_jira_to_csv.sh - Extraction JIRA avec mise à jour CSV existant

set -euo pipefail

# Configuration
JIRA_BASE_URL="${JIRA_BASE_URL:-https://votre-instance.atlassian.net}"
JIRA_PROJECT="${JIRA_PROJECT:-URLC}"
JIRA_TOKEN="${JIRA_TOKEN:-}"
JIRA_EMAIL="${JIRA_EMAIL:-}"
EXISTING_CSV="${EXISTING_CSV:-}"
OUTPUT_DIR="./jira_export"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }

validate_config() {
    local missing=()
    [[ -z "$JIRA_BASE_URL" ]] && missing+=("JIRA_BASE_URL")
    [[ -z "$JIRA_PROJECT" ]] && missing+=("JIRA_PROJECT")
    [[ -z "$JIRA_TOKEN" ]] && missing+=("JIRA_TOKEN")
    [[ -z "$JIRA_EMAIL" ]] && missing+=("JIRA_EMAIL")
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        log_error "Variables manquantes: ${missing[*]}"
        exit 1
    fi
}

get_auth_header() {
    echo -n "${JIRA_EMAIL}:${JIRA_TOKEN}" | base64
}

# Découverte des champs personnalisés
discover_custom_fields() {
    log_info "Découverte des champs personnalisés..."
    
    curl -s -X GET \
        -H "Authorization: Basic $(get_auth_header)" \
        -H "Content-Type: application/json" \
        "${JIRA_BASE_URL}/rest/api/3/field" | jq -r '.[] | select(.custom == true) | "\(.id): \(.name)"' > "${OUTPUT_DIR}/custom_fields_mapping.txt"
    
    log_info "Mapping des champs sauvegardé: ${OUTPUT_DIR}/custom_fields_mapping.txt"
}

# Extraction JIRA avec pagination
fetch_all_issues() {
    local start_at=0
    local max_results=100
    local total=1
    local all_issues="[]"
    
    while [[ $start_at -lt $total ]]; do
        log_info "Récupération tickets $start_at à $((start_at + max_results))..."
        
        local response
        response=$(curl -s -X GET \
            -H "Authorization: Basic $(get_auth_header)" \
            -H "Content-Type: application/json" \
            "${JIRA_BASE_URL}/rest/api/3/search?jql=project=${JIRA_PROJECT}&startAt=${start_at}&maxResults=${max_results}&expand=names")
        
        if echo "$response" | jq -e '.errorMessages' > /dev/null 2>&1; then
            log_error "Erreur API: $(echo "$response" | jq -r '.errorMessages[]')"
            exit 1
        fi
        
        total=$(echo "$response" | jq '.total')
        local issues
        issues=$(echo "$response" | jq '.issues')
        
        all_issues=$(echo "$all_issues $issues" | jq -s 'add')
        start_at=$((start_at + max_results))
    done
    
    log_info "Total: $(echo "$all_issues" | jq 'length') tickets récupérés"
    echo "$all_issues"
}

# Traitement et fusion avec CSV existant
process_and_merge() {
    local jira_json="$1"
    local existing_csv="$2"
    local output_file="$3"
    
    python3 << 'PYTHON_SCRIPT'
import json
import pandas as pd
import sys
import os
from datetime import datetime

# Paramètres
jira_base_url = os.environ.get('JIRA_BASE_URL', '')
existing_csv = os.environ.get('EXISTING_CSV', '')
output_file = os.environ.get('OUTPUT_FILE', '')

# Charger JSON JIRA depuis stdin
jira_data = json.loads(sys.stdin.read())

def safe_get(d, *keys, default=''):
    """Extraction sécurisée de valeurs imbriquées"""
    for key in keys:
        if isinstance(d, dict):
            d = d.get(key, {})
        else:
            return default
    return d if d and d != {} else default

def extract_custom_field(fields, field_id):
    """Extraction générique d'un champ personnalisé"""
    value = fields.get(field_id)
    if value is None:
        return ''
    if isinstance(value, dict):
        return value.get('value', value.get('name', str(value)))
    if isinstance(value, list):
        return ', '.join([
            v.get('value', v.get('name', str(v))) if isinstance(v, dict) else str(v)
            for v in value
        ])
    return str(value)

# Construire les enregistrements JIRA
jira_records = []
for issue in jira_data:
    key = issue.get('key', '')
    fields = issue.get('fields', {})
    
    # URL cliquable du ticket (format hyperlink pour CSV/Excel)
    ticket_url = f"{jira_base_url}/browse/{key}"
    
    record = {
        'ticket_url': ticket_url,
        'key': key,
        'summary': safe_get(fields, 'summary'),
        'type': safe_get(fields, 'issuetype', 'name'),
        'status': safe_get(fields, 'status', 'name'),
        'resolution': safe_get(fields, 'resolution', 'name'),
        'priority': safe_get(fields, 'priority', 'name'),
        'reporter': safe_get(fields, 'reporter', 'displayName'),
        'assignee': safe_get(fields, 'assignee', 'displayName'),
        'created': safe_get(fields, 'created', default='')[:10],
        'updated': safe_get(fields, 'updated', default='')[:10],
        'labels': ', '.join(fields.get('labels', [])),
        'components': ', '.join([c.get('name', '') for c in fields.get('components', [])]),
    }
    
    # Extraction de tous les champs personnalisés
    for field_key in fields:
        if field_key.startswith('customfield_'):
            value = extract_custom_field(fields, field_key)
            if value:
                record[field_key] = value
    
    jira_records.append(record)

df_jira = pd.DataFrame(jira_records)
print(f"[INFO] Tickets JIRA extraits: {len(df_jira)}", file=sys.stderr)

# Fusion avec CSV existant si fourni
if existing_csv and os.path.exists(existing_csv):
    print(f"[INFO] Chargement CSV existant: {existing_csv}", file=sys.stderr)
    
    # Détection automatique du séparateur
    with open(existing_csv, 'r', encoding='utf-8-sig') as f:
        first_line = f.readline()
        separator = ';' if ';' in first_line else ','
    
    df_existing = pd.read_csv(existing_csv, sep=separator, encoding='utf-8-sig')
    print(f"[INFO] Lignes CSV existant: {len(df_existing)}", file=sys.stderr)
    
    # Identifier la colonne de jointure (URL du ticket)
    url_column = None
    for col in df_existing.columns:
        if 'url' in col.lower() or 'identification' in col.lower() or 'lien' in col.lower():
            # Vérifier si contient des URLs JIRA
            sample = df_existing[col].dropna().head(5).astype(str)
            if any('browse/' in str(v) or 'URLC-' in str(v) for v in sample):
                url_column = col
                break
    
    if url_column:
        print(f"[INFO] Colonne de jointure détectée: '{url_column}'", file=sys.stderr)
        
        # Normaliser les URLs pour la jointure
        df_existing['_join_key'] = df_existing[url_column].astype(str).str.extract(r'(URLC-\d+)', expand=False)
        df_jira['_join_key'] = df_jira['key']
        
        # Fusion : mise à jour des lignes existantes + ajout des nouvelles
        df_merged = df_existing.merge(
            df_jira, 
            on='_join_key', 
            how='outer', 
            suffixes=('_old', '_jira')
        )
        
        # Prioriser les valeurs JIRA pour les colonnes communes
        for col in df_jira.columns:
            if col != '_join_key':
                col_jira = f"{col}_jira" if f"{col}_jira" in df_merged.columns else col
                col_old = f"{col}_old" if f"{col}_old" in df_merged.columns else None
                
                if col_jira in df_merged.columns:
                    if col_old and col_old in df_merged.columns:
                        df_merged[col] = df_merged[col_jira].fillna(df_merged[col_old])
                        df_merged.drop(columns=[col_jira, col_old], inplace=True, errors='ignore')
                    else:
                        df_merged[col] = df_merged[col_jira]
                        df_merged.drop(columns=[col_jira], inplace=True, errors='ignore')
        
        df_merged.drop(columns=['_join_key'], inplace=True, errors='ignore')
        df_final = df_merged
        
        # Stats
        new_count = len(df_jira) - len(df_existing[df_existing['_join_key'].isin(df_jira['key'])])
        print(f"[INFO] Nouveaux tickets ajoutés: {new_count}", file=sys.stderr)
    else:
        print("[WARN] Colonne URL non détectée, export JIRA seul", file=sys.stderr)
        df_final = df_jira
else:
    print("[INFO] Pas de CSV existant, création nouveau fichier", file=sys.stderr)
    df_final = df_jira

# Export CSV avec séparateur point-virgule (compatible Excel FR)
df_final.to_csv(output_file, index=False, sep=';', encoding='utf-8-sig')
print(f"[INFO] Export: {output_file} ({len(df_final)} lignes)", file=sys.stderr)

# Générer aussi un fichier avec formules Excel pour liens cliquables
excel_output = output_file.replace('.csv', '_hyperlinks.csv')
df_excel = df_final.copy()
if 'ticket_url' in df_excel.columns:
    df_excel['ticket_url'] = df_excel.apply(
        lambda row: f'=HYPERLINK("{row["ticket_url"]}";"{row.get("key", "Lien")}")'
        if pd.notna(row.get('ticket_url')) else '',
        axis=1
    )
df_excel.to_csv(excel_output, index=False, sep=';', encoding='utf-8-sig')
print(f"[INFO] Export avec hyperlinks: {excel_output}", file=sys.stderr)

PYTHON_SCRIPT
}

main() {
    validate_config
    mkdir -p "$OUTPUT_DIR"
    
    log_info "=== Extraction JIRA projet $JIRA_PROJECT ==="
    log_info "Instance: $JIRA_BASE_URL"
    
    # Découverte des champs personnalisés
    discover_custom_fields
    
    # Extraction
    local issues
    issues=$(fetch_all_issues)
    
    # Traitement
    local timestamp
    timestamp=$(date +%Y%m%d_%H%M%S)
    local output_file="${OUTPUT_DIR}/${JIRA_PROJECT}_export_${timestamp}.csv"
    
    export JIRA_BASE_URL EXISTING_CSV OUTPUT_FILE="$output_file"
    echo "$issues" | process_and_merge "$issues" "$EXISTING_CSV" "$output_file"
    
    log_info "=== Extraction terminée ==="
    log_info "Fichiers générés dans: $OUTPUT_DIR"
    ls -la "$OUTPUT_DIR"/*.csv 2>/dev/null || true
}

main "$@"
```

## Fichier de configuration `.env`

```bash
# .env - NE PAS COMMITER
JIRA_BASE_URL=https://votre-instance.atlassian.net
JIRA_EMAIL=pascal.froment@arval.com
JIRA_TOKEN=votre_api_token
JIRA_PROJECT=URLC
EXISTING_CSV=./FICHIER_INVENTAIRE_URLC.csv
```

## Utilisation

```bash
# Installation dépendances
pip install pandas openpyxl --break-system-packages

# Rendre exécutable
chmod +x extract_jira_to_csv.sh

# Exécution
source .env && ./extract_jira_to_csv.sh
```

## Fichiers générés

|Fichier                              |Description                                  |
|-------------------------------------|---------------------------------------------|
|`custom_fields_mapping.txt`          |Liste des champs personnalisés avec leurs IDs|
|`URLC_export_YYYYMMDD.csv`           |Export CSV standard                          |
|`URLC_export_YYYYMMDD_hyperlinks.csv`|CSV avec formules `=HYPERLINK()` pour Excel  |

## Concernant les liens cliquables

Deux options selon votre usage :

1. **CSV standard** : L’URL est en texte brut, cliquable dans Excel si la colonne est formatée
1. **CSV avec hyperlinks** : Contient la formule `=HYPERLINK("url";"texte")` — à ouvrir dans Excel et sauvegarder en `.xlsx` pour activer les liens

Souhaitez-vous que j’ajoute une conversion automatique vers `.xlsx` avec liens actifs via `openpyxl` ?​​​​​​​​​​​​​​​​
