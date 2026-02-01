---
name: mp-execute
description: Execute next task. Finds current phase, delegates to executor agent.
disable-model-invocation: true
allowed-tools: Read, Write, Task, Bash
---

# Execute Next Task

Execute the next task by finding the current phase and delegating to the executor agent.

## Usage

```
/mp-execute           # Execute next task
```

## Workflow

### Step 1: Find Next Task

1. Read `.claude/STATE.md` for current phase
2. Find first incomplete phase folder (`.claude/phases/NN-name/`)
3. Read phase's `CHECKLIST.md`
4. Find first unchecked task (`- [ ]`)
5. Read phase's `SPEC.md` for context
6. Prepare context for executor agent

### Step 2: Prepare Context for Agent

Gather essential context to pass to the executor agent:
- Project name and tech stack (from SPEC.md)
- Current phase name and objectives (from phase's SPEC.md)
- Task description
- Any relevant decisions (from global or phase STATE.md)

### Step 3: Delegate to Executor Agent

Use the Task tool to spawn a subagent:

```
Task tool:
  subagent_type: "general-purpose"
  model: opus
  description: "Execute task: [task_name]"
  prompt: |
    You are an executor agent with fresh context.

    ## Project Context
    [Include relevant SPEC.md content]

    ## Your Mission
    Execute this task from Phase N: [Task Description]

    ## Task Details
    [Task description and any relevant context]

    ## Instructions
    1. Implement the task
    2. Commit after completing (use descriptive message)
       - Simple: "[section] description"
       - Complex: "phase-N: description"
    3. Mark task complete: change `- [ ]` to `- [x]`
    4. If you encounter blockers, document them and stop
    5. Report summary when done

    ## Working Directory
    [Current working directory]

    ## Important
    - Do NOT modify files outside the project scope
    - Do NOT skip the task without documenting why
    - Do NOT make architectural changes not in the spec
```

### Step 4: Handle Agent Response

When the agent completes (or stops due to blocker):

**On Success:**
1. Task is already marked complete by agent in phase's CHECKLIST.md
2. Check if all phase tasks are complete
3. If phase complete:
   - Update phase's STATE.md
   - Update `.claude/STATE.md` (global)
   - Update `.claude/ROADMAP.md`
   - Update `.claude/CHECKLIST.md` (mark phase complete)
4. Report completion to user

**On Blocker:**
1. Update STATE.md:
   - Add blocker to Blockers section
   - Add session note describing the issue
2. Report to user what happened and what's needed

### Step 5: Report Results

```
Task Completed: [Task Description]
Phase: N - [Phase Name]

Phase Progress: X/Y tasks complete
[If phase complete: "Phase N Complete! Ready for Phase N+1"]

Commits Made: N

Next Task:
  □ [Next task description]

Run `/mp-execute` to continue.
Run `/mp-project-status` for full progress overview.
```

## Error Handling

- **No CHECKLIST.md:** "No project found. Run `/mp-init-project` or `/mp-parse-spec` first."
- **All phases complete:** "All phases complete! Project finished."
- **Phase prerequisites not met:** "Phase N requires Phase M to be completed first."
- **Agent fails:** Report error and suggest manual intervention

## Notes

- The subagent gets fresh 200k context, preventing degradation
- Each task should be atomic and completable in one execution
- STATE.md provides continuity between tasks and sessions
- Agent commits after each task to preserve progress
