---
name: mp-review-branch
description: 'Multi-agent code review of current branch changes (read-only, no GitHub posting). Use when: "review branch", "review my changes", "code review"'
disable-model-invocation: true
allowed-tools: Read, Write, Glob, Grep, Bash(git status *), Bash(git log *), Bash(git diff *), Bash(git show *), Bash(git branch --list *), Bash(git branch --show-current *), Bash(git branch -r *), Bash(git branch -a *), Bash(git branch -v *), Bash(git remote -v *), Bash(git remote show *), Bash(git describe *), Bash(git blame *), Bash(git ls-files *), Bash(git ls-tree *), Bash(git rev-parse *), Bash(git rev-list *), Bash(git merge-base *), Bash(git shortlog *), Bash(git tag --list *), Bash(git tag -l *), Bash(git config --get *), Bash(git config --list *), Bash(git stash list *), Bash(git for-each-ref *), Bash(git cat-file *), Bash(git name-rev *)
metadata:
  author: MartinoPolo
  version: "0.1"
  category: code-review
---

# Branch Review

Perform a thorough multi-agent code review of all changes on the current branch. $ARGUMENTS

This review is **READ-ONLY**. It does NOT:
- Post to GitHub
- Modify any files
- Make commits

## Arguments

- No argument: Auto-detect base branch (asks user if multiple candidates found)
- Branch name: Compare against specific branch (e.g., `/mp-review-branch dev`)

## Phase 1: Discovery (Haiku Agent)

Launch a Haiku agent to gather context:

### 1a. Determine Base Branch

If $ARGUMENTS contains a branch name, use it as base. Otherwise:

1. Get all remote branches: `git branch -r --list`
2. Get current branch: `git branch --show-current`
3. Identify candidate base branches:
   - Check for `main`, `master`, `dev`, `develop` branches
   - Check parent branch: `git merge-base --fork-point origin/main HEAD`
   - Check tracking branch: `git rev-parse --abbrev-ref @{upstream}`
4. If only ONE candidate found → use it
5. If MULTIPLE candidates found → ask user which branch to compare against
6. Store the selected base branch for the review

### 1b. Gather Changes

1. Get all changed files: `git diff [base]...HEAD --name-only`
2. Get diff summary: `git diff [base]...HEAD --stat`
3. Identify the tech stack by examining:
   - package.json (Node/TypeScript/React)
   - Cargo.toml (Rust)
   - go.mod (Go)
   - requirements.txt/pyproject.toml (Python)
   - *.csproj (C#/.NET)
   - File extensions in changes
4. Check for CLAUDE.md files in the repo
5. Return: base branch, changed files list, detected tech stack, CLAUDE.md locations

## Phase 2: Parallel Review (6 Sonnet Agents)

Launch 6 parallel Sonnet agents. Each receives the changed files and tech stack info.

> **Full agent specifications:** See `references/review-agents.md`

Launch 6 parallel Sonnet agents covering: Tech Stack Best Practices, Security (OWASP), Performance, Error Handling & Reliability, Code Quality & CLAUDE.md, Spec/Plan Alignment.

## Phase 3: Confidence Scoring (Haiku Agents)

For each issue found, score confidence 0-100:

- **0-39 (Low)**: Might be false positive, stylistic preference
- **40-65 (Medium)**: Probably real, worth reviewing
- **66-80 (High)**: Verified real issue, should address
- **81-100 (Top)**: Definitely real, must fix before merge

## Phase 4: Output

### Output Format:

## Branch Review: [branch-name]
**Tech Stack**: [detected technologies]
**Files Changed**: N | **Base Branch**: [base]

### Issues Summary Table

| # | Issue | Category | Confidence | Location |
|---|-------|----------|------------|----------|
| 1 | Issue name | Category | Score | [`file:line`](file#L) |

### Top Priority (score > 80)
...

### High Priority (score 66-80)
...

### Medium Priority (score 40-65)
...

### Low Priority (score < 40)
...

### Summary
| Category | Top | High | Medium | Low |
|----------|-----|------|--------|-----|
| Security | N | N | N | N |
| Performance | N | N | N | N |
| Best Practices | N | N | N | N |
| Error Handling | N | N | N | N |
| Code Quality | N | N | N | N |
| Spec Alignment | N | N | N | N |

## Phase 5: Write REVIEW-BRANCH.md

Write `REVIEW-BRANCH.md` to project root with actionable checklist format.

Map confidence scores to severity: Top (>80) + High (66-80) → Critical/Important. Medium + Low → Nice-to-Have.

```markdown
# Review: [branch-name] vs [base-branch]
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
- Brief mention of medium/low confidence issues (no checkboxes)
```

**What goes into Actionable:** bugs, DRY/SoC violations, code cleaning, quality improvements, high-confidence security issues.
**What goes into Nice-to-Have:** stylistic preferences, micro-optimizations, speculative issues.

Each checklist item is 2-7 lines with: category tag, file location, title, description, and suggested fix.

---

**Note**: This review writes `REVIEW-BRANCH.md` but does not modify source files. To fix issues, use the checklist or ask Claude to fix specific issues.
