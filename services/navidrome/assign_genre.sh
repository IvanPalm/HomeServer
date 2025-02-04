#!/bin/bash

# Script to assign genre tags to MP3 files based on folder selection
# Author: Ivan Palmegiani
# Date: 2025-02-02

# Ask the user for the music directory
read -p "Use default directory (/music)? (y/n): " use_default
if [[ "$use_default" != "y" ]]; then
    read -p "Enter the music directory: " MUSIC_DIR
else
    MUSIC_DIR="music"
fi

# Check if directory exists
if [[ ! -d "$MUSIC_DIR" ]]; then
    echo "Error: Directory '$MUSIC_DIR' does not exist."
    exit 1
fi

# Get list of folders (albums) in the directory
mapfile -t folder_list < <(find "$MUSIC_DIR" -mindepth 1 -maxdepth 1 -type d | sort)

# Check if there are any folders
if [[ ${#folder_list[@]} -eq 0 ]]; then
    echo "No albums (folders) found in '$MUSIC_DIR'."
    exit 1
fi

# Print available folders for selection
echo "Available albums (folders):"
for i in "${!folder_list[@]}"; do
    echo "$((i+1)). ${folder_list[$i]##*/}"
done

# User selects folder
echo "Enter the number of the folder you want to assign a genre to:"
read -r folder_index

# Validate selection
if ! [[ "$folder_index" =~ ^[0-9]+$ ]] || (( folder_index < 1 || folder_index > ${#folder_list[@]} )); then
    echo "Invalid selection. Please enter a valid number."
    exit 1
fi

selected_folder="${folder_list[$((folder_index-1))]}"

# Ask for the genre
echo "Enter genre for folder: ${selected_folder##*/}"
read -r genre

# Assign genre to all MP3 files in the selected folder
echo "Tagging files with genre '$genre' in '${selected_folder##*/}'..."
find "$selected_folder" -type f -iname "*.mp3" -print0 | while IFS= read -r -d '' file; do
    echo "Tagging: $file"
    id3v2 --genre "$genre" "$file"
done

# Select a random MP3 file from the folder for verification
random_file=$(find "$selected_folder" -type f -iname "*.mp3" | shuf -n 1)

# Check if genre was correctly assigned
if [[ -n "$random_file" ]]; then
    assigned_genre=$(id3v2 -R "$random_file" | grep "TCON" | cut -d ':' -f 2- | xargs)
    
    if [[ "$assigned_genre" == "$genre" ]]; then
        echo "Genre '$genre' successfully assigned to a track in '${selected_folder##*/}'."
    else
        echo "Warning: Genre assignment may have failed. Assigned genre: '$assigned_genre' (Expected: '$genre')"
    fi
else
    echo "Warning: No MP3 files found in '${selected_folder##*/}' for verification."
fi

echo "Genre assignment process complete!"
