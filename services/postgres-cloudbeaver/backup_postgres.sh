#!/bin/bash

# Determine the script's directory
# SCRIPT_DIR=/home/hs_admin/HomeServer/services/postgres-cloudbeaver
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load environment variables from .env file in the script's directory
if [ -f "$SCRIPT_DIR/.env" ]; then
    source "$SCRIPT_DIR/.env"
else
    echo ".env file not found in $SCRIPT_DIR! Exiting."
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
docker exec -t $CONTAINER_NAME pg_dump -U $POSTGRES_USER $POSTGRES_DB > $BACKUP_FILE
echo "[POSTGRESQL] Backup completed: $BACKUP_FILE"

# Check and delete backups older than 90 days
echo "[POSTGRESQL] Checking for backups older than 90 days..."
OLD_BACKUPS=$(find "$BACKUP_DIR" -type f -mtime +90)

if [ -z "$OLD_BACKUPS" ]; then
    echo "[POSTGRESQL] No backups older than 90 days found."
else
    # echo "The following backups are older than 90 days and will be deleted:"
    # echo "$OLD_BACKUPS"

    # Deleting the old backups
    echo "$OLD_BACKUPS" | while read -r FILE; do
        echo "[POSTGRESQL] Deleting: $FILE"
        rm -f "$FILE"
    done
    echo "[POSTGRESQL] Old backups deleted successfully."
fi