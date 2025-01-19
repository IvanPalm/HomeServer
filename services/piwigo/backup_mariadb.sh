#!/bin/bash

# Determine the script's directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load environment variables from .env file in the script's directory
if [ -f "$SCRIPT_DIR/.env" ]; then
    source "$SCRIPT_DIR/.env"
else
    echo ".env file not found in $SCRIPT_DIR! Exiting."
    exit 1
fi

# Variables (loaded from .env file or fallback defaults)
CONTAINER_NAME=mariadb
BACKUP_DIR=${BACKUP_DIR}
MARIA_DATABASE=${MARIA_DATABASE}
MARIADB_USER=${MARIADB_USER}
MARIADB_PASSWORD=${MARIADB_PASSWORD}

# Get current date and time for backup file
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE=$BACKUP_DIR/${TIMESTAMP}_backup_${MARIA_DATABASE}.sql

# Run mysqldump inside the MariaDB container
docker exec -t $CONTAINER_NAME mysqldump -u $MARIADB_USER -p $MARIADB_PASSWORD $MARIA_DATABASE > $BACKUP_FILE
echo "[MARIADB] Backup completed: $BACKUP_FILE"

# Check and delete backups older than 90 days
echo "[MARIADB] Checking for backups older than 90 days..."
OLD_BACKUPS=$(find "$BACKUP_DIR" -type f -mtime +90)

if [ -z "$OLD_BACKUPS" ]; then
    echo "[MARIADB] No backups older than 90 days found."
else
    # Deleting the old backups
    echo "$OLD_BACKUPS" | while read -r FILE; do
        echo "[MARIADB] Deleting: $FILE"
        rm -f "$FILE"
    done
    echo "[MARIADB] Old backups deleted successfully."
fi
