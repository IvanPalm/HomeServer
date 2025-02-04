#!/bin/bash

# Ask the user for the music directory
read -p "Enter the folder containing MP3 files: " MUSIC_DIR

# Check if directory exists
if [[ ! -d "$MUSIC_DIR" ]]; then
    echo "Error: Directory '$MUSIC_DIR' does not exist."
    exit 1
fi

# Ask for the album name
echo "Enter the album name to assign:"
read -r album_name

# Assign the album name to all MP3 files in the folder
echo "Assigning album name '$album_name' to all MP3 files in '$MUSIC_DIR'..."
find "$MUSIC_DIR" -type f -iname "*.mp3" -print0 | while IFS= read -r -d '' file; do
    echo "Tagging: $file"
    id3v2 --album "$album_name" "$file"
done

echo "Album assignment complete!"
