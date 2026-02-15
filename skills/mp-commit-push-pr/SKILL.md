---
name: mp-commit-push-pr
description: Full workflow - commit, push, and create draft PR
allowed-tools: Bash(git *), Bash(gh pr create *), Task
---

# Commit, Push, and Create PR

Full workflow: stage → commit → push → detect base → create draft PR. $ARGUMENTS

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

### Step 5: Detect Base Branch

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

### Step 6: Find Linked Issue

Spawn `mp-gh-issue-finder` agent (via Task tool, subagent_type `mp-gh-issue-finder`, model haiku) with:
- Repo: detect from `git remote get-url origin`
- Branch name: current branch
- Commit messages: from Step 2/3 output
- Diff summary: from Step 1 diff stat output

**Based on result:**
- **High confidence match** → add `Closes #N` to PR body
- **Candidates returned** → ask user with `AskUserQuestion` which (if any) to link
- **No match** → proceed without linking

### Step 7: Create Draft PR

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

After completion, display:

- Commit hash and message
- Push status
- Base branch used
- PR URL and number
- Draft status confirmation
- **Session Activity:** list agents dispatched (e.g. `mp-gh-issue-finder (haiku) — Find linked issue`)
