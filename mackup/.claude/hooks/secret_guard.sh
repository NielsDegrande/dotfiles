#!/bin/bash
# PreToolUse hook for Bash: block commands that reference secret files.
# The permissions.deny list only gates the Read tool, so `cat .env` via Bash
# would sail through — and in dangerously-skip-permissions mode this hook is
# the only enforcement. Exit 2 blocks the call and feeds stderr back to Claude.
#
# The pattern targets file-name shapes (an extension, or a path segment), not
# bare words, so content searches like `grep -r credentials src/` stay usable.
# Known limits: bare-word file references without a path or extension (e.g.
# `cat credentials`) pass, `*_key` matching also catches identifier greps
# (`grep api_key` — use the Grep tool for content searches), and deliberate
# obfuscation (quote-splitting like `cat .e""nv`) evades any pattern guard.
# This raises the bar; it is not a sandbox.

input=$(cat)
cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null)
[ -z "$cmd" ] && exit 0

pattern='\.env([^A-Za-z0-9_-]|$)|\.envrc|/credentials([^A-Za-z0-9_-]|$)|credentials\.[A-Za-z0-9]|secrets?\.[A-Za-z0-9]|/secrets?([^A-Za-z0-9_-]|$)|\.pem([^A-Za-z0-9]|$)|\.key([^A-Za-z0-9]|$)|[_-]key([^A-Za-z0-9._-]|$)|\.keychain|\.pgpass|\.npmrc|\.netrc|\.pfx|\.p12|\.docker/config\.json|\.kube/|\.aws/|\.ssh/|id_rsa|id_ed25519|\.config/gh/hosts\.yml|\.config/gcloud/'
if printf '%s' "$cmd" | grep -qE "$pattern"; then
  echo "Blocked by ~/.claude/hooks/secret_guard.sh: the command references a potential secrets file (mirrors permissions.deny). Have a script load secrets itself (e.g. dotenv) instead of reading them into the conversation; for content searches use the Grep tool." >&2
  exit 2
fi
exit 0
