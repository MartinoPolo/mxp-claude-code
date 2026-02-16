---
name: mpx-handoff
description: Create ephemeral HANDOFF.md capturing session progress, decisions, and working memory for the next session.
disable-model-invocation: true
allowed-tools: Read, Write, Edit, Glob, Grep, TaskList
metadata:
  author: MartinoPolo
  version: "0.1"
  category: project-management
---

# Session Handoff

Creates ephemeral phase-level `HANDOFF.md` that bridges between sessions. Also persists decisions to CHECKLIST.md and ROADMAP.md.

## Purpose

Capture accumulated knowledge, context, and insights that would be lost when starting a new conversation. HANDOFF.md is ephemeral — created here, consumed and deleted by `/mpx-execute` at the start of the next session.

## Workflow

### Step 1: Gather Context

Review the current conversation to extract:
- What was accomplished (progress)
- Decisions made and their reasoning
- Problems encountered and how they were solved
- Dead ends discovered (what NOT to do)
- Files modified or discovered
- Patterns and relationships identified

### Step 2: Check Task List

Use `TaskList` to see current task status:
- Completed tasks
- In-progress tasks
- Pending tasks

### Step 3: Identify Active Phase

1. Check if in a phased project (`.mpx/phases/` exists)
2. If yes, identify the current active phase from `.mpx/ROADMAP.md`
3. Read the active phase's `CHECKLIST.md` for current state

### Step 4: Create or Update HANDOFF.md

1. Check if `HANDOFF.md` already exists in the active phase folder
2. If exists: read it, merge previous context with current session context (preserve still-relevant items, update/replace stale ones)
3. If not: create new from scratch

Write **ephemeral** `HANDOFF.md` in the active phase folder only (`.mpx/phases/NN-name/HANDOFF.md`):

```markdown
# Session Handoff

Date: [Today's date]

## Progress This Session
- [What was accomplished]

## Key Decisions
- [Decisions and reasoning]

## Issues Encountered
- What went wrong: [Mistakes made]
- What NOT to do: [Dead ends discovered]
- What we tried: [All attempted approaches]
- How we handled it: [Solutions found]

## Next Steps
1. [Prioritized next actions]

## Critical Files
- [Key files with brief description]

## Working Memory
[Accumulated knowledge, mental models, file relationships, patterns, implicit context]
```

### Step 5: Persist Decisions

If decisions were made during this session:

1. Update `## Decisions` in the active phase's `CHECKLIST.md` (phase-specific decisions)
2. Update `## Decisions` in `.mpx/ROADMAP.md` (project-level decisions)

Decisions are persistent (unlike HANDOFF.md which is ephemeral).

Format:
```markdown
## Decisions
- [Date]: [Decision description] — [reasoning]
```

### Step 6: Confirm

Show the user what was created:

> "Session handoff created:
> - `.mpx/phases/02-feature/HANDOFF.md` (phase-level, ephemeral)
> - Updated Decisions in `.mpx/phases/02-feature/CHECKLIST.md`
> - Updated Decisions in `.mpx/ROADMAP.md` (project-level)
>
> Captured:
> - [X] items of progress
> - [X] decisions (persisted to CHECKLIST.md + ROADMAP.md)
> - [X] lessons learned
> - [X] next steps
>
> HANDOFF.md will be consumed automatically by `/mpx-execute` in your next session."

## HANDOFF.md Lifecycle

1. `/mpx-handoff` **creates** HANDOFF.md (phase folder only)
2. `/mpx-execute` **reads** HANDOFF.md at start, passes context to executor
3. `/mpx-execute` **deletes** HANDOFF.md after processing
4. Purpose: bridge between sessions only — not a permanent record

## Notes

- HANDOFF.md is ephemeral — it exists only between sessions
- Decisions are also persisted to CHECKLIST.md (permanent record)
- If no `.mpx/phases/` exists, skip HANDOFF.md creation (no phase folder to write to)
- Focus on "why" not just "what" — reasoning is crucial
- Capture implicit knowledge that isn't documented elsewhere
- If HANDOFF.md already exists, it is read and merged with current session context (update-or-create)
