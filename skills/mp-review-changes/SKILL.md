---
name: mp-review-changes
description: 'Lightweight code review of uncommitted changes with actionable checklist output. Use when: "review changes", "review uncommitted", "check my changes"'
disable-model-invocation: true
allowed-tools: Read, Write, Glob, Grep, Bash(git status *), Bash(git diff *), Bash(git log *), Bash(git branch --show-current *), Bash(git rev-parse *), Bash(git ls-files *)
metadata:
  author: MartinoPolo
  version: "0.1"
  category: code-review
---

# Review Uncommitted Changes

Lightweight multi-agent code review of all uncommitted changes (staged + unstaged). Produces actionable checklist file.

This review is **READ-ONLY** except for writing `REVIEW-CHANGES.md`. It does NOT:
- Post to GitHub
- Make commits
- Modify source files

## Phase 1: Discovery (Haiku Agent)

Launch a Haiku agent to gather context:

1. Get combined uncommitted changes: `git diff` + `git diff --cached`
2. Get changed file list: `git status`
3. If NO changes (clean working tree) → **exit early**: "No uncommitted changes to review."
4. Detect tech stack from file extensions and config files (package.json, Cargo.toml, go.mod, etc.)
5. Check for CLAUDE.md files in the repo
6. Check for spec files: `.mpx/SPEC.md`, `SPEC.md`, active checklists (`.mpx/phases/*/CHECKLIST.md`)
7. Return: changed files, combined diff, detected tech stack, CLAUDE.md locations, spec file presence

## Phase 2: Parallel Review (2-3 Sonnet Agents)

Launch parallel Sonnet agents. Each receives the full diff, changed files list, and tech stack info.

> **Full agent specifications:** See `references/review-agents.md`

**Always launch:**
- Agent 1: **Code Quality & DRY/SoC** — duplication, redundant logic, separation of concerns, naming, type safety, overcomplicated code
- Agent 2: **Best Practices & Conventions** — tech stack idioms, CLAUDE.md compliance, language conventions

**Conditionally launch:**
- Agent 3: **Spec Alignment** — only if spec files were found in Phase 1. Requirements coverage, YAGNI, scope creep

Each agent classifies issues directly as **Critical**, **Important**, or **Minor**. No separate confidence scoring phase.

## Phase 3: Output

### 3a: Console Summary

Print a brief summary to console:

```
## Changes Review
**Files Changed**: N | **Issues**: N (Critical: N, Important: N, Minor: N)

### Critical
- `file:line` — Issue title

### Important
- `file:line` — Issue title

### Minor
- `file:line` — Issue title
```

### 3b: Write REVIEW-CHANGES.md

Write `REVIEW-CHANGES.md` to project root with actionable checklist format:

```markdown
# Review: Uncommitted Changes
Generated: [date] | Files: N | Issues: N (Actionable: N)

## Actionable Checklist

### Critical
- [ ] **[Category]** `file:line` — Title
  Description (1-2 sentences: what + why it's a problem).
  Suggested fix: [concrete action]

### Important
- [ ] **[Category]** `file:line` — Title
  Description (1-2 sentences: what + why it's a problem).
  Suggested fix: [concrete action]

## Nice-to-Have
- Brief mention of minor/stylistic issues (no checkboxes)
```

**Categories:** `Code Quality`, `DRY/SoC`, `Best Practices`, `Conventions`, `Spec Alignment`, `Type Safety`, `Naming`

**What goes into Actionable:** bugs, DRY/SoC violations, code cleaning, quality improvements, high-confidence security issues. All Critical + Important issues.

**What goes into Nice-to-Have:** stylistic preferences, micro-optimizations, speculative issues. All Minor issues.

Each checklist item is 2-7 lines with: category tag, file location, title, description, and suggested fix.

If no issues found, write a minimal file noting clean review.
