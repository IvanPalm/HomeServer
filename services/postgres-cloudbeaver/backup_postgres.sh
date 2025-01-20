#!/bin/bash

# Function to log messages with timestamps
log_message() {
    local message="$1"
    echo "$(date +"%Y-%m-%d %H:%M:%S") $message"
}

# Determine the script's directory
# SCRIPT_DIR=/home/hs_admin/HomeServer/services/postgres-cloudbeaver
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load environment variables from .env file in the script's directory
if [ -f "$SCRIPT_DIR/.env" ]; then
    source "$SCRIPT_DIR/.env"
else
    log_message "[POSTGRESQL][ERROR] .env file not found in $SCRIPT_DIR! Exiting."
    exit 1
fi

# Variables (loaded from .env file or fallback defaults)
CONTAINER_NAME=postgres
BACKUP_DIR=${BACKUP_DIR}
POSTGRES_DB=${POSTGRES_DB}
POSTGRES_USER=${POSTGRES_USER}
POSTGRES_PASSWORD=${POSTGRES_PASSWORD}

# Get current date and time for backup file
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE=$BACKUP_DIR/${TIMESTAMP}_backup_${POSTGRES_DB}.sql

# Run pg_dump inside the PostgreSQL container
log_message "[POSTGRESQL] Starting backup..."
if docker exec -t $CONTAINER_NAME pg_dump -U $POSTGRES_USER $POSTGRES_DB > $BACKUP_FILE; then
    if [ -f "$BACKUP_FILE" ]; then
        log_message "[POSTGRESQL] Backup completed successfully: $BACKUP_FILE"
    else
        log_message "[POSTGRESQL][ERROR] Backup failed: Backup file does not exist."
        exit 1
    fi
else
    log_message "[POSTGRESQL][ERROR] Backup failed: An error occurred during the pg_dump process."
    exit 1
fi

# Check and delete backups older than 90 days
log_message "[POSTGRESQL] Checking for backups older than 90 days..."
OLD_BACKUPS=$(find "$BACKUP_DIR" -type f -mtime +90)

if [ -z "$OLD_BACKUPS" ]; then
    log_message "[POSTGRESQL] No backups older than 90 days found."
else
    echo "$OLD_BACKUPS" | while read -r FILE; do
        log_message "[POSTGRESQL] Deleting: $FILE"
        rm -f "$FILE"
    done
    log_message "[POSTGRESQL] Old backups deleted successfully."
fi
