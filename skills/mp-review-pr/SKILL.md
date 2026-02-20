---
name: mp-review-pr
description: 'Multi-agent PR review with confidence scoring (works on drafts, read-only). Use when: "review PR #N", "review pull request"'
disable-model-invocation: true
allowed-tools: Read, Write, Glob, Grep, Bash(git status *), Bash(git log *), Bash(git diff *), Bash(git show *), Bash(git branch --list *), Bash(git branch --show-current *), Bash(git branch -r *), Bash(git branch -a *), Bash(git rev-parse *), Bash(git merge-base *), Bash(gh pr list *), Bash(gh pr view *), Bash(gh pr diff *), Bash(gh pr status *), Bash(gh pr checks *), Bash(gh issue list *), Bash(gh issue view *), Bash(gh repo view *), Bash(gh run list *), Bash(gh run view *), Bash(gh search *)
metadata:
  author: MartinoPolo
  version: "0.1"
  category: code-review
---

# PR Review

Perform a thorough multi-agent code review of the specified pull request. $ARGUMENTS

This review is **READ-ONLY**. It does NOT:
- Post comments to GitHub
- Modify any files
- Approve or request changes

**Works on draft PRs** - unlike built-in /code-review.

## Usage

```
/mp-review-pr 123        # Review PR #123
/mp-review-pr            # Review PR for current branch
```

## Phase 1: Fetch PR (Haiku Agent)

1. Get PR details: `gh pr view $ARGUMENTS --json number,title,state,isDraft,baseRefName,headRefName,body,additions,deletions,changedFiles`
2. Get the diff: `gh pr diff $ARGUMENTS`
3. List changed files: `gh pr view $ARGUMENTS --json files --jq '.files[].path'`
4. Do NOT skip if draft - review it anyway
5. Detect tech stack from changed files and repo structure
6. Find CLAUDE.md files

## Phase 2: Parallel Review (6 Sonnet Agents)

Launch 6 parallel Sonnet agents. Each receives the PR diff, changed files, and tech stack info.

> **Full agent specifications:** See `references/review-agents.md`

Launch 6 parallel Sonnet agents covering: Tech Stack Best Practices, Security (OWASP), Performance, Error Handling & Reliability, Code Quality & CLAUDE.md, Spec/Plan Alignment.

## Phase 3: Confidence Scoring (Haiku Agents)

Score each issue 0-100:
- **0-39 (Low)**: Stylistic, minor
- **40-65 (Medium)**: Worth reviewing
- **66-80 (High)**: Should address
- **81-100 (Top)**: Must fix

## Phase 4: Output

## PR Review: #[number] - [title]
**Status**: [Ready/Draft] | **Base**: [base] → **Head**: [head]
**Tech Stack**: [detected]
**Changes**: +[additions] / -[deletions] in [changedFiles] files

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

**Overall Risk**: [Low/Medium/High/Critical]
**Ready to Merge**: [Yes/No - reasons]

## Phase 5: Write REVIEW-PR.md

Write `REVIEW-PR.md` to project root with actionable checklist format.

Map confidence scores to severity: Top (>80) + High (66-80) → Critical/Important. Medium + Low → Nice-to-Have.

```markdown
# Review: PR #[number] — [title]
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

**Note**: This review writes `REVIEW-PR.md` but does not modify source files or post to GitHub. To apply fixes, use the checklist or ask Claude to fix specific issues.
