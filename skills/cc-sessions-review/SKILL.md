---
name: cc-sessions-review
description: This skill should be used when the user asks to "review my sessions", "analyze my chat history", "review my Claude Code usage", "find compounding opportunities", "improve my AI workflow", "session review", or wants feedback on Claude Code session patterns. Do NOT use for code review, PR review, or general conversation analysis.
argument-hint: "[scope: current|today|week|month|last-N] [--all-projects]"
disable-model-invocation: true
allowed-tools: Bash, Read, Glob, Grep, AskUserQuestion
model: sonnet
run-as-subagent: true
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

Analysis time scales with session count and session size.
For `week`/`month`/`--all-projects`, prioritize substantial sessions first, then summarize short sessions.
If scope is large, state the estimated review depth before continuing.

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

Compute per-session stats (ID, date, size, turns, tool calls, tools used) using the commands in:
- `references/session-parsing.md` → **Per-Session Stats**

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

CRITICAL: For large sessions, use this 3-step chunk workflow and synthesize at the end:
1. Check size:
```bash
LINES="$(wc -l < "$SESSION_FILE" | tr -d ' ')"
echo "Total lines: $LINES"
```
2. Chunk with offset windows:
```bash
CHUNK=200
OFFSET=0
while [ "$OFFSET" -lt "$LINES" ]; do
  tail -n +"$((OFFSET + 1))" "$SESSION_FILE" | head -n "$CHUNK" > "/tmp/session-${SESSION_ID}-${OFFSET}.jsonl"
  # analyze each chunk independently before moving on
  OFFSET=$((OFFSET + CHUNK))
done
```
3. Synthesize:
- Merge chunk-level findings into one per-session summary.
- De-duplicate repeated issues across chunks before scoring/recommending.

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

| Session ID | Date | User turns | Assistant turns | Tools used | Size | Class | Quality (1-10) |
|---|---|---:|---:|---|---:|---|---:|
| ... | ... | ... | ... | ... | ...KB | Substantial | 7.8 |
```

Quality score formula (per session, clamp to 1-10):
```text
quality = clamp(1, 10,
  5.0
  - 0.6 * correction_count
  - 1.2 * topic_loop_count
  - 1.0 * abandoned_count
  - 0.8 * undo_revert_count
  + 0.9 * compound_actions
  + 0.5 * documented_patterns
  - 2.0 * abs(planning_ratio - 0.80)
)
```
Where:
- `compound_actions` = number of compounding outputs in session (new/updated skill, automation script/hook, durable docs update such as CLAUDE.md).
- `documented_patterns` = repeated conventions/procedures captured into durable docs during or from the session.
- `planning_ratio` = `planning_turns / (planning_turns + work_turns + review_turns + compound_turns)` (use `0` if denominator is `0`).

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

## Sample Output

```markdown
## Session Overview
Sessions analyzed: 4 (Substantial: 2 | Short: 1 | Abandoned: 1)

| Session ID | Date | User turns | Assistant turns | Tools used | Size | Class | Quality (1-10) |
|---|---|---:|---:|---|---:|---|---:|
| 84a7e050... | 2026-02-11 14:20 | 18 | 21 | Read,Bash,Edit | 96KB | Substantial | 6.4 |
| c51b1fd2... | 2026-02-11 09:07 | 7 | 8 | Read,Bash | 33KB | Substantial | 8.1 |
| 19dd30c0... | 2026-02-10 17:44 | 3 | 3 | Read | 11KB | Short | 7.9 |
| 33ae8b2e... | 2026-02-10 11:06 | 5 | 4 | Read,Bash | 20KB | Abandoned | 4.8 |

## Session Review: week
Sessions analyzed: 4 | Turns: 33 user, 36 assistant

### Top Recommendations
1. Add frontend verification workflow (Playwright screenshot + console check) before marking UI tasks complete.
2. Capture repeated repository-pattern guidance in CLAUDE.md under "Database Access".
3. Create a `release-checklist` skill to standardize pre-release checks.

## Detailed Breakdown

### 1. Compounding Patterns (2 findings)
- Metrics: repeated DB pattern explanation in 3 sessions; same release checks run manually in 2 sessions.
- Evidence: "Use repository pattern for DB access" repeated across 3 session IDs.
- Recommendation: document DB rule in CLAUDE.md; automate release checks in a skill.

### 2. Verification Gaps (1 critical finding)
- Metrics: correction_count=4, topic_loops=1, abandoned=1, undo/revert=1.
- Evidence: user reported browser regression after implementation with no browser validation step.
- Recommendation: add verification gate with Playwright MCP and test command checklist.

### Friction Points
- Corrections: 4 (high), Loops: 1 (moderate), Abandoned: 1 (moderate), Undo/Revert: 1 (moderate).
- Why it matters: repeated rework suggests missing upfront verification and weak acceptance checks.

### 3. Documentation Gaps (1 finding)
- Metrics: 2 conventions repeated, 0 captured in docs.
- Evidence: naming and DB guidance repeated without durable documentation.
- Recommendation: add CLAUDE.md section with exact conventions.

### 4. Delegatable Work (1 finding)
- Metrics: manual log parsing done in 2 sessions by user copy/paste.
- Evidence: user pasted repeated command output instead of delegating.
- Recommendation: have agent run parsing commands directly and summarize.

### 5. Stage Progression
- Inferred stage: Stage 2 (agentic tools + close supervision).
- Evidence: direct implementation requests=9, review turns=3, planning turns=4, compound turns=2.
- Next-stage indicator: enough repeated flow to pilot a plan-first workflow in similar tasks.

### 6. Planning/Work Balance
- Turn ratios: Planning 11%, Work 63%, Review 18%, Compound 8%.
- Assessment: imbalanced toward direct work relative to 80/20 guidance.
- Recommendation: add a short planning phase and explicit verification checklist before implementation.
```

## Additional Resources

- **`references/compound-engineering-principles.md`** - Detection algorithms, signal thresholds, recommendation types for all six categories
- **`references/session-parsing.md`** - JSONL format, jq extraction patterns, content type handling
- **`scripts/discover_sessions.sh`** - Session file discovery with scope filtering (`--all-projects` support)
