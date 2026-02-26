# Data Collection Tool

A Dockerized tool for scheduling data collection tasks and aggregating daily summaries, built on Alpine Linux.

## Features
- **Automated Data Collection**: Runs every 5 minutes via cron.
- **Daily Summaries**: Aggregates metrics (memory, disk usage) at 23:50 daily.
- **Web Interface**: Exposes collected data via a lightweight HTTP server on port 8000.
- **Persistent Storage**: Saves data to a volume.

## Deployment

### 1. Build the Docker Image
Navigate to the directory containing the Dockerfile and run:
```bash
docker build -t data-collector .
```

### 2. Run the Container
Run the container with a volume mount for persistence and port mapping for the web interface.
```bash
docker run -d \
    --name data-collector-instance \
    -v $(pwd)/data:/data \
    -p 8000:8000 \
    --restart unless-stopped \
    data-collector
```

### Authentication Handling
If your data collection script requires API keys or credentials, pass them as environment variables.

**Using `-e` flag:**
```bash
docker run -d \
    --name data-collector-instance \
    -v $(pwd)/data:/data \
    -p 8000:8000 \
    -e API_KEY="your_secure_api_key" \
    data-collector
```

**Using a `.env` file:**
Create a `.env` file:
```env
API_KEY=your_secure_api_key
DB_PASSWORD=secret
```
Run with `--env-file`:
```bash
docker run -d \
    --name data-collector-instance \
    -v $(pwd)/data:/data \
    -p 8000:8000 \
    --env-file .env \
    data-collector
```

**Rotating Credentials:**
To rotate credentials without losing data:
1. Stop the container: `docker stop data-collector-instance`
2. Remove the container: `docker rm data-collector-instance`
3. Start a new container with updated credentials (the data volume persists):
   ```bash
   docker run -d ... -e API_KEY="new_key" ...
   ```

## Verification

After deployment, verify the service is running correctly:

1.  **Check Container Status**:
    ```bash
    docker ps | grep data-collector
    ```

2.  **Check Logs**:
    Verify cron and server startup logs:
    ```bash
    docker logs data-collector-instance
    ```

3.  **Dry-Run Collection Script**:
    Manually execute the collection script to ensure it works:
    ```bash
    docker exec data-collector-instance /usr/local/bin/collect.sh
    ```
    Check the output for success messages.

4.  **Verify Web Interface**:
    Open `http://localhost:8000` in your browser or use curl:
    ```bash
    curl http://localhost:8000
    ```
    You should see the directory listing or the collected data files.

## Directory Structure
- `/data/YYYY-MM-DD/`: Daily data directories.
- `/data/YYYY-MM-DD/data_HH-MM-SS.json`: Individual data points.
- `/data/YYYY-MM-DD/daily_summary.json`: Daily summary report.
