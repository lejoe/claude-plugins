# Session Parsing Reference

## Storage Location

Claude Code stores session data at:
```
~/.claude/projects/<normalized-path>/<session-id>.jsonl
```

Path normalization: replace all `/` with `-`.
Example: `/Users/lejoe/my-project` → `-Users-lejoe-my-project`

Session files use UUID naming (e.g., `84a7e050-4ff6-4264-865b-baf9d561bba3.jsonl`).
Files prefixed with `agent-` are sub-agent sessions and should be excluded.

## JSONL Structure

Each line is a JSON object. Key fields:

| Field | Description |
|---|---|
| `type` | Message type: `user`, `assistant`, `queue-operation`, `progress` |
| `userType` | `external` for real user input |
| `message.content` | String (plain text) or array (structured content) |
| `timestamp` | ISO timestamp |
| `sessionId` | Session UUID |

### Content Types

**String content** (user typed text directly):
```json
{"type": "user", "userType": "external", "message": {"content": "Fix the login bug"}}
```

**Array content** (tool results, multi-part messages):
```json
{"type": "user", "userType": "external", "message": {"content": [
  {"type": "text", "text": "That looks wrong in the browser"},
  {"type": "tool_result", "tool_use_id": "...", "content": "..."}
]}}
```

**Assistant content** (always array):
```json
{"type": "assistant", "message": {"content": [
  {"type": "thinking", "thinking": "..."},
  {"type": "text", "text": "Let me fix that..."},
  {"type": "tool_use", "name": "Edit", "input": {...}}
]}}
```

## Extraction Patterns

### Extract user text messages
```bash
jq -r '
  select(.type == "user" and .userType == "external") |
  .message.content |
  if type == "string" then .
  elif type == "array" then
    [.[] | select(.type == "text") | .text] | join("\n")
  else empty end
' session.jsonl
```

### Extract assistant text responses
```bash
jq -r '
  select(.type == "assistant") |
  .message.content |
  if type == "array" then
    [.[] | select(.type == "text") | .text] | join("\n")
  else empty end
' session.jsonl
```

### Extract assistant tool usage
```bash
jq -c '
  select(.type == "assistant") |
  .message.content |
  if type == "array" then
    [.[] | select(.type == "tool_use") | {name, input: .input | keys}]
  else empty end |
  select(length > 0)
' session.jsonl
```

### Build conversation turn pairs
```bash
jq -c '
  select(.type == "user" or .type == "assistant") |
  {
    type,
    timestamp,
    text: (
      .message.content |
      if type == "string" then .
      elif type == "array" then
        [.[] | select(.type == "text") | .text] | join("\n")
      else "" end
    ),
    tools: (
      if .type == "assistant" then
        [.message.content[]? | select(.type == "tool_use") | .name]
      else [] end
    )
  }
' session.jsonl
```

## Filtering System Messages

Some user messages contain system injections (system-reminder tags, system_instruction, hook outputs). These appear as:
- First message in session (system prompt context)
- Messages starting with `<system-reminder>` or `<system_instruction>`
- Messages containing `[Request interrupted by user]`

Filter these by checking content does not start with `<system` and is not an interruption marker.

## Per-Session Stats

Use this block in Step 2 to compute the session overview metrics for a single file:

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

Recommended defaults:
- If `TOOLS_USED` is empty, render as `none`.
- Keep `SIZE_BYTES` for classification logic and display `SIZE_KB` in tables.
