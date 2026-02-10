---
name: mp-pr-create
description: Create draft PR from existing commits (no commit/push)
allowed-tools: Bash(gh pr create *), Bash(git status *), Bash(git log *), Bash(git diff *), Bash(git branch *)
---

# Create Pull Request

Create a draft PR from existing commits on current branch. $ARGUMENTS

## Prerequisites

- Branch has commits ahead of base branch
- Changes already pushed to remote

## Workflow

1. Get current branch: `git branch --show-current`
2. Get base branch: `git rev-parse --abbrev-ref origin/HEAD` or default to `main`
3. Review commits: `git log origin/main..HEAD --oneline`
4. Review changes: `git diff origin/main..HEAD --stat`
5. Create draft PR with `gh pr create`

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
gh pr create --draft --title "type(scope): Description" --body "$(cat <<'EOF'
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
- PR URL
- PR number
- Title
- Draft status confirmation
