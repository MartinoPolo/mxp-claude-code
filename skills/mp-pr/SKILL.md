---
name: mp-pr
description: 'Create or update draft PR from existing commits. Use when: "create PR", "open pull request", "make a PR", "update PR"'
allowed-tools: Bash(gh pr *), Bash(git status *), Bash(git log *), Bash(git diff *), Bash(git branch *), Bash(git rev-parse *), Bash(git merge-base *), Bash(git rev-list *), Bash(git remote *), Task
metadata:
  author: MartinoPolo
  version: "0.1"
  category: git-workflow
---

# Create or Update Pull Request

Create or update a draft PR from existing commits on current branch. $ARGUMENTS

## Workflow

### Step 1: Detect Base Branch

Spawn `mp-base-branch-detector` agent (via Task tool, subagent_type `mp-base-branch-detector`, model haiku) with:
- Explicit base branch from `$ARGUMENTS` (if provided)
- Remote branches: output of `git branch -r`

**Based on result:**
- **Branch returned** → use it, display to user
- **Null with candidates** → ask user with `AskUserQuestion` to pick from candidates
- **Null without candidates** → ask user with `AskUserQuestion` to specify manually

### Step 2: Review Changes

```bash
git log origin/<base>..HEAD --oneline
git diff origin/<base>..HEAD --stat
```

### Step 3: Find Linked Issue

Spawn `mp-gh-issue-finder` agent (via Task tool, subagent_type `mp-gh-issue-finder`, model haiku) with:
- Repo: detect from `git remote get-url origin`
- Branch name: current branch
- Commit messages: from commit log output
- Diff summary: from diff stat output

**Based on result:**
- **High confidence match** → add `Closes #N` to PR body
- **Candidates returned** → ask user with `AskUserQuestion` which (if any) to link
- **No match** → proceed without linking

### Step 4: Check Existing PR

```bash
gh pr view --json number,title,body,url,state 2>/dev/null
```

- **OPEN PR exists** → edit mode (Step 5a)
- **No PR or not OPEN** → create mode (Step 5b)

### Step 5a: Update Existing PR

```bash
gh pr edit --title "type(scope): Description" --body "$(cat <<'EOF'
PR body here
EOF
)"
```

### Step 5b: Create Draft PR

```bash
gh pr create --draft --base <base> --title "type(scope): Description" --body "$(cat <<'EOF'
PR body here
EOF
)"
```

## PR Rules

### Title

`type(scope): Description` — conventional commit format

### Description

Review ALL commits `origin/<base>..HEAD`. Write 1-6 concise bullets summarizing full scope of changes. No section headers. Include reasoning inline where non-obvious.

```
- Extract base branch detection into reusable agent (was duplicated across 3 skills)
- Add existing PR check to avoid duplicate PRs on repeated runs

Closes #42
```

### Critical

- **Always draft** on create (`--draft` flag)
- **No AI attribution**: Never include AI co-authorship

## Output

After completion, display:

- Base branch used
- PR URL and number
- Whether created or updated
- **Session Activity:** list agents dispatched
