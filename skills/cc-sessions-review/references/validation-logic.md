# Skill Recommendation Validation Logic

## Purpose

Prevent suggesting duplicate skills and detect agents.md symlink opportunities.

## Data Collection

### Step 2: Session Parsing
- Extract skill invocations from user messages
- Pattern: `/skill-name` in user text
- Script: `extract_used_skills.sh SESSION_FILE`
- Output: One skill name per line (deduplicated)

### Step 3: Codebase Context
- Script: `extract_skill_context.sh PROJECT_ROOT`
- Extracts:
  - All installed skills from `skills/*/SKILL.md` (grep `^name:`)
  - CLAUDE.md existence (project root and `.claude/`)
  - agents.md existence and path
- Output: JSON with `installed_skills[]`, `has_claude_md`, `has_agents_md`, `agents_md_path`

## Validation Rules

### Rule 1: Prevent Duplicate Skills

Before suggesting skill creation in Step 6:

1. Extract suggested skill name from recommendation
2. Check if name exists in `installed_skills[]` (from Step 3)
3. Check if name exists in skills detected in Step 2
4. **If exists:**
   - Change recommendation type to "Enhance existing skill: [name]"
   - Describe what functionality to add to existing skill
   - Reference the existing skill's location
5. **If not exists:**
   - Proceed with "Create new skill: [name]" recommendation

**Why exact matching:** Fuzzy matching could misidentify skills. Safer to suggest creation with a note if user believes skill exists.

### Rule 2: Agents.md Symlink

In Step 6, before presenting recommendations:

1. Check: `has_claude_md == false AND has_agents_md == true`
2. If condition met, prepend recommendation:
   ```
   Create agents.md symlink for CLAUDE.md compatibility:
   `ln -s <agents_md_path> <target_path>`

   Explanation: Claude Code looks for CLAUDE.md. Creating a symlink from
   agents.md ensures compatibility without file duplication.
   ```
3. Target path should match source location:
   - If `agents.md` in root → `CLAUDE.md` in root
   - If `.claude/agents.md` → `.claude/CLAUDE.md`

## Implementation Examples

### Example 1: Duplicate Skill Detection

**Session analysis finds:** User manually runs test commands repeatedly

**Draft recommendation:** "Create a 'test-runner' skill"

**Validation:**
- Check `installed_skills[]`: `['brainstorm', 'cc-sessions-review', 'test-runner']`
- Match found: `test-runner` exists
- **Updated recommendation:** "Enhance test-runner skill to include automated test detection and failure reporting"

### Example 2: Agents.md Symlink

**Step 3 context:**
```json
{
  "has_claude_md": false,
  "has_agents_md": true,
  "agents_md_path": ".claude/agents.md"
}
```

**Step 6 prepends recommendation:**
```
Create symlink for CLAUDE.md compatibility:
`ln -s .claude/agents.md .claude/CLAUDE.md`

Claude Code looks for CLAUDE.md. This symlink ensures compatibility without duplicating content.
```

### Example 3: Skill Used but Not Installed

**Session shows:** `/deep-research` used in conversation

**Draft recommendation:** "Create deep-research skill"

**Validation:**
- Detected in Step 2 used skills: `deep-research`
- Not in `installed_skills[]`
- **Result:** Data inconsistency - skill was used but not installed (shouldn't happen)
- **Action:** Log warning, treat as "exists" to avoid duplicate suggestion

## Edge Cases

### Both CLAUDE.md and agents.md exist
- Don't suggest symlink (already have CLAUDE.md)
- Optionally note both exist if they diverge in content

### Skill name mismatch
- User types `/review` but skill is `cc-sessions-review`
- With exact matching: won't detect as duplicate
- Recommendation: suggest creation, user will notice if duplicate

### Skill exists but wasn't invoked
- Still prevent duplicate creation based on `installed_skills[]`
- Recommendation: enhance existing OR create with different name

### Multiple sessions, union of skills
- Merge used skills across all analyzed sessions
- Deduplicate before validation in Step 6

## Helper Scripts

### extract_skill_context.sh
```bash
# Usage: extract_skill_context.sh [project_root]
# Output: JSON with installed_skills[], has_claude_md, has_agents_md, agents_md_path
```

### extract_used_skills.sh
```bash
# Usage: extract_used_skills.sh SESSION_FILE
# Output: One skill name per line (deduplicated, sorted)
```

## Testing Validation

1. **Test duplicate prevention:**
   - Run skill on session mentioning existing skill
   - Verify recommendation suggests enhancement, not creation

2. **Test agents.md detection:**
   - Create test project with `agents.md` but no `CLAUDE.md`
   - Verify symlink recommendation appears

3. **Test skill usage detection:**
   - Run skill on session where user invoked skills
   - Verify detected skills appear in validation

4. **Test helper scripts:**
   - `extract_skill_context.sh .` outputs valid JSON
   - `extract_used_skills.sh SESSION_FILE` outputs skill names
