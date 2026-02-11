---
name: cc-sessions-review
description: This skill should be used when the user asks to "review my sessions", "analyze my chat history", "review my Claude Code usage", "find compounding opportunities", "improve my AI workflow", "session review", or wants feedback on Claude Code session patterns. Do NOT use for code review, PR review, or general conversation analysis.
argument-hint: [scope: today|week|month|last-N]
disable-model-invocation: true
allowed-tools: Bash, Read, Glob, Grep, AskUserQuestion
model: sonnet
---

# CC Sessions Review

Analyze Claude Code session history for the current project using compound engineering principles. Identify anti-patterns, missed compounding opportunities, verification gaps, and undocumented knowledge. Produce actionable recommendations with draft content where applicable.

## Instructions

### Step 1: Discover Sessions

Run the discovery script with the user's scope argument:

```bash
bash ./skills/cc-sessions-review/scripts/discover_sessions.sh $ARGUMENTS
```

If no argument provided, default scope is `current` (most recent session).

Available scopes: `current`, `today`, `week`, `month`, `last-N` (e.g., `last-5`).

If no sessions are found, inform the user and suggest checking the project path.

### Step 2: Parse Conversations

For each discovered session file, extract the conversation using jq.

Extract user messages (skip system messages starting with `<system`):
```bash
jq -r 'select(.type == "user" and .userType == "external") | .message.content | if type == "string" then . elif type == "array" then [.[] | select(.type == "text") | .text] | join("\n") else empty end' SESSION_FILE
```

Extract assistant responses with tool usage:
```bash
jq -c 'select(.type == "assistant") | {text: [.message.content[]? | select(.type == "text") | .text] | join("\n"), tools: [.message.content[]? | select(.type == "tool_use") | .name]}' SESSION_FILE
```

CRITICAL: For large sessions (>500 lines of output), process in chunks. Read the first 200 lines, analyze, then continue. Do not attempt to load entire large sessions into context at once.

See `references/session-parsing.md` for full JSONL format details and additional extraction patterns.

### Step 3: Check Codebase Context

Before analyzing, gather project context to make recommendations specific:

- Read `CLAUDE.md` if it exists (check project root and `.claude/` directory)
- List installed skills: `ls skills/*/SKILL.md 2>/dev/null`
- List commands: `ls commands/*.md 2>/dev/null`
- Check docs structure: `ls docs/ 2>/dev/null`
- Check for hooks configuration

This context determines what already exists vs. what to recommend creating.

### Step 4: Analyze Patterns

Apply the six detection categories from `references/compound-engineering-principles.md`:

1. **Compounding patterns** - Repeated problems, unextracted patterns, missed reuse, no automation
2. **Verification gaps** - User caught issues agent could have detected
3. **Documentation gaps** - Undocumented patterns, procedures, best practices
4. **Delegatable work** - Manual tasks suitable for agent delegation
5. **Stage progression** - Only flag when clear opportunities exist
6. **Planning/work balance** - Only flag significant imbalances

For each finding, record:
- Category
- Evidence (specific quotes or turn references from the session)
- Impact (high/medium/low)
- Concrete recommendation

### Step 5: Generate Report

Present findings in two parts:

**Summary (always show):**
```
## Session Review: [scope]
Sessions analyzed: N | Turns: N user, N assistant

### Top Recommendations
1. [Highest impact finding + action]
2. [Second highest]
3. [Third highest]
```

**Detailed Breakdown (show after summary):**

For each category with findings:
- Category heading with count
- Each finding with evidence quotes from the session
- Specific recommendation
- For documentation gaps: include draft content for simple cases

For categories with no findings, state "No issues detected" briefly.

CRITICAL: Keep evidence quotes short (1-2 sentences). Do not reproduce entire conversation turns.

### Step 6: Offer Implementation Plan

After presenting the report, use AskUserQuestion to ask which recommendations to implement:

```
Which recommendations should I create an implementation plan for?
Options:
1. [Recommendation 1 summary]
2. [Recommendation 2 summary]
3. [Recommendation 3 summary]
4. All recommendations
```

For selected recommendations, generate a concrete plan:
- **CLAUDE.md additions:** Show exact text to add, ask for approval
- **Skill creation:** Outline skill structure, name, trigger phrases
- **Script/hook creation:** Describe what it does, where it goes
- **Permission changes:** Specify exact permissions to grant

## Examples

### Example 1: Review Today's Sessions

**User says:** `/cc-sessions-review today`

**Actions:**
1. Run `discover_sessions.sh today` to find today's session files
2. Parse each session for user and assistant turns
3. Check codebase for CLAUDE.md, skills, docs
4. Analyze across all six categories
5. Generate summary with top 3 recommendations
6. Show detailed breakdown
7. Ask which recommendations to implement

**Result:** Report showing e.g., "User corrected browser rendering issues 3 times - agent lacked browser verification. Recommend granting Playwright MCP access and adding a frontend verification step."

### Example 2: Review Last 5 Sessions

**User says:** `/cc-sessions-review last-5`

**Actions:**
1. Discover 5 most recent sessions
2. Parse and analyze across sessions (cross-session patterns are more valuable)
3. Focus on patterns that repeat across sessions, not within a single one

**Result:** Report showing e.g., "Same database query pattern explained in 3 of 5 sessions. Recommend adding to CLAUDE.md: 'Always use the repository pattern for DB access, see src/repos/'"

## Additional Resources

- **`references/compound-engineering-principles.md`** - Detection algorithms, signal thresholds, recommendation types for all six categories
- **`references/session-parsing.md`** - JSONL format, jq extraction patterns, content type handling
- **`scripts/discover_sessions.sh`** - Session file discovery with scope filtering
