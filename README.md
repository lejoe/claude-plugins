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

### CC Sessions Review

Analyze Claude Code session history using compound engineering principles to find workflow improvement opportunities.

**Usage:**

```
/cc-sessions-review [scope: today|week|month|last-N]
```

**Use when you need to:**

- Review past sessions for repeated problems or missed automation opportunities
- Find verification gaps where the agent missed issues the user caught
- Identify undocumented patterns, procedures, or preferences
- Detect manual work that could be delegated to the agent
- Get actionable recommendations with draft CLAUDE.md additions or skill proposals

### Twitter Thread Extractor

Extract and format Twitter threads for easy reading and analysis.

**Use when you need to:**

- Extract content from Twitter threads
- Convert threads to readable markdown format
- Analyze or save Twitter thread content

## Commands

### Spec Interview

Interactive specification writing tool that interviews you about feature requirements and writes detailed specifications.

_Inspired by [Thariq's spec-based workflow](https://x.com/trq212/status/2005315275026260309)._

**Usage:**

```
/spec-interview [spec-file]
```

If no file is specified, defaults to `SPEC.md`.

**Use when you need to:**

- Create detailed feature specifications through guided interviews
- Explore technical implementation details, UI/UX considerations, and trade-offs
- Convert rough ideas into comprehensive specification documents
- Document requirements through structured questioning

### Interview

Interactive interviewing tool that asks deep, non-obvious questions to understand your thinking about any topic.

**Usage:**

```
/interview [topic] [minutes]
```

- `topic` - The subject to interview you about
- `minutes` - Optional time limit for the interview

**Use when you need to:**

- Explore your thinking on a complex topic through guided questioning
- Uncover perspectives, concerns, and considerations through deep questions
- Get a comprehensive summary of your thoughts after the interview
- Work within a time constraint using the optional timer

### Kind Feedback

Draft supportive, constructive PR comments using Conventional Comments format and research-backed tone guidelines.

**Usage:**

```
/kind-feedback [your feedback/concern]
```

**Use when you need to:**

- Transform raw feedback into supportive PR comments
- Frame suggestions as questions rather than commands
- Apply proper labels (suggestion, issue, nitpick, etc.)
- Get multiple tone variations to choose from

## Agents

Agents are autonomous subprocesses that Claude automatically triggers when it detects appropriate scenarios. They handle complex, multi-step tasks independently.

### Thinking Partner

Autonomous agent for collaborative exploration of complex problems through Socratic questioning and active listening.

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
