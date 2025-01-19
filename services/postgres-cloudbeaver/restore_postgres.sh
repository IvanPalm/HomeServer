#!/bin/bash

# Script to restore a PostgreSQL database from a backup file using Docker.
# The script prompts the user to enter the required variables for the restoration process.

# Prompt the user for input
read -p "Enter the path to the backup file: " BACKUP_FILE
read -p "Enter the name of the Docker container: " CONTAINER_NAME
read -p "Enter the name of the PostgreSQL database: " DB_NAME
read -p "Enter the database username: " DB_USER
read -sp "Enter the database password: " DB_PASSWORD
echo

# Export the database password for the current session
export PGPASSWORD=$DB_PASSWORD

# Check if the backup file exists
if [ ! -f "$BACKUP_FILE" ]; then
  echo "Error: Backup file '$BACKUP_FILE' does not exist."
  exit 1
fi

# Restore the database
echo "Restoring the database..."
cat "$BACKUP_FILE" | docker exec -i "$CONTAINER_NAME" psql -U "$DB_USER" -d "$DB_NAME"

# Check the exit status of the restoration command
if [ $? -eq 0 ]; then
  echo "Database successfully restored from: $BACKUP_FILE"
else
  echo "Error: Database restoration failed."
fi
