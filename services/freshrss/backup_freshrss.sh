#!/bin/bash

# Function to log messages with timestamps
log_message() {
    local message="$1"
    echo "$(date +"%Y-%m-%d %H:%M:%S") $message"
}

# Determine the script's directory (assumed to be the FreshRSS installation)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FRESHRSS_CONFIG_DIR="$SCRIPT_DIR/config"
FRESHRSS_DATA_DIR="$SCRIPT_DIR/data"

# Load environment variables from .env file
if [ -f "$SCRIPT_DIR/.env" ]; then
    source "$SCRIPT_DIR/.env"
else
    log_message "[FRESHRSS][ERROR] .env file not found in $SCRIPT_DIR! Exiting."
    exit 1
fi

# Variables from .env file
BACKUP_DIR=${BACKUP_DIR}
CONTAINER_NAME=freshrss
DOCKER_COMPOSE_FILE="$SCRIPT_DIR/docker-compose.yaml"

# Get current date and time for backup filename
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="$BACKUP_DIR/${TIMESTAMP}_freshrss_backup.tar.gz"

# Ensure backup directory exists
if [ ! -d "$BACKUP_DIR" ]; then
    log_message "[FRESHRSS] Creating backup directory: $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
fi

# Stop FreshRSS container before backup
log_message "[FRESHRSS] Stopping FreshRSS container..."
if docker compose -f "$DOCKER_COMPOSE_FILE" stop "$CONTAINER_NAME"; then
    log_message "[FRESHRSS] FreshRSS container stopped successfully."
else
    log_message "[FRESHRSS][ERROR] Failed to stop FreshRSS container. Proceeding with backup anyway."
fi

# Create backup archive of config and data directories
log_message "[FRESHRSS] Creating backup archive..."
if tar -czf "$BACKUP_FILE" -C "$SCRIPT_DIR" config data; then
    log_message "[FRESHRSS] Backup completed successfully: $BACKUP_FILE"
else
    log_message "[FRESHRSS][ERROR] Backup failed."
fi

# Start FreshRSS container again
log_message "[FRESHRSS] Starting FreshRSS container..."
if docker compose -f "$DOCKER_COMPOSE_FILE" start "$CONTAINER_NAME"; then
    log_message "[FRESHRSS] FreshRSS container started successfully."
else
    log_message "[FRESHRSS][ERROR] Failed to start FreshRSS container. Manual intervention required."
fi

# Cleanup: Delete backups older than 90 days
log_message "[FRESHRSS] Checking for backups older than 90 days..."
OLD_BACKUPS=$(find "$BACKUP_DIR" -type f -mtime +90)

if [ -z "$OLD_BACKUPS" ]; then
    log_message "[FRESHRSS] No old backups found."
else
    echo "$OLD_BACKUPS" | while read -r FILE; do
        log_message "[FRESHRSS] Deleting old backup: $FILE"
        rm -f "$FILE"
    done
    log_message "[FRESHRSS] Old backups deleted successfully."
fi
