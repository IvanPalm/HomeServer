#!/bin/bash

# Prompt the user for the base directory
read -p "Enter the base directory for your home server (e.g., /homeserver): " BASE_DIR

# Function to create directory and README if they don't exist
create_dir_and_readme() {
    local dir="$1"
    local service_name="$2"
    
    if [ -d "$dir" ]; then
        echo "Folder $dir exists. Skipping."
    else
        mkdir -p "$dir"
        echo "Created folder: $dir"
    fi
    
    local readme_file="$dir/README.md"
    if [ -f "$readme_file" ]; then
        echo "README for $service_name exists. Skipping."
    else
        cat <<EOL > "$readme_file"
# $service_name
Documentation for setting up and configuring $service_name.
EOL
        echo "Created README for $service_name"
    fi
}

# List of services
services=(
    "nextcloud"
    "calibre"
    "utorrent-client"
    "jellyfin"
    "piwigo"
    "caddy"
    "freshrss"
)

# Create directories and README files for each service
for service in "${services[@]}"; do
    create_dir_and_readme "$BASE_DIR/services/$service/data" "$service"
    create_dir_and_readme "$BASE_DIR/services/$service/config" "$service"
done

echo "Directory structure created successfully."
