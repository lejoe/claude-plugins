# Claude Skills Collection

A personal collection of Claude Code skills for enhanced AI-assisted workflows.

## Skills Included

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

