#!/bin/bash
set -euo pipefail

# Discover Claude Code session files.
# Usage: discover_sessions.sh [--all-projects] [scope]
# Scopes: current (default), today, week, month, last-N
# Output: one session file path per line, newest first

PROJECT_PATH="$(pwd)"
NORMALIZED=$(echo "$PROJECT_PATH" | sed 's|/|-|g')
PROJECTS_DIR="$HOME/.claude/projects"
SESSION_DIR="$PROJECTS_DIR/$NORMALIZED"
ALL_PROJECTS=false
SCOPE="current"

usage() {
  echo "Usage: discover_sessions.sh [--all-projects] [current|today|week|month|last-N]" >&2
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --all-projects)
      ALL_PROJECTS=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    -*)
      echo "ERROR: Unknown option '$1'" >&2
      usage
      exit 1
      ;;
    *)
      if [ "$SCOPE" != "current" ]; then
        echo "ERROR: Too many positional arguments." >&2
        usage
        exit 1
      fi
      SCOPE="$1"
      shift
      ;;
  esac
done

SESSION_ROOTS=()

if $ALL_PROJECTS; then
  if [ ! -d "$PROJECTS_DIR" ]; then
    echo "ERROR: No projects directory found at $PROJECTS_DIR" >&2
    exit 1
  fi

  while IFS= read -r project_dir; do
    SESSION_ROOTS+=("$project_dir")
  done < <(find "$PROJECTS_DIR" -mindepth 1 -maxdepth 1 -type d | sort)

  if [ "${#SESSION_ROOTS[@]}" -eq 0 ]; then
    echo "ERROR: No project session directories found in $PROJECTS_DIR" >&2
    exit 1
  fi
else
  if [ ! -d "$SESSION_DIR" ]; then
    echo "ERROR: No session directory found at $SESSION_DIR" >&2
    exit 1
  fi
  SESSION_ROOTS=("$SESSION_DIR")
fi

emit_sorted_sessions() {
  while IFS= read -r -d '' file; do
    # macOS/BSD stat format
    mtime="$(stat -f '%m' "$file" 2>/dev/null || echo 0)"
    printf '%s\t%s\n' "$mtime" "$file"
  done | sort -rn | cut -f2-
}

list_sessions() {
  # List .jsonl files, exclude agent-* (sub-agent sessions), sort newest first.
  find "${SESSION_ROOTS[@]}" -maxdepth 1 -name "*.jsonl" -not -name "agent-*" -type f -print0 \
    | emit_sorted_sessions
}

filter_by_date() {
  local days="$1"
  find "${SESSION_ROOTS[@]}" -maxdepth 1 -name "*.jsonl" -not -name "agent-*" -type f -mtime "-${days}" -print0 \
    | emit_sorted_sessions
}

find_session_by_id() {
  local session_id="$1"
  local candidate
  local project_dir

  for project_dir in "${SESSION_ROOTS[@]}"; do
    candidate="$project_dir/${session_id}.jsonl"
    if [ -f "$candidate" ]; then
      echo "$candidate"
      return 0
    fi
  done

  return 1
}

case "$SCOPE" in
  current)
    if [ -n "${CLAUDE_SESSION_ID:-}" ]; then
      if SESSION_FILE="$(find_session_by_id "$CLAUDE_SESSION_ID")"; then
        echo "$SESSION_FILE"
      else
        list_sessions | head -n 1
      fi
    else
      list_sessions | head -n 1
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
