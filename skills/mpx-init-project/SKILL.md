---
name: mpx-init-project
description: Initialize a new Claude Code project. Sets up git, creates spec interactively, generates checklists.
disable-model-invocation: true
allowed-tools: Read, Write, Bash, Skill, AskUserQuestion
---

# Initialize Project

All-in-one orchestrator for setting up a new Claude Code project with specification, git repository, and implementation checklists.

## Workflow Overview

```
┌───────────────────┐
│ /mpx-init-project │
└────────┬──────────┘
         │
         ▼
┌───────────────────┐
│  /mpx-create-spec  │ ◄── Interactive tech stack Q&A
└────────┬──────────┘
         │
         ▼
┌───────────────────┐
│   Confirm git     │ ◄── Ask user before init
└────────┬──────────┘
         │
         ▼
┌───────────────────┐
│   /mpx-init-repo   │ ◄── Deterministic script
└────────┬──────────┘
         │
         ▼
┌───────────────────┐
│   /mpx-parse-spec  │ ◄── Creates phased plan
└────────┬──────────┘
         │
         ▼
┌───────────────────┐
│    Summary        │
└───────────────────┘
```

## Instructions

### Step 1: Check Current State

First, check what already exists:
- Does `.git/` exist? (git already initialized)
- Does `.mpx/SPEC.md` exist? (spec already created)
- Does `.mpx/ROADMAP.md` exist? (already parsed)

If any exist, inform the user and ask how to proceed:
- Skip that step
- Overwrite existing files
- Abort

### Step 2: Create Specification

If SPEC.md doesn't exist (or user wants to overwrite):

Invoke the `/mpx-create-spec` skill to interactively gather project requirements and tech stack decisions.

```
Use Skill tool: skill: "mpx-create-spec"
```

### Step 3: Confirm Git Initialization

After spec is created, ask the user:

> "Ready to initialize git repository? This will create:
> - `.git/` directory
> - Comprehensive `.gitignore`
> - Initial commit
>
> Proceed? (yes/no)"

Use `AskUserQuestion` for this confirmation.

### Step 4: Initialize Repository

If user confirms, invoke `/mpx-init-repo`:

```
Use Skill tool: skill: "mpx-init-repo"
```

If user declines, skip to next step.

### Step 5: Parse Specification

Invoke `/mpx-parse-spec` to generate implementation plan:

```
Use Skill tool: skill: "mpx-parse-spec"
```

This creates phases + ROADMAP.md + STATE.md.

### Step 6: Final Summary

Present a summary of everything created:

```
Project Initialized Successfully!

Project: [Name]
Tech Stack: [Language] + [Framework] + [Database]

Files Created:
  .gitignore              ✓
  .claude/CLAUDE.md       ✓
  .mpx/SPEC.md         ✓
  .mpx/ROADMAP.md      ✓
  .mpx/STATE.md        ✓
  .mpx/phases/         ✓

Git Status:
  Repository initialized  ✓
  Initial commit created  ✓

Next Steps:
  Run `/mpx-execute` to start Phase 1 with fresh context.
  Run `/mpx-show-project-status` to check progress at any time.
```

## Error Handling

- If `/mpx-create-spec` fails, stop and report the error
- If `/mpx-init-repo` fails (e.g., git not installed), continue but warn user
- If `/mpx-parse-spec` fails, suggest user check SPEC.md format

## Notes

- This skill orchestrates other skills - it doesn't do implementation itself
- Each sub-skill handles its own error cases
- The user can always run individual skills if they prefer
- All project files are created in `.mpx/` directory
