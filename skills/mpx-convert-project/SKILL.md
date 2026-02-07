---
name: mpx-convert-project
description: Convert existing project to mpx structure. Auto-detects tech stack, gathers goals, generates spec and phases.
disable-model-invocation: true
allowed-tools: Read, Write, Bash, Glob, Grep, Skill, Task, AskUserQuestion
---

# Convert Existing Project

Onboard an existing codebase into the mpx spec-driven workflow. Auto-detects tech stack, gathers forward-looking goals, generates SPEC.md with existing features marked IMPLEMENTED, then creates phased plan for new work.

## Workflow Overview

```
┌──────────────────────────┐
│  /mpx-convert-project    │
└────────┬─────────────────┘
         │
         ▼
┌──────────────────────────┐
│  Check prerequisites     │ ◄── .git/ exists? .mpx/ exists?
└────────┬─────────────────┘
         │
         ▼
┌──────────────────────────┐
│  Scan codebase           │ ◄── mpx-codebase-scanner agent
└────────┬─────────────────┘
         │
         ▼
┌──────────────────────────┐
│  Present & confirm       │ ◄── AskUserQuestion for corrections
└────────┬─────────────────┘
         │
         ▼
┌──────────────────────────┐
│  Gather goals            │ ◄── What to build/fix/improve
└────────┬─────────────────┘
         │
         ▼
┌──────────────────────────┐
│  Generate SPEC.md        │ ◄── Existing features IMPLEMENTED
└────────┬─────────────────┘
         │
         ▼
┌──────────────────────────┐
│  /mpx-parse-spec         │ ◄── Phase generation
└────────┬─────────────────┘
         │
         ▼
┌──────────────────────────┐
│  Update CLAUDE.md        │ ◄── Real project info
└────────┬─────────────────┘
         │
         ▼
┌──────────────────────────┐
│  Summary                 │
└──────────────────────────┘
```

## Instructions

### Step 1: Check Prerequisites

Verify the environment:

1. **`.git/` must exist** — this skill is for existing projects with git history. If missing, tell user to run `git init` first or use `/mpx-init-project` instead.
2. **Check for `.mpx/`** — if it already exists, use `AskUserQuestion`:
   - **Overwrite** — delete existing `.mpx/` and start fresh
   - **Add requirements** — keep existing spec, invoke `/mpx-add-requirements` instead
   - **Abort** — stop
3. **Verify source files exist** — glob for common source patterns (`*.ts`, `*.js`, `*.py`, `*.go`, `*.rs`, `*.java`, `*.rb`, `*.php`, `*.svelte`, `*.vue`, `*.jsx`, `*.tsx`). If no source files found, warn user this appears to be an empty project and suggest `/mpx-init-project`.

### Step 2: Scan Codebase

Spawn the `mpx-codebase-scanner` agent via the Task tool:

```
Use Task tool:
  subagent_type: "mpx-codebase-scanner"
  prompt: "Scan the codebase in the current directory and produce a structured report. Follow your scanning steps exactly."
```

The agent returns a structured markdown report with: Project Identity, Tech Stack, Structure, Dev Commands, Existing Features, Dependencies, Entry Points, Codebase Size, Notable Patterns.

Store the full report for use in subsequent steps.

### Step 3: Present Findings & Confirm

Display a summary of what was detected:

```
Detected Profile:
  Project:         [name]
  Language:        [language]
  Framework:       [framework]
  Database:        [db]
  Package Manager: [pm]
  Testing:         [testing tools]
  Features Found:  [count]
  Codebase Size:   ~[LOC] lines, [commits] commits
```

Then use `AskUserQuestion`:
- "Is this detection accurate? Select any corrections needed."
- Options:
  - **Looks correct** — proceed as-is
  - **Needs corrections** — user provides corrections in text
  - **Scan missed features** — user lists additional existing features

Apply any corrections to the scan report before proceeding.

### Step 4: Gather Goals

Use `AskUserQuestion` to understand what the user wants to build going forward:

**Question:** "What do you want to build, fix, or improve? Describe your goals for this project."

This is a free-text question — the user describes their forward-looking requirements. These become the "New Requirements" in the spec.

If the user provides multiple goals, follow up to clarify priority:
- Which goals are highest priority?
- Any specific order or dependencies between goals?

### Step 5: Generate SPEC.md

Create `.mpx/SPEC.md` with the following structure:

```markdown
# [Project Name] — Specification

> **Converted from existing project.** Features marked `[IMPLEMENTED]` already exist in the codebase. Do not create setup tasks for existing infrastructure. Phase planning should start from New Requirements.

Generated: [Date]

## Project Overview
[Description from scan report or user input]

## Tech Stack
- **Language:** [detected]
- **Runtime:** [detected]
- **Framework:** [detected]
- **CSS/Styling:** [detected]
- **Database:** [detected]
- **ORM:** [detected]
- **Package Manager:** [detected]
- **Testing:** [detected]

## Project Structure
```
[from scan report]
```

## Dev Commands
[from scan report — table of commands]

## Existing Features [IMPLEMENTED]

> These features are already implemented. They are documented here for context but should NOT be re-implemented in phases.

### [Feature 1] [IMPLEMENTED]
[Brief description from scan]

### [Feature 2] [IMPLEMENTED]
[Brief description from scan]

[... all detected features ...]

## New Requirements

### [Goal 1]
[Description from user goals]

#### Acceptance Criteria
- [Derived from user description]

### [Goal 2]
[Description from user goals]

#### Acceptance Criteria
- [Derived from user description]

[... all user goals ...]

## Technical Constraints
- Must integrate with existing codebase patterns
- Preserve existing functionality
- Follow established project conventions
[Any other constraints from scan — e.g., specific Node version, etc.]

## Dependencies Between Requirements
[Map out if any new requirements depend on others]
```

Write this to `.mpx/SPEC.md`.

### Step 6: Invoke /mpx-parse-spec

Invoke the existing parse-spec skill to generate phases:

```
Use Skill tool: skill: "mpx-parse-spec"
```

The `[IMPLEMENTED]` markers and instruction at the top of SPEC.md guide parse-spec to:
- Skip creating "foundation" or "setup" phases for existing infrastructure
- Focus phases entirely on the New Requirements
- Reference existing features as available dependencies (e.g., "uses existing auth system")

### Step 7: Update .claude/CLAUDE.md

Create or update `.claude/CLAUDE.md` in the **project directory** (not the global one) with real project information:

```markdown
# [Project Name]

## Tech Stack
[From scan report]

## Project Structure
[Key directories and their purpose]

## Dev Commands
```bash
[package manager] dev    # Start dev server
[package manager] build  # Build for production
[package manager] test   # Run tests
[package manager] lint   # Run linter
```

## Key Files
[Entry points, config files, important modules]

## Conventions
- [Detected patterns — e.g., feature-based organization, barrel exports, etc.]
- [Commit style if detectable from git history]

## MPX Project
- Spec: `.mpx/SPEC.md`
- Roadmap: `.mpx/ROADMAP.md`
- State: `.mpx/STATE.md`
- Phases: `.mpx/phases/`
```

**Before writing:**
- If `.claude/CLAUDE.md` already exists, read it first
- If it has non-template content (custom instructions, project-specific notes), use `AskUserQuestion` to ask whether to overwrite, merge, or skip
- If it's empty or has only template/placeholder content, overwrite silently

### Step 8: Summary

Present the final summary:

```
Project Converted Successfully!

Project: [Name]
Tech Stack: [Language] + [Framework] + [Database]

Existing Features (preserved):
  - [Feature 1]
  - [Feature 2]
  - [...]

New Requirements (planned):
  - [Goal 1]
  - [Goal 2]
  - [...]

Files Created:
  .mpx/SPEC.md           ✓
  .mpx/ROADMAP.md        ✓
  .mpx/STATE.md          ✓
  .mpx/phases/           ✓
  .claude/CLAUDE.md      ✓ [created/updated]

Phases: [N] phases focusing on new work
  1. [Phase name] ([N] tasks)
  2. [Phase name] ([N] tasks)
  [...]

Next Steps:
  Run `/mpx-execute-task` to start Phase 1 with fresh context.
  Run `/mpx-show-project-status` to check progress at any time.
```

## Error Handling

- If `.git/` doesn't exist → suggest `git init` or `/mpx-init-project`
- If scanner agent fails → report error, suggest manual spec creation with `/mpx-create-spec`
- If `/mpx-parse-spec` fails → suggest checking SPEC.md format
- If no source files detected → suggest `/mpx-init-project` for new projects

## Notes

- This skill orchestrates scanning + spec generation + phase planning
- The scanner agent runs with sonnet model for cost efficiency
- Existing features are preserved, not re-planned
- Key differentiator from `/mpx-init-project`: auto-detection instead of manual Q&A
