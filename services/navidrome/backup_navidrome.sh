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
    log_message "[NAVIDROME][ERROR] .env file not found in $SCRIPT_DIR! Exiting."
    exit 1
fi

# Variables (loaded from .env file)
BACKUP_DIR=${BACKUP_DIR}
NAVIDROME_DB="$SCRIPT_DIR/data/navidrome.db"
CONTAINER_NAME=navidrome
DOCKER_COMPOSE_FILE=${SCRIPT_DIR}/docker-compose.yaml

# Get current date and time for backup file
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE=$BACKUP_DIR/${TIMESTAMP}_navidrome_backup.db

# Create backup directory if it doesn't exist
if [ ! -d "$BACKUP_DIR" ]; then
    log_message "[NAVIDROME] Creating backup directory: $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
fi

# Check if Navidrome database exists
if [ ! -f "$NAVIDROME_DB" ]; then
    log_message "[NAVIDROME][ERROR] Navidrome database not found at $NAVIDROME_DB. Exiting."
    exit 1
fi

# Stop Navidrome container before backup
log_message "[NAVIDROME] Stopping Navidrome container..."
if docker compose -f "$DOCKER_COMPOSE_FILE" stop "$CONTAINER_NAME"; then
    log_message "[NAVIDROME] Navidrome container stopped successfully."
else
    log_message "[NAVIDROME][ERROR] Failed to stop Navidrome container. Proceeding with backup anyway."
fi

# Backup Navidrome database
log_message "[NAVIDROME] Starting backup..."
if cp "$NAVIDROME_DB" "$BACKUP_FILE"; then
    log_message "[NAVIDROME] Backup completed successfully: $BACKUP_FILE"
else
    log_message "[NAVIDROME][ERROR] Backup failed."
fi

# Start Navidrome container again (even if backup fails)
log_message "[NAVIDROME] Starting Navidrome container..."
if docker compose -f "$DOCKER_COMPOSE_FILE" start "$CONTAINER_NAME"; then
    log_message "[NAVIDROME] Navidrome container started successfully."
else
    log_message "[NAVIDROME][ERROR] Failed to start Navidrome container. Manual intervention required."
fi

# Check and delete backups older than 90 days
log_message "[NAVIDROME] Checking for backups older than 90 days..."
OLD_BACKUPS=$(find "$BACKUP_DIR" -type f -mtime +90)

if [ -z "$OLD_BACKUPS" ]; then
    log_message "[NAVIDROME] No backups older than 90 days found."
else
    # Deleting the old backups
    echo "$OLD_BACKUPS" | while read -r FILE; do
        log_message "[NAVIDROME] Deleting: $FILE"
        rm -f "$FILE"
    done
    log_message "[NAVIDROME] Old backups deleted successfully."
fi
