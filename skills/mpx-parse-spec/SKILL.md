---
name: mpx-parse-spec
description: Parse SPEC.md into phased implementation. Creates phase folders + ROADMAP.md + STATE.md.
disable-model-invocation: false
allowed-tools: Read, Write, Bash
---

# Parse Specification

Convert SPEC.md into a phased implementation plan with tracking files.

## Prerequisites

- `.mpx/SPEC.md` must exist

## Workflow

### Step 1: Read and Analyze SPEC.md

Read `.mpx/SPEC.md` and extract:
- Project name
- Tech stack
- Core features
- Technical requirements

### Step 2: Create Phase Structure

Create the following:
- `.mpx/ROADMAP.md` (phase overview + high-level tracking)
- `.mpx/STATE.md` (global state + session handoff)
- `.mpx/phases/` directory with **phase folders**

Smaller projects may have just 1-2 phases; larger projects may have more.

### Step 3: Create Files

**ROADMAP.md** (phase overview + tracking):
```markdown
# Implementation Roadmap

Project: [Name]
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

**STATE.md** (global state + session handoff):
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

---

## Session Handoff

### [Date] - Session Start
**Progress:**
- Initial project setup
- Created implementation plan

**Key Decisions:**
- [Decisions made]

**Issues Encountered:**
- What went wrong: None
- What NOT to do: [Lessons learned]
- What we tried: [Approaches attempted]
- How we handled it: [Solutions found]

**Next Steps:**
1. Start Phase 1: Foundation
2. [Next action]

**Critical Files:**
- `.mpx/SPEC.md`
- `.mpx/ROADMAP.md`

**Working Memory:**
[Accumulated context, patterns, file relationships]
```

**Phase Folders** (`.mpx/phases/01-foundation/`):

Each phase gets its own folder with three files:

**SPEC.md** (phase-specific requirements):
```markdown
# Phase 1: Foundation - Specification

**Status:** Not Started
**Dependencies:** None

## Objective
Set up the project infrastructure and development environment.

## Scope
- Initialize project structure
- Set up build tools
- Configure development environment

## Out of Scope
- Feature implementation
- Production deployment

## Deliverables
- Working dev environment
- Basic project structure
- Build configuration

## Notes
[Phase-specific considerations]
```

**CHECKLIST.md** (phase tasks):
```markdown
# Phase 1: Foundation - Checklist

## Setup
- [ ] Initialize [package manager] project
- [ ] Install core dependencies
- [ ] Configure TypeScript/linting

## Project Structure
- [ ] Create directory structure
- [ ] Set up entry point
- [ ] Configure build process

## Development Environment
- [ ] Set up dev server
- [ ] Configure hot reload
- [ ] Add debug configuration

## Completion Criteria
- [ ] Project builds without errors
- [ ] Dev server runs successfully
- [ ] Basic tests pass

---
Progress: 0/N tasks complete
```

**STATE.md** (phase state + session handoff):
```markdown
# Phase 1: Foundation - State

Last Updated: [Date]

## Status
Not Started

## Progress
0/N tasks complete (0%)

## Decisions Made
[Phase-specific decisions]

## Blockers
None

---

## Session Handoff

### [Date]
**Progress This Session:**
- [What was accomplished]

**Key Decisions:**
- [Decisions made this session]

**Issues Encountered:**
- What went wrong: [...]
- What NOT to do: [...]
- What we tried: [...]
- How we handled it: [...]

**Next Steps:**
1. [...]
2. [...]

**Critical Files:**
- [Files involved in current work]

**Working Memory:**
[Accumulated context, patterns, file relationships]
```

### Step 4: Update CLAUDE.md

If `.claude/CLAUDE.md` exists and has template content, update it with actual project information from SPEC.md.

### Step 5: Summary

Report what was created:

> "Created phased implementation plan:
> - `.mpx/ROADMAP.md` - Phase overview, dependencies, and tracking
> - `.mpx/STATE.md` - Global state and session handoff
> - `.mpx/phases/` - Phase folders with SPEC.md, CHECKLIST.md, STATE.md each
>
> **Phases Created:**
> 1. Foundation (N tasks)
> 2. [Feature] (N tasks)
> ...
>
> Run `/mpx-execute-task` to start with the first task."

## Task Breakdown Guidelines

When breaking features into tasks, ensure:
- Each task is atomic and completable in one sitting
- Tasks have clear completion criteria
- Dependencies between tasks are noted
- Setup tasks come before feature tasks
- Testing tasks are included for each feature
- Polish/cleanup tasks come at the end

## Phase Folder Structure Summary

```
.mpx/
├── SPEC.md              # Master project specification
├── ROADMAP.md           # Phase overview + high-level tracking
├── STATE.md             # Global state + session handoff
└── phases/
    ├── 01-foundation/
    │   ├── SPEC.md      # Phase requirements
    │   ├── CHECKLIST.md # Phase tasks
    │   └── STATE.md     # Phase state + session handoff
    ├── 02-core-feature/
    │   ├── SPEC.md
    │   ├── CHECKLIST.md
    │   └── STATE.md
    └── 03-polish/
        ├── SPEC.md
        ├── CHECKLIST.md
        └── STATE.md
```

## Notes

- All files are created in `.mpx/` directory
- Never create duplicate files in project root
- If files already exist, ask before overwriting
- Phase folders should be numbered (01-, 02-, etc.) for ordering
- Each phase folder contains its own SPEC.md, CHECKLIST.md, STATE.md
- ROADMAP.md tracks phase completion (update Status column when phases complete)
