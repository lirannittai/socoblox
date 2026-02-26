#!/bin/bash
set -e

# Function to handle shutdown
cleanup() {
    echo "Received termination signal. Shutting down..."

    if [ -n "$SERVER_PID" ]; then
        kill -TERM "$SERVER_PID" 2>/dev/null
    fi

    # Kill cron daemon
    pkill crond || true

    wait "$SERVER_PID"
    exit 0
}

# Trap signals
trap cleanup SIGTERM SIGINT

echo "Starting cron daemon..."
# -b for background (default for crond, but explicit is good)
# -l 2 for log level (info)
# -L /var/log/cron.log to log to file (useful since we are in background)
crond -b -l 2 -L /var/log/cron.log

echo "Starting web server on port 8000..."
# Ensure data directory exists
mkdir -p /data
cd /data

# Start python http.server in background
python3 -m http.server 8000 &
SERVER_PID=$!

echo "Services started. Web server PID: $SERVER_PID"

# Wait for the web server process
wait "$SERVER_PID"
