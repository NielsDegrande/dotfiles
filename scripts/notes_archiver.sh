#!/bin/sh

today=$(date +"%Y-%m-%d")
SOURCE_FILE="/Users/niels/documents/notes/notes.md"
DEST_DIR="/Users/niels/documents/notes/archive"
DEST_FILE="$DEST_DIR/${today}_notes.md"

/bin/mkdir -p "$DEST_DIR"
cp "$SOURCE_FILE" "$DEST_FILE"
