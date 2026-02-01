---
name: project-workflow
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
        SPEC.md  CHECKLIST.md  Commits
                 ROADMAP.md
                 STATE.md
```

## Simple vs Complex Projects

### Simple Projects
- **Characteristics:** 1-3 features, single focus, short duration
- **Tracking:** Single CHECKLIST.md
- **Workflow:** Work through checklist sequentially
- **Session handling:** Just continue where you left off

### Complex Projects
- **Characteristics:** 4+ features, multiple components, multi-session
- **Tracking:** Phases + STATE.md + ROADMAP.md
- **Workflow:** Execute phases with `/execute-phase N`
- **Session handling:** STATE.md tracks handoff context

## File Responsibilities

| File | Purpose | When Updated |
|------|---------|--------------|
| SPEC.md | Requirements, tech stack, scope | Initial creation, scope changes |
| CHECKLIST.md | Task tracking | As tasks complete |
| ROADMAP.md | Phase overview, dependencies | Phase completion |
| STATE.md | Session handoff, decisions, blockers | Each session |
| phases/*.md | Detailed phase tasks | During phase execution |

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
1. Run `/project-status` to see current state
2. Read STATE.md for recent context
3. Check last commits with `git log --oneline -10`

### "The plan doesn't match reality"
1. Update SPEC.md with actual requirements
2. Run `/parse-spec` to regenerate checklists
3. Review and adjust as needed

### "Context is getting degraded"
1. Use `/execute-phase N` for complex work
2. This spawns fresh agent with clean context
3. STATE.md maintains continuity

### "I need to change scope"
1. Update SPEC.md with new requirements
2. Regenerate with `/parse-spec`
3. Completed work is preserved in git

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
/init-project     - Full setup (spec + git + checklist)
/create-spec      - Interactive spec creation
/init-repo        - Git initialization only
/parse-spec       - Generate checklists from spec
/execute-phase N  - Execute phase with fresh context
/project-status   - Show progress and next steps
```
