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
    log_message "[MARIADB][ERROR] .env file not found in $SCRIPT_DIR! Exiting."
    exit 1
fi

# Variables (loaded from .env file or fallback defaults)
CONTAINER_NAME=mariadb
BACKUP_DIR=${BACKUP_DIR}
MARIADB_DATABASE=${MARIADB_DATABASE}
MARIADB_USER=${MARIADB_USER}
MARIADB_PASSWORD=${MARIADB_PASSWORD}

# Get current date and time for backup file
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE=$BACKUP_DIR/${TIMESTAMP}_backup_${MARIADB_DATABASE}.sql

# Run mysqldump inside the MariaDB container
log_message "[MARIADB] Starting backup..."
if docker exec -i $CONTAINER_NAME mariadb-dump -u $MARIADB_USER -p$MARIADB_PASSWORD $MARIADB_DATABASE > $BACKUP_FILE; then
    if [ -f "$BACKUP_FILE" ]; then
        log_message "[MARIADB] Backup completed successfully: $BACKUP_FILE"
    else
        log_message "[MARIADB][ERROR] Backup failed: Backup file does not exist."
        exit 1
    fi
else
    log_message "[MARIADB][ERROR] Backup failed: An error occurred during the mysqldump process."
    exit 1
fi

# Check and delete backups older than 90 days
log_message "[MARIADB] Checking for backups older than 90 days..."
OLD_BACKUPS=$(find "$BACKUP_DIR" -type f -mtime +90)

if [ -z "$OLD_BACKUPS" ]; then
    log_message "[MARIADB] No backups older than 90 days found."
else
    # Deleting the old backups
    echo "$OLD_BACKUPS" | while read -r FILE; do
        log_message "[MARIADB] Deleting: $FILE"
        rm -f "$FILE"
    done
    log_message "[MARIADB] Old backups deleted successfully."
fi
