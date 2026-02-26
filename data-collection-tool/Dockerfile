FROM alpine:latest

# Install bash, cron, python3, and common CLI dependencies
# cleaning package manager caches is handled by --no-cache
RUN apk add --no-cache \
    bash \
    curl \
    jq \
    ca-certificates \
    python3

# Create directory for data
RUN mkdir -p /data

# Workdir for scripts
WORKDIR /app

# Copy scripts
COPY collect.sh /usr/local/bin/collect.sh
RUN chmod +x /usr/local/bin/collect.sh

COPY summarize.sh /usr/local/bin/summarize.sh
RUN chmod +x /usr/local/bin/summarize.sh

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Add scripts to crontab
# Alpine's crond uses /etc/crontabs/root
# Run collect.sh every 5 minutes
RUN echo "*/5 * * * * /usr/local/bin/collect.sh >> /var/log/cron.log 2>&1" >> /etc/crontabs/root
# Run summarize.sh at 23:50 daily
RUN echo "50 23 * * * /usr/local/bin/summarize.sh >> /var/log/cron.log 2>&1" >> /etc/crontabs/root

# Expose web server port
EXPOSE 8000

# Set entrypoint to run services
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
