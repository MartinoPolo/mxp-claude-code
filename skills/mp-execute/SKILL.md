---
name: mp-execute
description: Execute next task. Prompts for phase selection, delegates to executor agent.
disable-model-invocation: true
allowed-tools: Read, Write, Task, Bash, AskUserQuestion
---

# Execute Next Task

Execute a task by selecting a phase and delegating to the executor agent.

## Usage

```
/mp-execute           # Select phase, execute next task
```

## Workflow

### Step 1: Find Available Phases

1. Read `.claude/STATE.md` for overall status
2. Read `.claude/ROADMAP.md` for phase dependencies
3. Find all phase folders in `.claude/phases/`
4. For each phase, check:
   - Status from ROADMAP.md (Not Started / In Progress / Completed)
   - Dependencies from ROADMAP.md
   - Whether dependencies are satisfied (all dependency phases = Completed)

### Step 2: Prompt for Phase Selection

Use `AskUserQuestion` to let user choose which phase to work on.

**Rules:**
- Only offer phases whose dependencies are satisfied
- First option = first incomplete phase (Recommended)
- Next 3 options = next eligible phases
- "Other" allows manual phase number entry

**Example prompt:**
```
Question: "Which phase to execute?"
Header: "Phase"
Options:
  1. "Phase 1: Foundation (Recommended)" - "First incomplete phase, 3/10 tasks done"
  2. "Phase 2: Core API" - "Dependencies met, 0/8 tasks done"
  3. "Phase 3: UI Components" - "Dependencies met, 0/12 tasks done"
  4. "Phase 4: Integration" - "Blocked by Phase 2, 3"
```

**If only one phase available:** Skip prompt, proceed with that phase.

**If user selects "Other":** Parse phase number from input.

### Step 3: Find Next Task in Selected Phase

1. Read selected phase's `CHECKLIST.md`
2. Find first unchecked task (`- [ ]`)
3. Read phase's `SPEC.md` for context

### Step 4: Prepare Context for Agent

Gather essential context to pass to the executor agent:
- Project name and tech stack (from SPEC.md)
- Current phase name and objectives (from phase's SPEC.md)
- Task description
- Any relevant decisions (from global or phase STATE.md)

### Step 5: Delegate to Executor Agent

Use the Task tool to spawn a subagent:

```
Task tool:
  subagent_type: "mp-executor-agent"
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
       - Format: "phase-N: description"
    3. Mark task complete: change `- [ ]` to `- [x]` in phase CHECKLIST.md
    4. If you encounter blockers, document them and stop
    5. Report summary when done

    ## Working Directory
    [Current working directory]

    ## Important
    - Do NOT modify files outside the project scope
    - Do NOT skip the task without documenting why
    - Do NOT make architectural changes not in the spec
```

### Step 6: Handle Agent Response

When the agent completes (or stops due to blocker):

**On Success:**
1. Task is already marked complete by agent in phase's CHECKLIST.md
2. Check if all phase tasks are complete
3. If phase complete:
   - Update phase's STATE.md (Status = Completed)
   - Update `.claude/STATE.md` (global)
   - Update `.claude/ROADMAP.md` (Status column = Completed)
4. Report completion to user

**On Blocker:**
1. Update STATE.md:
   - Add blocker to Blockers section
   - Add session note in Session Handoff section
2. Report to user what happened and what's needed

### Step 7: Report Results

```
Task Completed: [Task Description]
Phase: N - [Phase Name]

Phase Progress: X/Y tasks complete
[If phase complete: "Phase N Complete!"]

Commits Made: N

Next Task:
  [] [Next task description]

Run `/mp-execute` to continue.
Run `/mp-project-status` for full progress overview.
```

## Error Handling

- **No phases found:** "No project found. Run `/mp-init-project` or `/mp-parse-spec` first."
- **All phases complete:** "All phases complete! Project finished."
- **No eligible phases:** "All remaining phases are blocked. Check dependencies in ROADMAP.md."
- **Agent fails:** Report error and suggest manual intervention

## Parallel Execution Note

Multiple `/mp-execute` commands can run in parallel on different phases if:
- The phases have no mutual dependencies
- Both phases' dependencies are already satisfied

Example: Phase 2 and Phase 3 can both run if they only depend on Phase 1 (completed).

## Notes

- The subagent gets fresh 200k context, preventing degradation
- Each task should be atomic and completable in one execution
- STATE.md provides continuity between tasks and sessions
- Agent commits after each task to preserve progress
- ROADMAP.md is the source of truth for phase completion status
