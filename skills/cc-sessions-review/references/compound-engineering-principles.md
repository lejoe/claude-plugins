# Compound Engineering Detection Principles

Source: [Compound Engineering Guide](https://every.to/guides/compound-engineering)

Core principle: every unit of engineering work should make subsequent units easier.

## 1. Compounding Patterns

Detect work that does NOT compound into future productivity.

### What to Look For

**Repeated problem-solving:**
- Same error/problem appears across multiple sessions
- User explains the same concept/preference to the agent repeatedly
- Similar debugging sequences occur in different sessions
- Same questions asked about codebase structure or conventions

**Patterns not extracted to systems:**
- Coding preferences stated in conversation but absent from CLAUDE.md
- Architectural decisions discussed but not documented
- Naming conventions explained verbally, not codified
- Workflow steps described manually each time

**Missed reuse:**
- Agent writes similar code/scripts in multiple sessions
- User provides same context/background repeatedly
- Same file modifications done across sessions
- Similar prompts issued for recurring tasks

**Missing automation:**
- Repetitive manual commands (same bash sequences)
- Multi-step processes done step-by-step each time
- Recurring checks/validations performed manually
- Regular reporting or status-gathering done by hand

### Signal Threshold
- 2+ occurrences in different sessions: potential pattern
- 3+ occurrences: strong signal, recommend action

### Recommendation Types
- **Patterns** → Add to CLAUDE.md (preferences, conventions, constraints)
- **Procedures** → Create a skill (repeatable multi-step workflows)
- **Automation** → Create a script or hook (deterministic, repetitive tasks)

## 2. Verification Gaps

Detect instances where the user caught issues the agent could have detected.

### What to Look For

**User correction signals:**
- "actually", "no that's wrong", "that broke", "doesn't work"
- "I see [issue] in the browser/terminal/output"
- "tests are failing", "build is broken"
- "the API returns [unexpected result]"
- User providing screenshots or error output the agent didn't check

**Gap classification:**

| Type | Signal | Example |
|---|---|---|
| Missing tool access | Agent couldn't check | "I see this is broken in the browser" (no browser tool) |
| Missing verification step | Agent didn't check | "Tests fail" after agent wrote code without running tests |
| Missing workflow | No systematic check | Same type of issue caught by user repeatedly |

### Friction Signals (Track Under Verification Gaps)

Detect friction even when there is no single explicit bug report.

**Correction keyword signals:**
- "no", "that's wrong", "actually", "doesn't work", "broke", "regression"
- Count only user turns, not assistant text

**Loop signals:**
- 5+ turns on the same unresolved topic/issue
- Repeated "try/fix/retry" cycle without forward progress

**Abandonment signals:**
- Session ends with unresolved user request
- User says "never mind", "skip this", "forget it", "let's stop"

**Undo/revert signals:**
- "undo", "revert", "roll back", "start over"
- User asks to discard prior changes due to low confidence

### Friction Thresholds

- Correction keywords:
  - `>=2` in one session: moderate friction
  - `>=4`: high friction
- Topic loops:
  - `>=1` loop of 5+ turns: moderate friction
  - `>=2` loops: high friction
- Abandoned threads:
  - `>=1`: moderate friction
  - `>=2`: high friction
- Undo/revert patterns:
  - `>=1`: moderate friction
  - `>=2`: high friction

### Recommendation Types
- **Immediate:** Suggest granting permissions/tools for the missing capability
- **Systematic:** If same gap appears 2+ times, suggest creating a verification workflow or hook
  - Example: "Create a PreToolUse hook that runs tests before committing"
  - Example: "Add browser screenshot verification to frontend skill"

## 3. Documentation Gaps

Detect knowledge that should be documented but isn't.

### What to Look For

**CLAUDE.md candidates (patterns):**
- User states a preference: "always use X instead of Y"
- User corrects agent style: "use camelCase not snake_case"
- User explains project conventions 2+ times
- Architectural decisions: "we use X pattern because..."

**Skill candidates (procedures):**
- User walks through a multi-step process manually
- Recurring workflow: deploy, release, review, setup
- Task requiring specific ordering or checks

**Docs candidates (best practices):**
- Team-specific knowledge shared in conversation
- External API behaviors or gotchas explained
- Environment setup or configuration details

### Draft Generation Rules
- **Simple (generate draft):** Single-line preferences, naming rules, tool choices
- **Complex (point to gap):** Architectural decisions, multi-faceted workflows, things needing team input

### Draft Format
```markdown
## Proposed CLAUDE.md Addition

### [Category]
- [preference/convention/constraint as stated by user]
```

## 4. Delegatable Work

Detect manual work the user does that could be delegated to the agent.

### What to Look For

**User doing agent-suitable work:**
- "I'll do X manually" / "Let me handle X"
- User running commands and pasting output
- User editing files and describing changes
- "how do I..." questions about tooling

**Copy-paste workflows:**
- User copying output from one tool to another
- Manual data transformation between formats
- Repeated context-switching between tools

**Repetitive tasks:**
- Same command sequences in multiple sessions
- Regular maintenance tasks done by hand
- Routine checks or status gathering

### Recommendation Format
- Describe what the user did manually
- Explain how the agent could handle it
- Suggest specific permissions/tools needed if applicable

## 5. Stage Progression

Always report stage indicators with evidence. Suggest progression only when the next step is clear and actionable.

### Compound Engineering Stages
- **Stage 0:** Manual development without AI
- **Stage 1:** Chat-based assistance (copy-paste)
- **Stage 2:** Agentic tools with line-by-line review
- **Stage 3:** Plan-first, PR-only review (compound engineering begins)
- **Stage 4:** Idea-to-PR automation
- **Stage 5:** Parallel cloud execution with multiple agents

### Reporting Rules
- Always show inferred current stage
- Always include evidence counts (e.g., planning turns, direct implementation turns, review turns)
- Suggest advancing only when 5+ instances of current-stage behavior are visible and the next step is concrete
- Frame as opportunity, not criticism

### Example Suggestions
- Stage 1→2: "Consider letting the agent edit files directly instead of copy-pasting suggestions"
- Stage 2→3: "Start with a plan phase before implementation. Use EnterPlanMode or a planning skill"
- Stage 3→4: "Automate the plan→work→review cycle with a workflow skill"

## 6. Planning/Work Balance

The compound engineering guide recommends spending 80% on planning+review, 20% on work+compound.

### Reporting Rules
- Always report planning/work/review/compound turn counts and ratios
- Flag only significant imbalances. This is guidance, not a strict rule.

### How to Estimate
- **Planning turns:** Questions, design discussions, requirement exploration, architecture talk
- **Work turns:** Implementation requests, "do X", "fix Y", "add Z"
- **Review turns:** "Check this", "does this look right", reviewing output
- **Compound turns:** Documentation, creating skills, updating configs

### Imbalance Signals
- >80% work turns with <10% planning: suggest more upfront planning
- Many corrections/reverts: indicates insufficient planning
- Sessions that jump straight to implementation without context gathering

### Recommendation
Frame as: "Consider spending more time on [phase] - sessions with more [planning/review] tend to produce fewer corrections and rework."
