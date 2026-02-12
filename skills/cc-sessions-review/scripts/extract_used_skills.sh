#!/bin/bash
set -euo pipefail

# Extract skill names invoked in a session file
# Usage: extract_used_skills.sh SESSION_FILE
# Output: One skill name per line (deduplicated, sorted)

SESSION_FILE="$1"

if [ ! -f "$SESSION_FILE" ]; then
  echo "ERROR: Session file not found: $SESSION_FILE" >&2
  exit 1
fi

# Extract user messages and find skill invocations (pattern: /skill-name)
# Only match at start of line or after whitespace to avoid catching paths
jq -r '
  select(.type == "user" and .userType == "external") |
  .message.content |
  if type == "string" then .
  elif type == "array" then
    [.[] | select(.type == "text") | .text] | join("\n")
  else empty end
' "$SESSION_FILE" 2>/dev/null |
grep -oE '(^|[[:space:]])/[a-z][a-z0-9-]+' || true |
sed 's|^[[:space:]]*||' |
sed 's|^/||' |
grep -v '^Users$' || true |
grep -v '^home$' || true |
grep -v '^var$' || true |
grep -v '^tmp$' || true |
grep -v '^etc$' || true |
sort -u || true
