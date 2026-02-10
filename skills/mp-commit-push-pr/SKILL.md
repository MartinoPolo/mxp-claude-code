---
name: mp-commit-push-pr
description: Full workflow - commit, push, and create draft PR
allowed-tools: Bash(git *), Bash(gh pr create *)
---

# Commit, Push, and Create PR

Full workflow: stage → commit → push → create draft PR. $ARGUMENTS

## Workflow

### Step 1: Check Status

```bash
git status
git diff --stat
```

### Step 2: Stage Changes

```bash
git add <specific-files>
```

Prefer specific files over `git add -A`.

### Step 3: Commit

```bash
git commit -m "$(cat <<'EOF'
type(scope): Description

Optional body with details
EOF
)"
```

**Commit Rules:**

- Conventional commit format: `type(scope): description`
- Types: feat, fix, refactor, chore, docs, style, test, perf, ci, build
- No AI attribution (no "Co-authored-by: Claude" or similar)
- Focus on "why" over "what"

### Step 4: Push

```bash
git push -u origin $(git branch --show-current)
```

### Step 5: Create Draft PR

**PR Rules:**

- **Always draft**: Use `--draft` flag
- **No AI attribution**: Never include AI co-authorship

**Title Format:** `type(scope): Description`

**Description Template:**

```
## Changes
- [bullet point 1]
- [bullet point 2]

## Why
[business or technical reason]
```

**Command:**

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

After completion, display:

- Commit hash and message
- Push status
- PR URL and number
- Draft status confirmation
