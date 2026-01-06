# Claude Skills Collection

A personal collection of Claude Code skills and autonomous agents for enhanced AI-assisted workflows.

## What's Included

This plugin provides both **skills** (user-invoked commands) and **agents** (autonomously triggered for complex tasks).

## Skills

### Brainstorm

Collaborative thinking partner for exploring complex problems through Socratic questioning and active listening.

**Use when you need to:**

- Brainstorm solutions to complex problems
- Explore ideas and organize your thoughts
- Work through challenges using structured dialogue
- Get help thinking through decisions or trade-offs

### Deep Research Prompt Builder

Interactive prompt builder for creating high-quality deep research prompts through adaptive interviewing.

**Use when you need to:**

- Transform a basic research topic into a comprehensive research prompt
- Enhance existing questions with best practices
- Create structured prompts for product comparisons, technical docs, academic research, or market analysis

**Automatically triggered when:**

- You're working through complex problems or decisions
- You ask for brainstorming or thinking assistance
- You need help exploring different perspectives
- You want to organize thoughts around a challenging topic

**Example triggers:**

- "I'm trying to figure out the best approach to restructure our API"
- "Help me brainstorm ideas for improving team communication"
- "I'm stuck between two architecture patterns and need to think through the pros and cons"

## Installation

### Option 1: GitHub Marketplace (Recommended)

In Claude Code, run:

```
/plugin marketplace add lejoe/claude-plugins
/plugin install lejoe-agent-skills@lejoe/claude-plugins
```

### Option 2: Local Installation

Clone this repository and add it as a local marketplace:

```bash
git clone https://github.com/lejoe/claude-plugins.git
```

In Claude Code:

```
/plugin marketplace add /path/to/claude-plugins
/plugin install lejoe-agent-skills@lejoe-claude-plugins
```

### Option 3: Copy to Personal Skills

Copy skills directly to your Claude Code skills directory:

```bash
cp -r skills/deep-research-prompt-builder ~/.claude/skills/
```

## Usage

Once installed, Claude Code will automatically discover and use these skills based on context. For example:

- Ask Claude to help you "build a research prompt about X"
- Request to "create a deep research query for comparing Y"
- Say "help me structure a research question about Z"

## Author

**Joel Bez**  
[lejoe.com](https://lejoe.com) · [GitHub](https://github.com/lejoe)
