---
name: project-status
description: Show current project progress and next steps. Works for both simple and complex projects.
disable-model-invocation: true
allowed-tools: Read, Bash
---

# Project Status

Display current project progress, completed tasks, and next steps. Works for both simple (checklist-based) and complex (phase-based) projects.

## Usage

```
/project-status
```

## Workflow

### Step 1: Detect Project Type

Check which files exist:
- `.claude/CHECKLIST.md` - Required for any tracked project
- `.claude/STATE.md` - Indicates complex (phased) project
- `.claude/phases/` - Phase files for complex projects

**Simple Project:** Has CHECKLIST.md but no STATE.md
**Complex Project:** Has CHECKLIST.md, STATE.md, and phases/

### Step 2: Gather Progress Data

**For Simple Projects:**
1. Read `.claude/CHECKLIST.md`
2. Count total tasks (lines with `- [ ]` or `- [x]`)
3. Count completed tasks (lines with `- [x]`)
4. Identify current section being worked on
5. Find next incomplete task

**For Complex Projects:**
1. Read `.claude/STATE.md` for current status
2. Read `.claude/ROADMAP.md` for phase overview
3. For current phase, read phase file to get task progress
4. Compile overall statistics

### Step 3: Generate Status Display

**Simple Project Format:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 Project Status: [Project Name]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Progress: ████████░░░░░░░░░░░░ 40% (8/20 tasks)

Sections:
  ✅ Setup (4/4)
  🔄 Feature: User Auth (2/6) ◄ Current
  ⬜ Feature: Dashboard (0/5)
  ⬜ Polish (0/5)

Next Task:
  □ Implement password hashing

Recent Completions:
  ✓ Set up Express server
  ✓ Configure database connection
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Complex Project Format:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 Project Status: [Project Name]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Current Phase: Phase 2 - Core Feature
Overall Progress: ████░░░░░░░░░░░░░░░░ 20%

Phase Breakdown:
  ✅ Phase 1: Foundation      (8/8 tasks)
  🔄 Phase 2: Core Feature    (3/12 tasks) ◄ Active
  ⬜ Phase 3: Secondary       (0/8 tasks)
  ⬜ Phase 4: Polish          (0/6 tasks)

Current Phase Progress:
  ████████░░░░░░░░░░░░ 25% (3/12 tasks)

  Completed:
    ✓ Set up API routes
    ✓ Create data models
    ✓ Implement basic CRUD

  Next:
    □ Add authentication middleware

Blockers:
  None

Session Notes:
  [Latest note from STATE.md]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Commands:
  /execute-phase 2    Continue current phase
  /parse-spec         Regenerate checklists
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Step 4: Show Contextual Commands

Based on project state, suggest relevant next commands:

- If no tasks done: "Start with the first task in Setup"
- If phase incomplete: "Continue with `/execute-phase N`"
- If phase complete: "Ready for `/execute-phase N+1`"
- If blockers exist: "Resolve blockers before continuing"
- If all done: "Project complete! Consider final review"

## Progress Bar Generation

Generate ASCII progress bars based on completion percentage:

```
0%:   ░░░░░░░░░░░░░░░░░░░░
25%:  █████░░░░░░░░░░░░░░░
50%:  ██████████░░░░░░░░░░
75%:  ███████████████░░░░░
100%: ████████████████████
```

Use 20 characters for the bar.

## Status Icons

- ✅ Completed section/phase
- 🔄 In progress (has some completed tasks)
- ⬜ Not started
- 🚫 Blocked
- ◄ Current/Active indicator

## Error Cases

- **No CHECKLIST.md:** "No project tracking found. Run `/init-project` or `/parse-spec` first."
- **Empty checklist:** "Checklist exists but has no tasks. Check `.claude/CHECKLIST.md`"
- **Corrupted STATE.md:** "Could not parse STATE.md. Consider regenerating with `/parse-spec`"

## Notes

- This is a read-only operation - it never modifies files
- Works from any directory within the project
- Can be run at any time to check progress
- Useful for session handoff - shows where to continue
