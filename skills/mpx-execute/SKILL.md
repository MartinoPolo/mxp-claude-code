---
name: mpx-execute
description: Execute tasks. Prompts for phase, then choose full-phase or single-task execution mode.
disable-model-invocation: true
allowed-tools: Read, Write, Task, Bash, AskUserQuestion, Glob
---

# Execute Tasks

Execute tasks by selecting a phase and choosing between full-phase or single-task execution mode.

## Usage

```
/mpx-execute           # Select phase, choose execution mode
```

## Workflow

### Step 1: Find Available Phases

1. Read `.mpx/ROADMAP.md` for overall status and phase dependencies
2. Find all phase folders in `.mpx/phases/`
3. For each phase, check:
   - Status from ROADMAP.md (Not Started / In Progress / Completed)
   - Dependencies from ROADMAP.md
   - Whether dependencies are satisfied (all dependency phases = Completed)

### Step 1.5: Check for HANDOFF.md

HANDOFF.md may not exist if `/mpx-handoff` was not run. This is normal — proceed without handoff context.

1. Check if active phase folder has `HANDOFF.md` (phase handoff)
2. If exists, read it and store the context for inclusion in the executor prompt
3. Delete the HANDOFF.md file after reading — it is ephemeral, single-use
4. If not found, skip — no handoff context needed

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

### Step 3: Prompt for Execution Mode

Count remaining unchecked tasks (`- [ ]`) in the selected phase's CHECKLIST.md.

**If only 1 task remaining:** Skip prompt, execute it directly.

**If multiple tasks remaining:** Use `AskUserQuestion`:

```
Question: "How do you want to execute Phase N?"
Header: "Mode"
Options:
  1. "Execute entire phase (N remaining tasks) (Recommended)" - "Run all tasks sequentially with review after each"
  2. "Execute next task only" - "Run single task then stop"
```

### Step 4: Execute — Task Mode

For single-task execution:

1. Read selected phase's `CHECKLIST.md`
2. Find first unchecked task (`- [ ]`) — task text includes inline spec paragraph
3. Delegate to executor (Step 5)
4. Run reviews (Steps 5.5 + 5.6)
5. Report results (Step 7)

### Step 4: Execute — Phase Mode

For full-phase execution:

1. Read selected phase's `CHECKLIST.md`
2. Collect all unchecked tasks (`- [ ]`) — each includes inline spec paragraph
3. Initialize tracking: `completed = []`, `failed = []`, `skipped = []`

**For each unchecked task sequentially:**
a. Delegate to executor (Step 5)
b. Run spec compliance review (Step 5.5)
c. Run code quality review (Step 5.6)
d. **On success (both reviews pass):** Add to `completed[]`, continue to next task
e. **On failure/blocker:** Report issue to user, ask fix/skip: - **Fix:** Re-dispatch executor with specific issues, re-review, loop until pass - **Skip:** Add to `skipped[]`, continue to next task - **Stop:** Halt phase execution, report partial progress
f. Continue to next task regardless of previous task outcome

After all tasks processed: Go to Step 7 (phase summary report).

### Step 5: Delegate to Executor Agent

Use the Task tool to spawn a subagent:

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
    1. Implement the task
    2. Commit after completing (use descriptive message)
       - Format: "type(scope): description"
    3. Mark task complete: change `- [ ]` to `- [x]` in phase CHECKLIST.md
    4. If you made significant decisions, add them to the Decisions section in CHECKLIST.md
    5. If you encounter blockers, document them in the Blockers section and stop
    6. Report summary when done

    ## Working Directory
    [Current working directory]

    ## Important
    - Do NOT modify files outside the project scope
    - Do NOT skip the task without documenting why
    - Do NOT make architectural changes not in the spec
```

### Step 5.5: Stage 1 — Spec Compliance Review

After executor reports back, dispatch a spec compliance reviewer (Sonnet agent):

```
Task tool:
  subagent_type: "general-purpose"
  model: sonnet
  description: "Review spec compliance for: [task_name]"
  prompt: |
    You are reviewing whether an implementation matches its specification.

    ## What Was Requested
    [FULL TEXT of task line + spec paragraph from CHECKLIST.md]

    ## What Implementer Claims They Built
    [Executor's report summary]

    ## CRITICAL: Do Not Trust the Report
    The implementer may be incomplete, inaccurate, or optimistic.
    Verify everything independently by reading actual code.

    DO NOT: Take their word, trust claims about completeness, accept their interpretation
    DO: Read actual code, compare to requirements line by line, check for missing pieces

    ## Check For

    **Missing requirements:**
    - Everything requested actually implemented?
    - Requirements skipped or missed?
    - Claims something works but didn't actually implement it?

    **Extra/unneeded work:**
    - Built things not requested? (YAGNI violations)
    - Over-engineered or added unnecessary features?

    **Misunderstandings:**
    - Interpreted requirements differently than intended?
    - Solved the wrong problem?

    ## Report
    - ✅ Spec compliant (everything matches after code inspection)
    - ❌ Issues: [list what's missing/extra with file:line references]
```

**If spec reviewer reports ❌:**

1. Report issues to user
2. Ask: fix now or skip?
3. If fix: re-dispatch executor with specific issues to fix, then re-review
4. Loop until ✅ or user says skip

### Step 5.6: Stage 2 — Code Quality Review

Only after spec compliance passes (✅). Dispatch code quality reviewer (Sonnet agent):

```
Task tool:
  subagent_type: "general-purpose"
  model: sonnet
  description: "Review code quality for: [task_name]"
  prompt: |
    You are reviewing code quality of a task implementation.

    ## What Was Implemented
    [Executor's report]

    ## Files Changed
    Run `git diff HEAD~1 --name-only` to see changed files.
    Run `git diff HEAD~1` to see the full diff.

    ## Review Checklist
    - Code patterns match existing codebase?
    - Error handling adequate?
    - Naming clear and descriptive?
    - No DRY violations?
    - No tight coupling?
    - Tests verify real behavior?
    - No security issues (injection, XSS, secrets)?
    - No performance issues (N+1, memory leaks)?
    - CLAUDE.md/project conventions followed?

    ## Report
    - Strengths: [what's good]
    - Issues (Critical): [must fix — blocks completion]
    - Issues (Important): [should fix]
    - Issues (Minor): [nice to have]
    - Assessment: APPROVED / NEEDS CHANGES
```

**If reviewer reports NEEDS CHANGES with Critical issues:**

1. Report to user
2. Ask: fix now or skip?
3. If fix: re-dispatch executor, then re-review
4. Loop until APPROVED or user says skip

**Important/Minor issues:** Report to user but don't block completion.

### Step 6: Handle Reviewed Results

After both review stages pass for a task:

**On Success (both reviews ✅/APPROVED):**

1. Task marked complete by agent in phase CHECKLIST.md
2. Check if all phase tasks complete
3. If phase complete: check phase checkbox in ROADMAP.md (`- [ ]` → `- [x]`)
4. Report completion + review summaries to user

**On Blocker:**

1. Update Blockers section in phase CHECKLIST.md
2. Report to user

### Step 7: Report Results

**Task mode report:**

```
Task Completed: [Task Description]
Phase: N - [Phase Name]

Phase Progress: X/Y tasks complete
[If phase complete: "Phase N Complete!"]

Commits Made: N

Next Task:
  [] [Next task description]

Run `/mpx-execute` to continue.
Run `/mpx-show-project-status` for full progress overview.
```

**Phase mode report:**

```
Phase N Execution Summary: [Phase Name]

Results:
  ✅ Completed: X tasks
  ❌ Failed:    Y tasks
  ⏭️ Skipped:   Z tasks

Task Details:
  ✅ [Task 1 description]
  ✅ [Task 2 description]
  ❌ [Task 3 description] — [failure reason]
  ✅ [Task 4 description]

Phase Progress: X/Y tasks complete
[If phase complete: "Phase N Complete!"]
[If failed tasks exist: "Failed tasks may need manual intervention or re-execution."]

Commits Made: N

Run `/mpx-execute` to continue with next phase.
Run `/mpx-show-project-status` for full progress overview.
```

## Error Handling

- **No phases found:** "No project found. Run `/mpx-init-project` or `/mpx-parse-spec` first."
- **All phases complete:** "All phases complete! Project finished."
- **No eligible phases:** "All remaining phases are blocked. Check dependencies in ROADMAP.md."
- **Agent fails:** Report error, record in `failed[]` (phase mode) or suggest manual intervention (task mode)

## Parallel Execution Note

Multiple `/mpx-execute` commands can run in parallel on different phases if:

- The phases have no mutual dependencies
- Both phases' dependencies are already satisfied

Example: Phase 2 and Phase 3 can both run if they only depend on Phase 1 (completed).

## Notes

- The subagent gets fresh 200k context, preventing degradation
- Each task should be atomic and completable in one execution
- CHECKLIST.md is the single source of truth per phase (specs + tasks + state)
- Agent commits after each task to preserve progress
- ROADMAP.md is the source of truth for phase completion status
- Phase mode continues on failure — all tasks get attempted
- Two-stage review runs after EVERY task, even in phase mode
- HANDOFF.md is ephemeral — read once at start, then deleted
