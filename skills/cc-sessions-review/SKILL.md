---
name: cc-sessions-review
description: This skill should be used when the user asks to "review my sessions", "analyze my chat history", "review my Claude Code usage", "find compounding opportunities", "improve my AI workflow", "session review", or wants feedback on Claude Code session patterns. Do NOT use for code review, PR review, or general conversation analysis.
argument-hint: "[scope: current|today|week|month|last-N] [--all-projects]"
disable-model-invocation: true
allowed-tools: Bash, Read, Glob, Grep, AskUserQuestion
model: sonnet
---

# CC Sessions Review

Analyze Claude Code session history using compound engineering principles. Identify anti-patterns, missed compounding opportunities, verification gaps, and undocumented knowledge. Produce actionable recommendations with implementation-ready drafts.

## Instructions

### Step 1: Resolve Scope

If `$ARGUMENTS` already includes scope information, use it directly and skip interactive scope questions.

If no scope argument is provided, ask scope at the start using AskUserQuestion:

1. Project scope:
   - `Current project`
   - `All projects`
2. Timeframe:
   - `current`
   - `today`
   - `week`
   - `month`
   - `last-N`

If user selects `last-N`, ask one follow-up question for `N` (number only), then build `last-N`.

Convert answers to script args:
- Current project + timeframe: `SCOPE_ARGS="<timeframe>"`
- All projects + timeframe: `SCOPE_ARGS="--all-projects <timeframe>"`

### Step 1.5: Discover Sessions

Run the discovery script with resolved scope:

```bash
bash ./skills/cc-sessions-review/scripts/discover_sessions.sh $SCOPE_ARGS
```

Available scopes: `current`, `today`, `week`, `month`, `last-N` (e.g., `last-5`).
Use `--all-projects` to include all `~/.claude/projects/*` session directories.

If no sessions are found, inform the user and suggest checking the project path.

### Step 2: Parse Conversations, Compute Session Stats, Detect Skill Usage

For each discovered session file, extract the conversation using jq.

Extract user messages (skip system messages starting with `<system`):
```bash
jq -r 'select(.type == "user" and .userType == "external") | .message.content | if type == "string" then . elif type == "array" then [.[] | select(.type == "text") | .text] | join("\n") else empty end' SESSION_FILE
```

Extract assistant responses with tool usage:
```bash
jq -c 'select(.type == "assistant") | {text: [.message.content[]? | select(.type == "text") | .text] | join("\n"), tools: [.message.content[]? | select(.type == "tool_use") | .name]}' SESSION_FILE
```

Extract per-session stats:
```bash
SESSION_ID="$(basename "$SESSION_FILE" .jsonl)"
SESSION_DATE="$(date -r "$SESSION_FILE" '+%Y-%m-%d %H:%M')"
SIZE_BYTES="$(wc -c < "$SESSION_FILE" | tr -d ' ')"
SIZE_KB="$(( (SIZE_BYTES + 1023) / 1024 ))"
USER_TURNS="$(jq -r 'select(.type == "user" and .userType == "external") | 1' "$SESSION_FILE" | wc -l | tr -d ' ')"
ASSISTANT_TURNS="$(jq -r 'select(.type == "assistant") | 1' "$SESSION_FILE" | wc -l | tr -d ' ')"
TOOL_CALLS="$(jq -r 'select(.type == "assistant") | .message.content[]? | select(.type == "tool_use") | 1' "$SESSION_FILE" | wc -l | tr -d ' ')"
TOOLS_USED="$(jq -r 'select(.type == "assistant") | .message.content[]? | select(.type == "tool_use") | .name' "$SESSION_FILE" | sort -u | paste -sd ',' -)"
```

Classify each session:
- **Substantial**: `USER_TURNS > 5` OR `SIZE_BYTES > 51200` (50KB)
- **Short**: not substantial
- **Abandoned**: last external user turn has no following assistant turn, or user explicitly aborts (`never mind`, `skip this`, `stop`, `forget it`)

Build a session-level table row for each file:
- ID
- Date
- User turns
- Assistant turns
- Tools used
- Size (KB)
- Class (Substantial/Short/Abandoned)

Track totals for:
- Sessions analyzed
- Substantial sessions
- Short sessions
- Abandoned sessions

**Detect skill invocations** (store for Step 6 validation):
```bash
# Extract skill names used in this session
bash ./skills/cc-sessions-review/scripts/extract_used_skills.sh SESSION_FILE
```

This detects skills invoked via `/skill-name` pattern in user messages. Store the results to check against recommendations in Step 6.

CRITICAL: For large sessions (>500 lines of output), process in chunks. Read the first 200 lines, analyze, then continue. Do not attempt to load entire large sessions into context at once.

See `references/session-parsing.md` for full JSONL format details and additional extraction patterns.

### Step 3: Check Codebase Context

Before analyzing, gather project context to make recommendations specific.

**Extract skill and configuration context** (store for Step 6 validation):
```bash
# Get installed skills, CLAUDE.md status, and agents.md detection
bash ./skills/cc-sessions-review/scripts/extract_skill_context.sh .
```

This returns JSON with:
- `installed_skills[]` - names of all installed skills
- `has_claude_md` - whether CLAUDE.md exists
- `has_agents_md` - whether agents.md exists
- `agents_md_path` - path to agents.md if found

**Additional context:**
- Read `CLAUDE.md` if it exists (check project root and `.claude/` directory)
- List commands: `ls commands/*.md 2>/dev/null`
- Check docs structure: `ls docs/ 2>/dev/null`
- Check for hooks configuration

This context determines what already exists vs. what to recommend creating.

### Step 4: Analyze Patterns

Apply the six detection categories from `references/compound-engineering-principles.md`:

1. **Compounding patterns** - Repeated problems, unextracted patterns, missed reuse, no automation
2. **Verification gaps** - User caught issues agent could have detected, including friction signals
3. **Documentation gaps** - Undocumented patterns, procedures, best practices
4. **Delegatable work** - Manual tasks suitable for agent delegation
5. **Stage progression** - Always report stage indicators and evidence
6. **Planning/work balance** - Always report turn ratios and evidence

For **Verification Gaps**, always compute friction signals:
- Correction keyword count (`no`, `that's wrong`, `actually`, `doesn't work`, `broke`)
- Topic loops: 5+ turns stuck on same issue/topic
- Abandoned thread count
- Undo/revert pattern count (`undo`, `revert`, `roll back`, `start over`)

For **Stage Progression**, always show:
- Inferred current stage
- Evidence counts supporting that stage
- Next-stage indicator (or explicitly state current stage is appropriate now)

For **Planning/Work Balance**, always show:
- Turn counts and ratios for Planning, Work, Review, Compound
- Whether ratio is healthy or imbalanced

For each finding, record:
- Category
- Evidence (specific quotes or turn references from the session)
- Impact (high/medium/low)
- Concrete recommendation

### Step 5: Generate Report

Present findings in this order:

1. **Session Overview** (always first):
```markdown
## Session Overview
Sessions analyzed: N (Substantial: N | Short: N | Abandoned: N)

| Session ID | Date | User turns | Assistant turns | Tools used | Size | Class |
|---|---|---:|---:|---|---:|---|
| ... | ... | ... | ... | ... | ...KB | Substantial |
```

2. **Summary** (always show):
```
## Session Review: [scope]
Sessions analyzed: N | Turns: N user, N assistant

### Top Recommendations
1. [Highest impact finding + action]
2. [Second highest]
3. [Third highest]
```

3. **Detailed Breakdown** (show after summary):

Show all six categories every time (never skip categories).

For each category:
- Category heading with count (or `0 critical findings`)
- Metrics and evidence (always include data)
- Findings with short evidence quotes
- Specific recommendation or explicit "healthy" note backed by metrics

Under **Verification Gaps**, include:
- `### Friction Points`
- Correction count, loop count, abandoned/undo counts, and why they matter

Do not output bare "No issues detected" without supporting data.

CRITICAL: Keep evidence quotes short (1-2 sentences). Do not reproduce entire conversation turns.

### Step 6: Offer Implementation Plan

**VALIDATION BEFORE PRESENTING RECOMMENDATIONS:**

Before presenting recommendations, validate against existing codebase (using data from Steps 2-3):

1. **Check for agents.md symlink opportunity:**
   - If `has_claude_md == false` AND `has_agents_md == true`
   - Prepend recommendation: "Create symlink for CLAUDE.md compatibility: `ln -s <agents_md_path> <target_location>`"
   - Explain: Claude Code looks for CLAUDE.md. Symlinking from agents.md ensures compatibility without duplication.

2. **Validate skill recommendations against existing skills:**
   - For each skill recommendation, extract the suggested skill name
   - Check if name exists in:
     - `installed_skills[]` from Step 3
     - Skills detected in Step 2 (used in session)
   - **If skill exists:** Change recommendation to "Enhance existing skill: [name]" + describe what functionality to add
   - **If skill doesn't exist:** Proceed with "Create new skill: [name]" recommendation

After presenting the validated report, use AskUserQuestion to ask which recommendations to implement:

```
Which recommendations should I create an implementation plan for?
Options:
1. [Recommendation 1 summary]
2. [Recommendation 2 summary]
3. [Recommendation 3 summary]
4. All recommendations
```

For selected recommendations, generate a concrete plan where every recommendation includes:
- **What to create/update**
- **Where it goes** (exact path)
- **Estimated size** (e.g., "~20 lines", "~1 file + 1 config update")

Use these output requirements:
- **agents.md symlink:** Show exact command with full paths
- **CLAUDE.md additions:** Include exact draft text in a fenced code block
- **Skill creation:** If new, include folder path and SKILL.md skeleton frontmatter:
  ```markdown
  ---
  name: <skill-name>
  description: <what it does + trigger conditions>
  ---
  ```
- **Skill enhancement:** Specify exact sections to add/change in existing `SKILL.md`
- **Script/hook automation:** Provide exact script/hook path and starter command/body
- **Permission changes:** Specify exact permission(s) to grant and why

## Examples

### Example 1: Review Today's Sessions

**User says:** `/cc-sessions-review today`

**Actions:**
1. Use provided scope argument (skip AskUserQuestion)
2. Run `discover_sessions.sh today` to find today's session files
3. Parse each session, compute stats table rows, classify substantial/short/abandoned
4. Check codebase for CLAUDE.md, skills, docs
5. Analyze across all six categories, including friction signals
6. Generate session overview + summary + detailed breakdown (all categories)
7. Ask which recommendations to implement

**Result:** Report showing e.g., "User corrected browser rendering issues 3 times - agent lacked browser verification. Recommend granting Playwright MCP access and adding a frontend verification step."

### Example 2: Review Last 5 Sessions

**User says:** `/cc-sessions-review last-5`

**Actions:**
1. Use provided scope argument (skip AskUserQuestion)
2. Discover 5 most recent sessions
3. Parse, classify sessions, and analyze across sessions
4. Focus on patterns that repeat across sessions, not within a single one

**Result:** Report showing e.g., "Same database query pattern explained in 3 of 5 sessions. Recommend adding to CLAUDE.md: 'Always use the repository pattern for DB access, see src/repos/'"

### Example 3: Interactive Scope Selection

**User says:** `/cc-sessions-review`

**Actions:**
1. Ask project scope (current/all)
2. Ask timeframe (current/today/week/month/last-N)
3. Build `SCOPE_ARGS` and run discovery script
4. Continue with normal parse/analyze/report flow

## Additional Resources

- **`references/compound-engineering-principles.md`** - Detection algorithms, signal thresholds, recommendation types for all six categories
- **`references/session-parsing.md`** - JSONL format, jq extraction patterns, content type handling
- **`scripts/discover_sessions.sh`** - Session file discovery with scope filtering (`--all-projects` support)
