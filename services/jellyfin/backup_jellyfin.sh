#!/bin/bash

# Function to log messages with timestamps
log_message() {
    local message="$1"
    echo "$(date +"%Y-%m-%d %H:%M:%S") $message"
}

# Determine the script's directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load environment variables from .env file in the script's directory
if [ -f "$SCRIPT_DIR/.env" ]; then
    source "$SCRIPT_DIR/.env"
else
    log_message "[JELLYFIN][ERROR] .env file not found in $SCRIPT_DIR! Exiting."
    exit 1
fi

# Variables (loaded from .env file)
BACKUP_DIR=${BACKUP_DIR}
JELLYFIN_CONFIG_DIR="$SCRIPT_DIR/config"
JELLYFIN_DATA_DIR="$SCRIPT_DIR/data"
CONTAINER_NAME=jellyfin
DOCKER_COMPOSE_FILE=${SCRIPT_DIR}/docker-compose.yaml

# Get current date and time for backup file
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE=$BACKUP_DIR/${TIMESTAMP}_jellyfin_backup.tar.gz

# Create backup directory if it doesn't exist
if [ ! -d "$BACKUP_DIR" ]; then
    log_message "[JELLYFIN] Creating backup directory: $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
fi

# Stop Jellyfin container before backup
log_message "[JELLYFIN] Stopping Jellyfin container..."
if docker compose -f "$DOCKER_COMPOSE_FILE" stop "$CONTAINER_NAME"; then
    log_message "[JELLYFIN] Jellyfin container stopped successfully."
else
    log_message "[JELLYFIN][ERROR] Failed to stop Jellyfin container. Proceeding with backup anyway."
fi

# Backup Jellyfin configuration and metadata
log_message "[JELLYFIN] Starting backup..."
if tar -czf "$BACKUP_FILE" -C "$SCRIPT_DIR" config data; then
    log_message "[JELLYFIN] Backup completed successfully: $BACKUP_FILE"
else
    log_message "[JELLYFIN][ERROR] Backup failed."
fi

# Start Jellyfin container again (even if backup fails)
log_message "[JELLYFIN] Starting Jellyfin container..."
if docker compose -f "$DOCKER_COMPOSE_FILE" start "$CONTAINER_NAME"; then
    log_message "[JELLYFIN] Jellyfin container started successfully."
else
    log_message "[JELLYFIN][ERROR] Failed to start Jellyfin container. Manual intervention required."
fi

# Check and delete backups older than 90 days
log_message "[JELLYFIN] Checking for backups older than 90 days..."
OLD_BACKUPS=$(find "$BACKUP_DIR" -type f -mtime +90)

if [ -z "$OLD_BACKUPS" ]; then
    log_message "[JELLYFIN] No backups older than 90 days found."
else
    # Deleting the old backups
    echo "$OLD_BACKUPS" | while read -r FILE; do
        log_message "[JELLYFIN] Deleting: $FILE"
        rm -f "$FILE"
    done
    log_message "[JELLYFIN] Old backups deleted successfully."
fi
