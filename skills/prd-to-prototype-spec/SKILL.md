---
name: prd-to-prototype-spec
description: Turn a PRD (the why and what) into a UX spec (the how) for the prototype phase, by interviewing the user on the non-obvious decisions. Use when the user shares a PRD and wants a spec, wants to clarify the how, or is preparing prototypes.
---

# PRD to prototype spec

The PRD defines the **why** and the **what**. You produce the **how**: a UX spec, written as a second tab in the PRD doc.

The spec feeds prototypes that do two jobs:
- **explore** design directions
- **validate** UX points

After the prototype phase, the spec, the prototype decisions and the chosen directions (design links) drive implementation. Write the spec so those can be added to it later.

Stay at the UX level. Raise a technical point only when it constrains the UX or the scope.

## 1. Read the PRD

Read the whole PRD and any context it links to. Build a list of open questions: every UX decision the PRD leaves unstated, ambiguous or contradictory. Skip what the PRD already answers.

Done when every user-facing flow in the PRD has been checked for open questions.

## 2. Interview

Ask one question at a time, upstream decisions first. Give your recommended answer with each question so the user can confirm or correct it. Use `AskUserQuestion` when the options are distinct.

Sort each answer into one of three buckets:
- **Decided**: goes into the spec as is.
- **Explore**: several valid directions; a prototype should compare them.
- **Validate**: a UX assumption a prototype should test with users.

Done when every open question sits in a bucket, or the user stops the interview.

## 3. Write the spec tab

Add a second tab to the PRD doc. If the doc tool can't add tabs, ask where to put it.

Structure:
- **Users and key flows**: step by step, from the user's point of view.
- **Screens and states**: per screen, what it shows and does, including empty, error and loading states that matter.
- **Decided**: the decisions from the interview.
- **To explore**: each direction to prototype, with what would make one win.
- **To validate**: each assumption, with what result would confirm or reject it.
- **Prototype decisions and design links**: empty, filled after the prototype phase.

Done when every Explore and Validate item can be turned into a prototype without asking the user again.
