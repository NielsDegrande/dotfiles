#!/bin/sh

today=$(date +"%Y-%m-%d")
SOURCE_FILE="/Users/niels/Documents/notes/notes.md"
DEST_DIR="/Users/niels/Documents/notes/archive"
DEST_FILE="$DEST_DIR/${today}_notes.md"

# Exit quietly when there is nothing to archive — cron mails every failure.
[ -f "$SOURCE_FILE" ] || exit 0

/bin/mkdir -p "$DEST_DIR"
cp "$SOURCE_FILE" "$DEST_FILE"
