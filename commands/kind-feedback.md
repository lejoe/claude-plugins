---
description: Draft supportive, constructive feedback using kind tone and Conventional Comments
argument-hint: [your feedback/concern]
allowed-tools: AskUserQuestion
model: sonnet
---

Help me draft a PR comment from this raw feedback: "$ARGUMENTS"

If no argument provided, ask what feedback I want to give.

Then ask (using AskUserQuestion):
1. Type? (suggestion / question / nitpick / issue / praise / thought)
2. Blocking? (yes / no)

## Best Practices

### Labels (Conventional Comments)

| Label | Use for | Blocking |
|-------|---------|----------|
| praise | Something done well | No |
| nitpick | Minor style/preference | No |
| suggestion | Improvement idea | Usually no |
| issue | Actual problem | Yes |
| question | Need clarification | No |
| thought | Non-blocking idea | No |

Format: `label (non-blocking):` or `label (blocking):`

### Tone Rules

**Focus on code, not person**
- Bad: "You didn't close the connection"
- Good: "The connection isn't closed here"

**Questions > commands**
- Bad: "Change this to X"
- Good: "What do you think about X?"

**Explain the why** - never assume they know your reasoning

**Avoid belittling words**: just, simply, obviously, clearly

**Use softeners**:
- "What do you think about..."
- "Have you considered..."
- "I wonder if..."
- "One option might be..."

### Structure

- One point per comment
- Lead with label
- 1-3 sentences max
- Brief reasoning included

## Output

Draft 2-3 variations:
1. **Concise** - Label + one sentence
2. **With context** - Label + reasoning
3. **Softest** - Questions throughout, maximum warmth

Present options. Let me pick or adjust.
