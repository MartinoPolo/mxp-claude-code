---
name: mpx-project-workflow
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
                 phases/
```

## File Responsibilities

| File | Purpose | When Updated |
|------|---------|--------------|
| SPEC.md | Requirements, tech stack, scope | Initial creation, scope changes |
| ROADMAP.md | Phase overview, dependencies, tracking, decisions, blockers | Phase completion, decisions |
| phases/NN-name/ | Phase folder with CHECKLIST.md (specs + tasks + state) | During phase execution |

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
- Run `/mpx-handoff` at end of each session to create ephemeral HANDOFF.md
- HANDOFF.md only exists if `/mpx-handoff` was run — it is optional, not always present
- Note any decisions made and why
- Document blockers clearly
- Leave "next step" note for continuity
- HANDOFF.md is consumed and deleted by `/mpx-execute` at next session start

## Troubleshooting

### "I'm lost in my project"
1. Run `/mpx-show-project-status` to see current state
2. Read ROADMAP.md for overall progress and decisions
3. Check last commits with `git log --oneline -10`

### "The plan doesn't match reality"
1. Update SPEC.md with actual requirements
2. Run `/mpx-parse-spec` to regenerate checklists
3. Review and adjust as needed

### "Context is getting degraded"
1. Use `/mpx-execute` for complex work
2. This spawns fresh agent with clean context
3. CHECKLIST.md maintains continuity (HANDOFF.md adds optional session context if `/mpx-handoff` was run)

### "I need to change scope"
1. Update SPEC.md with new requirements
2. Regenerate with `/mpx-parse-spec`
3. Completed work is preserved in git

### "I need to add new requirements"
1. Run `/mpx-add-requirements "description"`
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
/mpx-init-project       - Full setup (spec + git + checklist)
/mpx-create-spec        - Interactive spec creation
/mpx-init-repo          - Git initialization only
/mpx-parse-spec         - Generate checklists from spec
/mpx-execute                  - Execute tasks (full phase or single)
/mpx-show-project-status     - Show progress and next steps
/mpx-add-requirements   - Add new requirements to existing project
```
