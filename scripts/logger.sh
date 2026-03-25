#!/bin/zsh
set -euo pipefail

entry="$(cat)"

file="$HOME/Documents/notes/log.md"
mkdir -p "$(dirname "$file")"

day="$(date +%F)"
time="$(date +%H:%M)"

# Ensure file exists
if [[ ! -f "$file" ]]; then
  printf '# Log\n\n## %s\n\n' "$day" > "$file"
else
  # Ensure शीर्ष title exists at top
  first_line="$(head -n 1 "$file" || true)"
  if [[ "$first_line" != "# Log" ]]; then
    tmp="$(mktemp)"
    printf '# Log\n\n' > "$tmp"
    cat "$file" >> "$tmp"
    mv "$tmp" "$file"
  fi

  # Ensure today's section exists
  last_header="$(grep '^## ' "$file" | tail -n 1 || true)"
  if [[ "$last_header" != "## $day" ]]; then
    printf '\n## %s\n\n' "$day" >> "$file"
  fi
fi

# Append entry
printf -- '- %s %s\n' "$time" "$entry" >> "$file"

# Output yesterday's and today's sections
yesterday="$(date -v-1d +%F)"
awk -v yesterday="$yesterday" -v today="$day" '
  $0 == "## " yesterday || $0 == "## " today { printing=1 }
  printing {
    if ($0 ~ /^## / && $0 != "## " yesterday && $0 != "## " today) exit
    print
  }
' "$file"
