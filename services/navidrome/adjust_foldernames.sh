#!/bin/bash

# Prompt the user for the root music directory
DEFAULT_DIR="./music"
read -p "Is your music folder '$DEFAULT_DIR'? (y/n): " CONFIRM
if [[ "$CONFIRM" != "y" ]]; then
    read -p "Enter the full path to your music folder: " MUSIC_DIR
else
    MUSIC_DIR="$DEFAULT_DIR"
fi

# Check if the directory exists
if [[ ! -d "$MUSIC_DIR" ]]; then
    echo "Error: Directory does not exist."
    exit 1
fi

# Function to sanitize folder names
sanitize() {
    local name="$1"
    
    # Convert to UTF-8 (ignoring invalid characters)
    name=$(echo "$name" | iconv -f utf-8 -t utf-8//IGNORE)
    
    # Convert to lowercase
    name=$(echo "$name" | tr '[:upper:]' '[:lower:]')
    
    # Replace " - " with "-"
    name=$(echo "$name" | sed 's/ - /-/g')
    
    # Replace spaces with underscores
    name=$(echo "$name" | tr ' ' '_')
    
    # Remove special characters except "_" and "-"
    name=$(echo "$name" | sed 's/[^a-z0-9_-]//g')

    echo "$name"
}

# Process all folders recursively (starting from the deepest)
find "$MUSIC_DIR" -depth -type d | while IFS= read -r folder; do
    PARENT_DIR=$(dirname "$folder")
    BASE_NAME=$(basename "$folder")

    NEW_NAME=$(sanitize "$BASE_NAME")
    NEW_FOLDER="$PARENT_DIR/$NEW_NAME"

    if [[ "$folder" != "$NEW_FOLDER" ]]; then
        mv "$folder" "$NEW_FOLDER"
        echo "Renamed: $folder → $NEW_FOLDER"
    fi
done

echo "All folders renamed successfully!"
