#!/bin/bash
set -euo pipefail

# Discover Claude Code session files for the current project.
# Usage: discover_sessions.sh [scope]
# Scopes: current (default), today, week, month, last-N
# Output: one session file path per line, newest first

PROJECT_PATH="$(pwd)"
NORMALIZED=$(echo "$PROJECT_PATH" | sed 's|/|-|g')
SESSION_DIR="$HOME/.claude/projects/$NORMALIZED"

if [ ! -d "$SESSION_DIR" ]; then
  echo "ERROR: No session directory found at $SESSION_DIR" >&2
  exit 1
fi

SCOPE="${1:-current}"

list_sessions() {
  # List .jsonl files, exclude agent-* (sub-agent sessions), sort newest first
  find "$SESSION_DIR" -maxdepth 1 -name "*.jsonl" -not -name "agent-*" -type f -print0 \
    | xargs -0 ls -t 2>/dev/null
}

filter_by_date() {
  local days="$1"
  find "$SESSION_DIR" -maxdepth 1 -name "*.jsonl" -not -name "agent-*" -type f -mtime "-${days}" -print0 \
    | xargs -0 ls -t 2>/dev/null
}

case "$SCOPE" in
  current)
    if [ -n "${CLAUDE_SESSION_ID:-}" ]; then
      SESSION_FILE="$SESSION_DIR/${CLAUDE_SESSION_ID}.jsonl"
      if [ -f "$SESSION_FILE" ]; then
        echo "$SESSION_FILE"
      else
        list_sessions | head -1
      fi
    else
      list_sessions | head -1
    fi
    ;;
  today)
    filter_by_date 1
    ;;
  week)
    filter_by_date 7
    ;;
  month)
    filter_by_date 30
    ;;
  last-*)
    N="${SCOPE#last-}"
    if ! [[ "$N" =~ ^[0-9]+$ ]]; then
      echo "ERROR: Invalid count in '$SCOPE'. Use last-N where N is a number." >&2
      exit 1
    fi
    list_sessions | head -"$N"
    ;;
  *)
    echo "ERROR: Unknown scope '$SCOPE'. Use: current, today, week, month, last-N" >&2
    exit 1
    ;;
esac
