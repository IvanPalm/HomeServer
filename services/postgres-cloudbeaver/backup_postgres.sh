#!/bin/bash

# Load environment variables from .env file
if [ -f .env ]; then
    source .env
else
    echo ".env file not found! Exiting."
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
echo "Backup completed: $BACKUP_FILE"
