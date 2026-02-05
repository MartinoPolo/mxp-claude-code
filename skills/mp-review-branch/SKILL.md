---
name: mp-review-branch
description: Multi-agent code review of current branch changes (read-only, no GitHub posting)
disable-model-invocation: true
allowed-tools: Read, Glob, Grep, Bash(git status *), Bash(git log *), Bash(git diff *), Bash(git show *), Bash(git branch --list *), Bash(git branch --show-current *), Bash(git branch -r *), Bash(git branch -a *), Bash(git branch -v *), Bash(git remote -v *), Bash(git remote show *), Bash(git describe *), Bash(git blame *), Bash(git ls-files *), Bash(git ls-tree *), Bash(git rev-parse *), Bash(git rev-list *), Bash(git merge-base *), Bash(git shortlog *), Bash(git tag --list *), Bash(git tag -l *), Bash(git config --get *), Bash(git config --list *), Bash(git stash list *), Bash(git for-each-ref *), Bash(git cat-file *), Bash(git name-rev *)
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

## Phase 2: Parallel Review (5 Sonnet Agents)

Launch 5 parallel Sonnet agents. Each receives the changed files and tech stack info.

### Agent 1: Tech Stack Best Practices
Based on detected tech stack, check for:

**TypeScript/JavaScript:** Strict mode, proper typing, no `any` abuse, modern ES features, async/await patterns

**React:** Hooks rules, key props, effect cleanup, memoization, side effect abuse (useEffect for derived state)

**Solid.js:** Signal usage, createMemo vs createEffect, Show/For/Switch components, onCleanup

**Svelte:** Reactive declarations, store subscriptions, lifecycle, unnecessary reactivity

**Node.js:** Async patterns, stream handling, error propagation, env handling

**Python:** Type hints, PEP 8, context managers, exception patterns

**Go:** Error handling, goroutine leaks, interface usage

**Rust:** Ownership, Result/Option, unsafe usage

### Agent 2: Security Review (OWASP Focus)
- SQL/NoSQL injection
- XSS (Cross-Site Scripting)
- Command injection
- Path traversal
- CSRF vulnerabilities
- Auth/authz issues
- Secrets exposure
- Sensitive data in logs
- Input validation gaps

### Agent 3: Performance Analysis
- N+1 query patterns
- Unnecessary re-renders
- Memory leaks
- Bundle size impact
- Expensive operations in hot paths
- Inefficient algorithms

### Agent 4: Error Handling & Reliability
- Try/catch usage
- Error boundary patterns
- Graceful degradation
- User-facing error messages
- Retry patterns
- Timeout handling
- Race conditions

### Agent 5: Code Quality & CLAUDE.md
- DRY violations
- Cyclomatic complexity
- Naming conventions
- Type safety
- Edge cases
- Test coverage gaps
- CLAUDE.md compliance
- Overcomplicated code - over-abstraction, premature optimization, convoluted logic, excessive indirection, feature creep beyond requirements

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

---

**Note**: This review is read-only. To fix issues, copy the suggested changes and apply them manually, or ask Claude to fix specific issues in a separate conversation.
