---
name: mp-project-workflow
description: Project workflow guidance for spec-driven development. Background knowledge auto-loaded when relevant.
user-invocable: false
---

# Project Workflow Guide

This document provides background knowledge about spec-driven development workflow. It is automatically loaded when discussing project specifications, checklists, or implementation planning.

## Workflow Overview

```
┌──────────────────────────────────────────────────────────────┐
│                     Project Lifecycle                        │
└──────────────────────────────────────────────────────────────┘

  Idea ──► Spec ──► Plan ──► Implement ──► Test ──► Ship
           │         │           │
           ▼         ▼           ▼
        SPEC.md  ROADMAP.md   Commits
                 STATE.md
                 phases/
```

## File Responsibilities

| File | Purpose | When Updated |
|------|---------|--------------|
| SPEC.md | Requirements, tech stack, scope | Initial creation, scope changes |
| ROADMAP.md | Phase overview, dependencies, high-level tracking | Phase completion |
| STATE.md | Global state, session handoff, decisions, blockers | Each session |
| phases/NN-name/ | Phase folder with SPEC.md, CHECKLIST.md, STATE.md | During phase execution |

## Best Practices

### Writing Good Specifications
- Be specific about features, not implementation
- Include success criteria
- Define what's OUT of scope
- List assumptions explicitly

### Breaking Down Tasks
- Each task should be completable in one sitting
- Tasks should have clear completion criteria
- Group related tasks together
- Order tasks by dependency

### Phase Design
- Each phase should produce working software
- Minimize dependencies between phases
- Foundation phase always comes first
- Polish/testing phase always comes last

### Session Handoff
- Update STATE.md at end of each session
- Note any decisions made and why
- Document blockers clearly
- Leave "next step" note for continuity

## Troubleshooting

### "I'm lost in my project"
1. Run `/mp-project-status` to see current state
2. Read STATE.md for recent context
3. Check last commits with `git log --oneline -10`

### "The plan doesn't match reality"
1. Update SPEC.md with actual requirements
2. Run `/mp-parse-spec` to regenerate checklists
3. Review and adjust as needed

### "Context is getting degraded"
1. Use `/mp-execute` for complex work
2. This spawns fresh agent with clean context
3. STATE.md maintains continuity

### "I need to change scope"
1. Update SPEC.md with new requirements
2. Regenerate with `/mp-parse-spec`
3. Completed work is preserved in git

### "I need to add new requirements"
1. Run `/mp-add-requirements "description"`
2. Reviews current state and detects conflicts
3. Updates SPEC.md and generates new tasks

## Integration with Git

### Commit Strategy
- Commit after each logical unit of work
- Use descriptive commit messages
- For phases: `phase-N: description`
- For tasks: `[section] description`

### Branch Strategy (optional)
- Main branch for stable code
- Feature branches for risky changes
- Merge when phase completes

## Quick Reference

```
/mp-init-project       - Full setup (spec + git + checklist)
/mp-create-spec        - Interactive spec creation
/mp-init-repo          - Git initialization only
/mp-parse-spec         - Generate checklists from spec
/mp-execute            - Execute next task (simple or complex)
/mp-project-status     - Show progress and next steps
/mp-add-requirements   - Add new requirements to existing project
```
