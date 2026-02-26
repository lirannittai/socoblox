#!/bin/bash
set -euo pipefail

# Logging configuration
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

log() {
    local level=$1
    local msg=$2
    local color=$NC
    case $level in
        INFO) color=$GREEN ;;
        ERROR) color=$RED ;;
    esac
    echo -e "${color}[$(date +'%Y-%m-%dT%H:%M:%S%z')] [${level}] ${msg}${NC}" >&2
}

# Configuration
DATA_DIR="/data/$(date +'%Y-%m-%d')"
SUMMARY_FILE="${DATA_DIR}/daily_summary.json"

log "INFO" "Starting daily summary..."

# Check if data directory exists
if [ ! -d "$DATA_DIR" ]; then
    log "ERROR" "Data directory $DATA_DIR does not exist. No data collected today."
    exit 0
fi

# Locate JSON files
FILES=$(find "$DATA_DIR" -name "data_*.json" -type f)

if [ -z "$FILES" ]; then
    log "INFO" "No data files found for today."
    echo "{ \"status\": \"no_data\", \"date\": \"$(date +'%Y-%m-%d')\" }" > "$SUMMARY_FILE"
    exit 0
fi

# Calculate statistics using jq
# memory_usage_mb and disk_usage_percent are expected fields
# We handle potential missing fields with default values or errors if critical
STATS=$(cat $FILES | jq -s '
    {
        count: length,
        avg_mem: (map(.memory_usage_mb | tonumber) | add / length),
        max_mem: (map(.memory_usage_mb | tonumber) | max),
        avg_disk: (map(.disk_usage_percent | tonumber) | add / length),
        max_disk: (map(.disk_usage_percent | tonumber) | max)
    }
')

# Extract values from STATS JSON
COUNT=$(echo "$STATS" | jq -r '.count')
AVG_MEM=$(echo "$STATS" | jq -r '.avg_mem')
MAX_MEM=$(echo "$STATS" | jq -r '.max_mem')
AVG_DISK=$(echo "$STATS" | jq -r '.avg_disk')
MAX_DISK=$(echo "$STATS" | jq -r '.max_disk')

# Create summary JSON
jq -n \
    --arg date "$(date +'%Y-%m-%d')" \
    --arg count "$COUNT" \
    --arg avg_mem "$AVG_MEM" \
    --arg avg_disk "$AVG_DISK" \
    --arg max_mem "$MAX_MEM" \
    --arg max_disk "$MAX_DISK" \
    '{
        date: $date,
        total_samples: ($count | tonumber),
        metrics: {
            memory: {
                average_mb: ($avg_mem | tonumber),
                max_mb: ($max_mem | tonumber)
            },
            disk: {
                average_percent: ($avg_disk | tonumber),
                max_percent: ($max_disk | tonumber)
            }
        },
        status: "success"
    }' > "$SUMMARY_FILE"

log "INFO" "Daily summary generated at $SUMMARY_FILE"
