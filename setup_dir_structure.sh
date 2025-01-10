#!/bin/bash

# Prompt the user for the base directory
read -p "Enter the base directory for your home server (e.g., /homeserver): " BASE_DIR

# Create the main docker directory and subdirectories
# mkdir -p "$BASE_DIR/app-data"
mkdir -p "$BASE_DIR/services/nextcloud/data"
mkdir -p "$BASE_DIR/services/calibre/library"
mkdir -p "$BASE_DIR/services/calibre/config"
mkdir -p "$BASE_DIR/services/utorrent-client/data"
mkdir -p "$BASE_DIR/services/utorrent-client/config"
mkdir -p "$BASE_DIR/services/jellyfin/data"
mkdir -p "$BASE_DIR/services/jellyfin/config"
mkdir -p "$BASE_DIR/services/piwigo/data"
mkdir -p "$BASE_DIR/services/piwigo/config"

# Create README.md files for each service
cat <<EOL > "$BASE_DIR/services/nextcloud/README.md"
# Nextcloud
Documentation for setting up and configuring Nextcloud.
EOL

cat <<EOL > "$BASE_DIR/services/calibre/README.md"
# Calibre
Documentation for setting up and configuring Calibre.
EOL

cat <<EOL > "$BASE_DIR/services/utorrent-client/README.md"
# uTorrent Client
Documentation for setting up and configuring uTorrent Client.
EOL

cat <<EOL > "$BASE_DIR/services/jellyfin/README.md"
# Jellyfin
Documentation for setting up and configuring Jellyfin.
EOL

cat <<EOL > "$BASE_DIR/services/piwigo/README.md"
# Piwigo
Documentation for setting up and configuring Piwigo.
EOL

# # Create a central README file in the root directory
# cat <<EOL > /homeserver/README.md
# # Home Server Setup

# This document provides an overview of the home server setup, including services and configurations.

# ## Services

# - Nextcloud
# - Calibre
# - uTorrent Client
# - Jellyfin
# - Piwigo

# Each service has its own directory under /homeserver/docker/services.
# EOL

echo "Directory structure created successfully."
