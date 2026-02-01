---
name: mp-add-requirements
description: Add new requirements to project. Parses current spec, checklist, state, and roadmap. Updates all files and detects conflicts.
disable-model-invocation: false
allowed-tools: Read, Write, Bash, AskUserQuestion
args: "[requirements]"
---

# Add Requirements

Add new requirements to an existing project, updating all relevant files and detecting conflicts.

## Usage

```
/mp-add-requirements "Add dark mode support"
/mp-add-requirements "User authentication with OAuth"
/mp-add-requirements   # Prompts for requirements
```

## Prerequisites

- `.claude/SPEC.md` must exist
- `.claude/ROADMAP.md` must exist

## Workflow

### Step 1: Parse New Requirements

If requirements provided as argument, use them.
If no argument, ask the user:

> "What new requirements would you like to add to the project?"

### Step 2: Read Current State

Read all relevant project files:
- `.claude/SPEC.md` - Master requirements
- `.claude/ROADMAP.md` - Phase overview + tracking
- `.claude/STATE.md` - Current progress + session handoff
- `.claude/CLAUDE.md` - Project context (if exists)
- `.claude/phases/*/SPEC.md` - Phase requirements
- `.claude/phases/*/CHECKLIST.md` - Phase tasks

### Step 3: Analyze for Conflicts

Check the new requirements against existing specifications:

**Tech Stack Conflicts:**
- Adding MongoDB when SPEC.md says "Database: PostgreSQL"
- Adding React when SPEC.md says "Framework: Vue"
- Adding Python when SPEC.md says "Language: TypeScript"

**Requirement Conflicts:**
- "Remove authentication" when existing tasks depend on auth
- "Add offline support" that contradicts "Real-time sync" requirement
- Contradicting business logic requirements

**Scope Conflicts:**
- Adding features explicitly marked as "Out of Scope"
- Requirements that dramatically change project complexity
- Features that depend on non-existent infrastructure

### Step 4: Report Conflicts (if any)

If conflicts detected, present them to the user:

```
⚠️ Potential Conflicts Detected:

1. Tech Stack Conflict:
   - New: "Add MongoDB database"
   - Existing: "Database: PostgreSQL"
   - Impact: Would require database migration or dual-database setup

2. Requirement Conflict:
   - New: "Remove user authentication"
   - Existing: Tasks in Phase 2 depend on authentication
   - Impact: Would invalidate 8 existing tasks

Options:
1. Proceed anyway (will add notes about conflicts)
2. Modify requirements to resolve conflicts
3. Cancel and review manually
```

Use `AskUserQuestion` for conflict resolution.

### Step 5: Update Files

1. **Update SPEC.md:**
   - Add to features list
   - Note tech stack changes

2. **Determine placement:**
   - Can it fit in an existing phase? → Add to that phase's CHECKLIST.md
   - Needs new phase? → Create new phase folder
   - Spans multiple phases? → Distribute tasks appropriately

3. **Update ROADMAP.md:**
   - Add tasks to phase summary
   - Update task counts

4. **Update phase files:**
   - Add new tasks to appropriate phase's CHECKLIST.md
   - Update phase's SPEC.md if scope changes

5. **Update STATE.md:**
   - Add note about requirements change
   - Update task counts

### Step 6: Report Changes

```
Requirements Added Successfully!

New Requirements:
  - [Description]

Files Updated:
  ✓ .claude/SPEC.md - Added to Core Features
  ✓ .claude/ROADMAP.md - Updated Phase 3 task count
  ✓ .claude/phases/03-secondary/CHECKLIST.md - Added tasks
  ✓ .claude/phases/03-secondary/SPEC.md - Updated scope

New Tasks Generated:
  - [ ] [Task 1]
  - [ ] [Task 2]
  - [ ] [Task 3]

[If conflicts were noted:]
⚠️ Conflicts Noted:
  - Database conflict noted in SPEC.md
  - Consider reviewing Phase 2 dependencies

Run `/mp-project-status` to see updated progress.
Run `/mp-execute` to start working on new tasks.
```

## Conflict Detection Rules

### Hard Conflicts (Block by default)
- Contradicting tech stack (different databases, frameworks, languages)
- Removing features that have dependent tasks
- Adding features marked as "Out of Scope"

### Soft Conflicts (Warn but allow)
- Adding features that increase complexity
- Adding features to completed phases
- Features that may need additional infrastructure

### No Conflict
- New features that fit naturally
- Enhancements to existing features
- Additional polish/testing tasks

## Task Generation Guidelines

When generating tasks for new requirements:
- Each task should be atomic
- Follow existing task style in the project
- Include setup tasks if needed
- Include testing tasks
- Consider dependencies on existing features

## Error Handling

- **No SPEC.md:** "No project found. Run `/mp-init-project` first."
- **Empty requirements:** "Please specify what requirements to add."
- **Unresolvable conflict:** "Cannot add requirements due to fundamental conflicts. Manual review required."

## Notes

- This skill modifies project files - changes can be reviewed with `git diff`
- Conflict detection is advisory - user has final say
- Tasks are generated based on the requirement description
- Complex requirements may need manual task refinement
