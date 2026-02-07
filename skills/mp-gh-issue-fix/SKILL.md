---
name: mp-gh-issue-fix
description: Investigate GitHub issue, analyze codebase, create fix plan, execute with approval
disable-model-invocation: true
allowed-tools: Read, Glob, Grep, Task, AskUserQuestion, Bash(gh issue *), Bash(git log *)
---

# Fix GitHub Issue

Investigate a GitHub issue, analyze the codebase, plan a fix, and execute with user approval.

## Usage

```
/mp-gh-issue-fix <issue-url>
/mp-gh-issue-fix https://github.com/owner/repo/issues/123
```

## Workflow

### Phase 1: Fetch Issue Data

Use `gh` CLI to retrieve issue details:

```bash
gh issue view <number> --repo owner/repo --json title,body,labels,comments,state
```

Parse and summarize:
- Title and description
- Labels (bug, feature, etc.)
- Key comments with context
- Linked PRs or issues

**If issue not found or auth fails:** Report error and stop.

### Phase 2: Explore Codebase

Spawn exploration agent to find relevant code:

```
Task tool:
  subagent_type: "Explore"
  model: haiku
  description: "Explore codebase for issue #N"
  prompt: |
    Find code relevant to this GitHub issue:

    **Issue:** [title]
    **Description:** [body summary]
    **Keywords:** [extracted keywords]

    Search for:
    1. Files matching keywords from issue
    2. Error messages or strings mentioned
    3. Related function/class names
    4. Test files that cover this area

    Return:
    - List of relevant files with brief descriptions
    - Key code snippets (with file:line references)
    - Observed patterns or conventions
```

### Phase 3: Analyze & Plan

Spawn analyzer agent to synthesize findings:

```
Task tool:
  subagent_type: "mp-gh-issue-analyzer"
  model: opus
  description: "Analyze issue #N and plan fix"
  prompt: |
    Analyze this GitHub issue and create a fix plan.

    ## Issue Data
    [Include fetched issue data]

    ## Codebase Exploration Results
    [Include exploration findings]

    ## Instructions
    Produce a structured analysis with:
    - Root cause analysis
    - Affected files with line references
    - Solution plan with specific steps
    - Testing checklist
    - Confidence assessment
```

### Phase 4: Execute Fix

Present plan to user and request approval:

```
AskUserQuestion:
  question: "Proceed with this fix plan?"
  header: "Execute"
  options:
    - label: "Execute (Recommended)"
      description: "Implement the fix plan"
    - label: "Modify plan"
      description: "Adjust the approach first"
    - label: "Cancel"
      description: "Do not implement"
```

**On approval:** Delegate to executor agent:

```
Task tool:
  subagent_type: "mpx-executor"
  model: opus
  description: "Fix issue #N"
  prompt: |
    Implement this fix for GitHub issue #N.

    ## Issue
    [title and summary]

    ## Fix Plan
    [Include the approved plan]

    ## Instructions
    1. Implement each step in the plan
    2. Run relevant tests to verify
    3. Commit with message: "fix(scope): description (fixes #N)"
    4. Report summary when done

    ## Constraints
    - Follow existing code patterns
    - Keep changes minimal and focused
    - Do NOT expand scope beyond the plan
```

**On modify:** Ask for changes, re-run Phase 3 with adjustments.

**On cancel:** End workflow.

## Output

After execution completes:

```
## Issue #N: [title]

**Status:** [Fixed / Partially Fixed / Blocked]

### Changes Made
- [file:line] - [what changed]

### Commits
- [commit hash] - [message]

### Testing
- [x] [test that passed]
- [ ] [test that needs manual verification]

### Next Steps
- [ ] Push changes: `git push`
- [ ] Close issue: `gh issue close N --repo owner/repo`
```

## Error Handling

| Error | Action |
|-------|--------|
| Issue not found | Report error, suggest checking URL |
| No relevant code found | Report findings, ask for hints |
| Plan confidence = Low | Ask user before proceeding |
| Execution fails | Report blocker, suggest manual fix |

## Optional: Library Docs

If the issue involves an external library, use Context7 for docs:

```
Task tool:
  description: "Fetch docs for [library]"
  prompt: "Get documentation for [library] focusing on [relevant API]"
```

Only fetch docs when issue clearly involves library-specific behavior.
