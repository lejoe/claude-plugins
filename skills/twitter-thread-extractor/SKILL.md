---
name: twitter-thread-extractor
description: This skill should be used when the user asks to "extract this Twitter thread", "save this Twitter thread", "export Twitter thread to markdown", "archive this thread", "download this thread", or provides a Twitter/X URL requesting thread extraction, export, or archival into markdown format.
---

# Twitter Thread Extractor

Expert workflow for extracting Twitter/X threads into clean, well-formatted markdown files using browser automation.

## Prerequisites

This skill requires the **Playwright MCP server** for browser automation.

### Verify MCP Availability

Before starting extraction, verify Playwright MCP is available:

1. Check if `mcp__playwright__browser_navigate` tool exists
2. If not available, inform user gracefully:
   > "This skill requires the Playwright MCP server for browser automation. Please ensure the Playwright MCP is configured and running, then try again."
3. Do NOT proceed with extraction if MCP is unavailable

## Overview

Extract complete Twitter threads with all content (including truncated tweets) and save them as structured markdown files. This skill handles the complete workflow from opening the browser to generating the final markdown document.

## Core Workflow

### Step 1: Initialize and Navigate

1. Create a todo list to track the extraction process:

   - Open browser and navigate to the tweet URL
   - Wait for user to log in (if needed)
   - Extract and expand all tweets in thread
   - Save all content to .md file

2. Open the browser and navigate to the provided Twitter/X URL using `mcp__playwright__browser_navigate`

3. Take a snapshot using `mcp__playwright__browser_snapshot` to verify the page loaded

### Step 2: User Login Check

Check the page snapshot for login status:

- If the user is already logged in (profile visible), proceed immediately
- If login is required, inform the user and wait for login completion
- Update the todo list to mark the login step as completed once verified

### Step 3: Extract Thread Content

1. Identify all tweets in the thread from the page snapshot

   - Look for article elements containing tweet content
   - Note which tweets have "Show more" buttons (truncated content)

2. Create the initial markdown file with:

   - Thread title/topic
   - Author information (@username)
   - Date
   - Source URL
   - Introduction section

3. Systematically expand ALL truncated tweets:

   - For each tweet with a "Show more" button, click it using `mcp__playwright__browser_click`
   - Use the element reference from the snapshot
   - After each click, verify that the content expanded
   - Extract the full content after expansion

4. Identify and note any attached media:

   - Check for images, videos, or embedded content in each tweet
   - Note the presence and type of media (e.g., "Image", "Video", "Embedded video")
   - Extract the media URL if available from link elements
   - Do NOT attempt to download or extract the actual media files

5. Continue scrolling/clicking through the thread until all tweets are captured

### Step 4: Format and Save

1. Structure the markdown file with proper header and metadata:

   - Add thread title as H1
   - Include author name and @username
   - Add date and source URL
   - Separate metadata from content with `---`

2. Extract thread content sequentially:

   - Extract each tweet in the order it appears in the thread
   - Preserve all formatting (bold, italics, code blocks, lists)
   - Keep emoji characters intact
   - Note attached media inline with the tweet content (see "Media Handling")
   - Separate tweets with `---` for readability
   - Do NOT reorganize or create artificial sections

3. Save the complete content to a markdown file with a descriptive filename

4. Update the todo list to mark extraction as completed

5. Close the browser using `mcp__playwright__browser_close`

## Formatting Guidelines

### Content Preservation

- Preserve all original formatting (bold, italics, code blocks)
- Keep emoji characters intact
- Maintain line breaks and paragraph structure
- Include all links, mentions, and hashtags

### Tweet Organization

- Extract tweets in sequential order as they appear
- Separate each tweet with `---` (horizontal rule)
- Preserve the original text formatting
- Use code blocks (```) only if present in the original tweet
- Do NOT add headings or section titles that weren't in the original thread

### File Naming

- Use descriptive, readable names
- Replace spaces with underscores or hyphens
- Keep it concise but informative
- Example: `twitter_thread_prompting_techniques.md`

### Media Handling

When a tweet contains attached media:

- Note the media type inline: `[Image]`, `[Video]`, or `[Embedded video]`
- If the media has a direct URL, include it as a markdown link: `[Image](URL)`
- Place media notes after the tweet text content
- For multiple images, note each one: `[Image 1](URL)`, `[Image 2](URL)`
- Example:

  ```markdown
  This is the tweet text explaining the concept.

  [Image](https://x.com/username/status/123456/photo/1)
  ```

## Best Practices

1. **Always expand truncated content**: Never save partial tweets - click all "Show more" buttons

2. **Verify completeness**: Check that the thread has no more tweets after the last one captured

3. **Maintain structure**: Preserve the logical flow and organization of the original thread

4. **Clean formatting**: Remove Twitter UI artifacts, focus on pure content

5. **Todo tracking**: Update the todo list after completing each major step to show progress

6. **Handle errors gracefully**: If a tweet fails to expand, note it and try again

## Output Format

The extracted thread should follow this structure:

```markdown
# [Thread Title/Topic]

**Author:** [Name] (@username)
**Date:** [Date]
**Source:** [URL]

---

[Tweet 1 text content]

[Media if present]

---

[Tweet 2 text content]

[Media if present]

---

[Tweet 3 text content]

...
```

Each tweet is extracted verbatim with its media noted, separated by horizontal rules for readability.
