#!/bin/bash
set -euo pipefail

# Logging configuration
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log() {
    local level=$1
    local msg=$2
    local color=$NC
    case $level in
        INFO) color=$GREEN ;;
        WARN) color=$YELLOW ;;
        ERROR) color=$RED ;;
    esac
    echo -e "${color}[$(date +'%Y-%m-%dT%H:%M:%S%z')] [${level}] ${msg}${NC}" >&2
}

# Configuration
DATA_DIR="/data/$(date +'%Y-%m-%d')"
TIMESTAMP=$(date +'%H-%M-%S')
OUTPUT_FILE="${DATA_DIR}/data_${TIMESTAMP}.json"

# Ensure data directory exists
if ! mkdir -p "$DATA_DIR"; then
    log "ERROR" "Failed to create directory $DATA_DIR"
    exit 1
fi

log "INFO" "Starting data collection..."

# Execute command (Simulated data collection: memory and disk usage)
# capturing output and exit code
if ! OUTPUT=$(
    echo "{"
    echo "  \"timestamp\": \"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\","
    echo "  \"memory_usage_mb\": $(free -m | awk '/Mem:/ {print $3}'),"
    echo "  \"disk_usage_percent\": $(df -h / | awk '/\// {print $5}' | sed 's/%//')"
    echo "}"
); then
    log "ERROR" "Failed to execute data collection command."
    exit 1
fi

# Basic validation of output
if [[ -z "$OUTPUT" ]]; then
    log "WARN" "Command returned empty output."
else
    if echo "$OUTPUT" > "$OUTPUT_FILE"; then
        log "INFO" "Data saved to $OUTPUT_FILE"
    else
        log "ERROR" "Failed to write to $OUTPUT_FILE"
        exit 1
    fi
fi

log "INFO" "Data collection complete."
