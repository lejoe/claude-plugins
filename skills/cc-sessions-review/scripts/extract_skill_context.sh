#!/bin/bash
set -euo pipefail

# Extract installed skills and check for agents.md
# Usage: extract_skill_context.sh [project_root]
# Output: JSON with installed_skills[], has_claude_md, has_agents_md, agents_md_path

PROJECT_ROOT="${1:-.}"

# Check for CLAUDE.md
CLAUDE_MD="false"
[ -f "$PROJECT_ROOT/CLAUDE.md" ] && CLAUDE_MD="true"
[ -f "$PROJECT_ROOT/.claude/CLAUDE.md" ] && CLAUDE_MD="true"

# Check for agents.md
AGENTS_MD="false"
AGENTS_MD_PATH=""
if [ -f "$PROJECT_ROOT/agents.md" ]; then
  AGENTS_MD="true"
  AGENTS_MD_PATH="agents.md"
elif [ -f "$PROJECT_ROOT/.claude/agents.md" ]; then
  AGENTS_MD="true"
  AGENTS_MD_PATH=".claude/agents.md"
fi

# Extract installed skills
SKILLS_JSON="[]"
if [ -d "$PROJECT_ROOT/skills" ]; then
  SKILLS_JSON=$(for f in "$PROJECT_ROOT"/skills/*/SKILL.md; do
    if [ -f "$f" ]; then
      grep '^name:' "$f" 2>/dev/null | sed 's/name: *//' || true
    fi
  done | jq -R -s -c 'split("\n") | map(select(length > 0))')
fi

# Output JSON
jq -n \
  --argjson skills "$SKILLS_JSON" \
  --arg has_claude "$CLAUDE_MD" \
  --arg has_agents "$AGENTS_MD" \
  --arg agents_path "$AGENTS_MD_PATH" \
  '{
    installed_skills: $skills,
    has_claude_md: ($has_claude == "true"),
    has_agents_md: ($has_agents == "true"),
    agents_md_path: $agents_path
  }'
