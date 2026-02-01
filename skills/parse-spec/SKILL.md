---
name: parse-spec
description: Parse SPEC.md into implementation checklist or phases. Auto-detects complexity. Creates CHECKLIST.md for simple projects, phase folders + ROADMAP.md + STATE.md for complex.
disable-model-invocation: false
allowed-tools: Read, Write, Bash
---

# Parse Specification

Convert SPEC.md into actionable implementation checklists or phases based on project complexity.

## Prerequisites

- `.claude/SPEC.md` must exist
- SPEC.md should have a "Complexity" field (Simple or Complex)
- If complexity field is missing, analyze features to determine it

## Workflow

### Step 1: Read and Analyze SPEC.md

Read `.claude/SPEC.md` and extract:
- Project name
- Tech stack
- Complexity level
- Core features
- Technical requirements

### Step 2: Determine Output Format

**If Simple Project:**
- Create single `.claude/CHECKLIST.md`

**If Complex Project:**
- Create `.claude/CHECKLIST.md` (high-level phase tracking)
- Create `.claude/ROADMAP.md` (phase overview)
- Create `.claude/STATE.md` (session handoff)
- Create `.claude/phases/` directory with phase files

### Step 3A: Simple Project - Create CHECKLIST.md

```markdown
# Implementation Checklist

Project: [Name]
Generated: [Date]

## Setup
- [ ] Initialize project with [package manager]
- [ ] Configure [framework]
- [ ] Set up [testing framework]

## Feature: [Feature 1 Name]
- [ ] [Task 1.1]
- [ ] [Task 1.2]
- [ ] [Task 1.3]

## Feature: [Feature 2 Name]
- [ ] [Task 2.1]
- [ ] [Task 2.2]

## Polish
- [ ] Add error handling
- [ ] Write README.md
- [ ] Final testing

---
Progress: 0/N tasks complete
```

### Step 3B: Complex Project - Create Phase Structure

**CHECKLIST.md** (high-level):
```markdown
# Implementation Checklist

Project: [Name]
Generated: [Date]
Complexity: Complex (Phased)

## Phases
- [ ] Phase 1: Foundation
- [ ] Phase 2: [Core Feature Name]
- [ ] Phase 3: [Secondary Features]
- [ ] Phase 4: Polish & Testing

See `phases/` for detailed task breakdowns.
See `ROADMAP.md` for phase overview.
See `STATE.md` for session handoff notes.
```

**ROADMAP.md**:
```markdown
# Implementation Roadmap

Generated: [Date]
Total Phases: N

## Overview
[Brief summary of the full implementation approach]

## Phase Summary

| Phase | Name | Status | Tasks | Dependencies |
|-------|------|--------|-------|--------------|
| 1 | Foundation | Not Started | N | None |
| 2 | [Feature] | Not Started | N | Phase 1 |
| 3 | [Feature] | Not Started | N | Phase 2 |
| 4 | Polish | Not Started | N | Phase 3 |

## Dependency Graph
```
Phase 1 (Foundation)
    │
    ▼
Phase 2 (Core Feature)
    │
    ▼
Phase 3 (Secondary)
    │
    ▼
Phase 4 (Polish)
```

## Phase Details

### Phase 1: Foundation
**Goal:** Set up project infrastructure
**Deliverables:** Working dev environment, basic project structure

### Phase 2: [Feature Name]
**Goal:** Implement core functionality
**Deliverables:** [Specific outputs]

[Continue for all phases...]
```

**STATE.md**:
```markdown
# Project State

Last Updated: [Date]

## Current Status
- **Active Phase:** Phase 1 - Foundation
- **Phase Status:** Not Started
- **Overall Progress:** 0%

## Completed Phases
None

## Phase Progress
| Phase | Status | Progress |
|-------|--------|----------|
| 1 | Not Started | 0/N tasks |
| 2 | Blocked | - |
| 3 | Blocked | - |
| 4 | Blocked | - |

## Decisions Made
[Record important decisions here for context]

## Blockers
None

## Session Notes
[Use this section for handoff between sessions]

### [Date] - Session Start
- Initial project setup
- Created implementation plan
```

**Phase Files** (`.claude/phases/01-foundation.md`):
```markdown
# Phase 1: Foundation

**Status:** Not Started
**Estimated Tasks:** N
**Dependencies:** None

## Objective
Set up the project infrastructure and development environment.

## Tasks

### Setup
- [ ] Initialize [package manager] project
- [ ] Install core dependencies
- [ ] Configure TypeScript/linting

### Project Structure
- [ ] Create directory structure
- [ ] Set up entry point
- [ ] Configure build process

### Development Environment
- [ ] Set up dev server
- [ ] Configure hot reload
- [ ] Add debug configuration

## Completion Criteria
- [ ] Project builds without errors
- [ ] Dev server runs successfully
- [ ] Basic tests pass

## Notes
[Phase-specific notes and considerations]
```

### Step 4: Update CLAUDE.md

If `.claude/CLAUDE.md` exists and has template content, update it with actual project information from SPEC.md.

### Step 5: Summary

Report what was created:

**For Simple Projects:**
> "Created `.claude/CHECKLIST.md` with N tasks across M sections.
>
> Start implementing by working through the checklist. Mark items with [x] as you complete them."

**For Complex Projects:**
> "Created phased implementation plan:
> - `.claude/CHECKLIST.md` - High-level phase tracking
> - `.claude/ROADMAP.md` - Phase overview and dependencies
> - `.claude/STATE.md` - Session handoff tracking
> - `.claude/phases/` - Detailed phase breakdowns
>
> **Phases Created:**
> 1. Foundation (N tasks)
> 2. [Feature] (N tasks)
> ...
>
> Run `/execute-phase 1` to start Phase 1 with fresh context."

## Task Breakdown Guidelines

When breaking features into tasks, ensure:
- Each task is atomic and completable in one sitting
- Tasks have clear completion criteria
- Dependencies between tasks are noted
- Setup tasks come before feature tasks
- Testing tasks are included for each feature
- Polish/cleanup tasks come at the end

## Notes

- All files are created in `.claude/` directory
- Never create duplicate files in project root
- If files already exist, ask before overwriting
- Phase files should be numbered (01-, 02-, etc.) for ordering
