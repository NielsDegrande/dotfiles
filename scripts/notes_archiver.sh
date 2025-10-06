#!/bin/sh

today=$(date +"%Y-%m-%d")
SOURCE_FILE="/Users/degrandeniels/Library/CloudStorage/OneDrive-TheBostonConsultingGroup,Inc/Notes/notes.md"
DEST_DIR="/Users/degrandeniels/Library/CloudStorage/OneDrive-TheBostonConsultingGroup,Inc/Notes/Archive"
DEST_FILE="$DEST_DIR/${today}_notes.md"

/bin/mkdir -p "$DEST_DIR"
cp "$SOURCE_FILE" "$DEST_FILE"
