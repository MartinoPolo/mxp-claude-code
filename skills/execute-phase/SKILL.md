---
name: execute-phase
description: Execute phase N of a complex project. Use '/execute-phase 1' for phase 1. Delegates to phase-executor agent for fresh context.
disable-model-invocation: true
allowed-tools: Read, Write, Task, Bash
args: "[phase_number]"
---

# Execute Phase

Execute a specific phase of a complex project with context isolation via subagent delegation.

## Usage

```
/execute-phase 1      # Execute Phase 1
/execute-phase 2      # Execute Phase 2
/execute-phase        # Executes current/next incomplete phase
```

## Prerequisites

This skill is for **complex projects** only. Required files:
- `.claude/SPEC.md` - Project specification
- `.claude/STATE.md` - Current state tracking
- `.claude/ROADMAP.md` - Phase overview
- `.claude/phases/NN-phase-name.md` - Phase file to execute

## Workflow

### Step 1: Determine Phase Number

If phase number provided as argument, use it.
If no argument, read `.claude/STATE.md` to find:
1. Current incomplete phase, OR
2. Next phase after last completed

### Step 2: Validate Phase

Read the phase file (`.claude/phases/NN-phase-name.md`) and verify:
- Phase file exists
- Phase is not already completed
- Prerequisites are met (check STATE.md for completed phases)

If prerequisites not met:
> "Cannot execute Phase N. Phase M must be completed first.
> Current status: [from STATE.md]"

### Step 3: Prepare Context for Agent

Gather essential context to pass to the phase-executor agent:
- Project name and tech stack (from SPEC.md)
- Phase objectives and tasks (from phase file)
- Any relevant decisions (from STATE.md)

### Step 4: Delegate to Phase-Executor Agent

Use the Task tool to spawn a subagent:

```
Task tool:
  subagent_type: "general-purpose"
  description: "Execute phase N"
  prompt: |
    You are a phase-executor agent with fresh context.

    ## Project Context
    [Include relevant SPEC.md content]

    ## Your Mission
    Execute Phase N: [Phase Name]

    ## Phase Details
    [Include full phase file content]

    ## Instructions
    1. Work through each task in order
    2. Commit after completing each logical unit of work
       - Use commit message format: "phase-N: [description]"
    3. Mark tasks as complete in the phase file with [x]
    4. If you encounter blockers, document them and stop
    5. When all tasks complete, report summary

    ## Working Directory
    [Current working directory]

    ## Important
    - Do NOT modify files outside the project scope
    - Do NOT skip tasks without documenting why
    - Do NOT make architectural changes not in the spec
```

### Step 5: Handle Agent Response

When the agent completes (or stops due to blocker):

**On Success:**
1. Update `.claude/STATE.md`:
   - Mark phase as completed
   - Update progress percentages
   - Add session note with completion date
2. Update `.claude/ROADMAP.md`:
   - Change phase status to "Completed"
3. Update `.claude/CHECKLIST.md`:
   - Mark phase checkbox as complete

**On Blocker:**
1. Update `.claude/STATE.md`:
   - Add blocker to Blockers section
   - Add session note describing the issue
2. Report to user what happened and what's needed

### Step 6: Report Results

```
Phase N: [Name] - Completed!

Tasks Completed: X/Y
Commits Made: N
Time: [duration if available]

Files Modified:
  - [list of files]

Next Phase: Phase M - [Name]
  Run `/execute-phase M` to continue.

Or run `/project-status` for full progress overview.
```

## Error Handling

- **Phase file not found:** "Phase N doesn't exist. Available phases: [list]"
- **Already completed:** "Phase N is already completed. Run `/execute-phase N+1` for next phase."
- **Prerequisites not met:** "Phase N requires Phase M to be completed first."
- **Agent fails:** Report error and suggest manual intervention

## Notes

- The subagent gets fresh 200k context, preventing degradation
- Each phase should be self-contained enough to execute independently
- STATE.md provides continuity between phases and sessions
- Agent commits frequently to preserve progress
