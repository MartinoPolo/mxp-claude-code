### Step 5: Delegate to Executor Agent

**Single-task prompt** (for `next` mode):

```
Task tool:
  subagent_type: "mpx-executor"
  model: opus
  description: "Execute task: [task_name]"
  prompt: |
    You are an executor agent with fresh context.

    ## Project Context
    [Include relevant content from CHECKLIST.md header: Objective, Scope, Out of Scope]

    [If HANDOFF.md context was captured in Step 1.5:]
    ## Session Handoff Context
    [Include HANDOFF.md content — previous session's progress, decisions, issues, working memory]

    ## Your Mission
    Execute this task from Phase N: [Task Description]

    ## Task Details
    [Full task line + indented spec paragraph from CHECKLIST.md]

    ## Instructions
    Follow your standard execution process (understand, implement, verify, commit, report).
    Update this phase's CHECKLIST.md when tasks complete.

    ## Working Directory
    [Current working directory]
```

**Batch prompt** (for default/`all` mode, 1-3 tasks per batch):

```
Task tool:
  subagent_type: "mpx-executor"
  model: opus
  description: "Execute batch: [section_name] (N tasks)"
  prompt: |
    You are an executor agent with fresh context.

    ## Project Context
    [Include relevant content from CHECKLIST.md header: Objective, Scope, Out of Scope]

    [If HANDOFF.md context was captured in Step 1.5:]
    ## Session Handoff Context
    [Include HANDOFF.md content — previous session's progress, decisions, issues, working memory]

    ## Your Mission
    Execute these tasks from Phase N, section "[Section Name]":

    ## Tasks (execute in order)
    1. [Full task line + indented spec paragraph from CHECKLIST.md]
    2. [Full task line + indented spec paragraph from CHECKLIST.md]
    3. [Full task line + indented spec paragraph from CHECKLIST.md]

    ## Instructions
    - Execute all tasks in order
    - Follow your standard execution process for each (understand, implement, verify)
    - Update this phase's CHECKLIST.md as each task completes
    - Make a single commit covering all tasks in this batch
    - Commit message: `feat(phase-N): [brief description of batch work]`
    - If a task fails, complete remaining tasks if possible and report which failed
    - Report results for each task: ✅ completed / ❌ failed (reason)

    ## Working Directory
    [Current working directory]
```
