---
name: mp-handoff
description: Update STATE.md with session handoff information capturing progress, decisions, and working memory.
disable-model-invocation: true
allowed-tools: Read, Write, Edit, Glob, Grep, TaskList
---

# Update Session Handoff

Updates the "Session Handoff" section in STATE.md files (global and/or phase-level) with current session context.

## Purpose

Capture accumulated knowledge, context, and insights that would be lost when starting a new conversation. This includes progress, decisions, problems solved, dead ends, and implicit context that's hard to reconstruct.

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

### Step 3: Identify Which STATE.md to Update

1. Check if in a phased project (`.claude/phases/` exists)
2. If yes, identify the current active phase from `.claude/STATE.md`
3. Update both:
   - `.claude/STATE.md` (global) - for overall session context
   - `.claude/phases/NN-name/STATE.md` (phase) - for phase-specific work

### Step 4: Update Session Handoff Section

Append or update the "Session Handoff" section in STATE.md:

```markdown
---

## Session Handoff

### [TODAY'S DATE]
**Progress This Session:**
- [What was accomplished]

**Key Decisions:**
- [Decisions and their reasoning]

**Issues Encountered:**
- What went wrong: [Mistakes made]
- What NOT to do: [Dead ends discovered]
- What we tried: [All attempted approaches]
- How we handled it: [Solutions found]

**Next Steps:**
1. [Prioritized next actions]
2. [...]

**Critical Files:**
- [Key files with brief description]

**Working Memory:**
[Accumulated knowledge, mental models, file relationships, patterns, implicit context]
```

### Step 5: Confirm Update

Show the user what was updated:

> "Session handoff updated in:
> - `.claude/STATE.md` (global)
> - `.claude/phases/02-feature/STATE.md` (current phase)
>
> Captured:
> - [X] items of progress
> - [X] decisions
> - [X] lessons learned
> - [X] next steps
>
> Start your next session by reading STATE.md."

## Notes

- Updates existing STATE.md files, doesn't create new ones
- If no STATE.md exists, suggest running `/mp-init-project` or `/mp-parse-spec`
- Focus on "why" not just "what" - reasoning is crucial
- Capture implicit knowledge that isn't documented elsewhere
- Previous session entries are preserved (append new entry)
