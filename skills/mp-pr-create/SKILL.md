---
name: mp-pr-create
description: Create draft PR from existing commits (no commit/push)
allowed-tools: Bash(gh pr create *), Bash(git status *), Bash(git log *), Bash(git diff *), Bash(git branch *), Bash(git rev-parse *), Bash(git merge-base *), Bash(git rev-list *), Bash(git remote *), Task
---

# Create Pull Request

Create a draft PR from existing commits on current branch. $ARGUMENTS

## Prerequisites

- Branch has commits ahead of base branch
- Changes already pushed to remote

## Workflow

### Step 1: Detect Base Branch

If `$ARGUMENTS` specifies a base branch, use it. Otherwise detect automatically:

1. Get current branch: `git branch --show-current`
2. List remote branches: `git branch -r --list`
3. Build candidate list from existing remote branches, priority order: `dev` > `develop` > `main` > `master`
4. For each candidate, test: `git merge-base --fork-point origin/<candidate> HEAD`
   - **One valid** → use it
   - **Multiple valid** → count `git rev-list --count <merge-base>..HEAD` for each, pick closest (fewest commits). Tie → prefer priority order
   - **None valid** → fallback: `git merge-base origin/<candidate> HEAD` for each, pick closest
5. **Still ambiguous / no candidates** → ask user with `AskUserQuestion`
6. Display detected base branch before proceeding

### Step 2: Review Changes

```bash
git log origin/<detected-base>..HEAD --oneline
git diff origin/<detected-base>..HEAD --stat
```

### Step 3: Find Linked Issue

Spawn `mp-gh-issue-finder` agent (via Task tool, subagent_type `mp-gh-issue-finder`, model haiku) with:
- Repo: detect from `git remote get-url origin`
- Branch name: current branch
- Commit messages: from Step 2 log output
- Diff summary: from Step 2 diff stat output

**Based on result:**
- **High confidence match** → add `Closes #N` to PR body
- **Candidates returned** → ask user with `AskUserQuestion` which (if any) to link
- **No match** → proceed without linking

### Step 4: Create Draft PR

Create draft PR with `gh pr create` using detected base.

## PR Rules

### Critical
- **Always draft**: Use `--draft` flag

### Title Format
`type(scope): Description`

### Description Template
```
## Changes
- [bullet point 1]
- [bullet point 2]

## Why
[business or technical reason for the change]
```

## Command

```bash
gh pr create --draft --base <detected-base> --title "type(scope): Description" --body "$(cat <<'EOF'
## Changes
- Change 1
- Change 2

## Why
Reason for the change
EOF
)"
```

## Output

After creating PR, display:
- Base branch used
- PR URL
- PR number
- Title
- Draft status confirmation
- **Session Activity:** list agents dispatched (e.g. `mp-gh-issue-finder (haiku) — Find linked issue`)
