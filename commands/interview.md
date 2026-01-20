---
description: Interview user about any topic to understand their thinking
argument-hint: [topic] [minutes]
allowed-tools: AskUserQuestion, Bash
model: sonnet
---

Interview me in-depth about "$1" using the AskUserQuestionTool. Ask deep, non-obvious questions to understand my thinking, perspectives, concerns, and considerations. Continue interviewing until you have a comprehensive understanding (or the time runs out, see below), then write a detailed summary in markdown format.

If $2 is provided (number of minutes), start a background timer using `sleep ${2}m && echo "⏰ Time's up!"`
After each answer, check the timer to make best use of the time constraint.
