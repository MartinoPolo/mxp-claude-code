---
name: mpx-execute
description: 'Execute tasks autonomously. Auto-selects phase and scope, only asks when genuinely unsure. Use when: "execute phase", "run tasks", "start building"'
args: "[phase N | all | task]"
disable-model-invocation: true
allowed-tools: Read, Write, Task, Bash, AskUserQuestion, Glob
metadata:
  author: MartinoPolo
  version: "0.1"
  category: project-management
---

# Execute Tasks

Autonomously execute tasks — auto-selects the next eligible phase and executes all remaining tasks in batches.

## Usage

```
/mpx-execute           # Execute entire phase in batches
/mpx-execute phase 3   # Target specific phase
/mpx-execute task      # Force single task execution
/mpx-execute all       # Same as default (entire phase)
```

## Examples

**User says:** "/mpx-execute"
**Actions:** Auto-select next eligible phase, group tasks into batches, execute sequentially
**Result:** Full phase completed with batch commits and wrap-up review

**User says:** "/mpx-execute task"
**Actions:** Find first unchecked task in current phase, execute single task
**Result:** One task completed and checked off in CHECKLIST.md

**User says:** "/mpx-execute phase 3"
**Actions:** Target phase 3 specifically, verify dependencies met, execute all tasks
**Result:** Phase 3 completed (or partial with failure report)

## Workflow

### Step 1: Find Available Phases

1. Read `.mpx/ROADMAP.md` for overall status and phase dependencies
2. Find all phase folders in `.mpx/phases/`
3. For each phase, check:
   - Status from ROADMAP.md (Not Started / In Progress / Completed)
   - Dependencies from ROADMAP.md
   - Whether dependencies are satisfied (all dependency phases = Completed)

### Step 1.5: Check for HANDOFF.md

HANDOFF.md may not exist if `/mp-handoff` was not run. This is normal — proceed without handoff context.

1. Check if project root has `HANDOFF.md`
2. If exists, read it and store the context for inclusion in the executor prompt
3. Delete the HANDOFF.md file after reading — it is ephemeral, single-use
4. If not found, skip — no handoff context needed

### Step 2: Auto-Select Phase

Determine which phase to execute without prompting.

**Logic:**

1. Collect all non-completed phases whose dependencies are satisfied
2. Sort by phase number ascending
3. Pick the lowest — this is almost always correct

**If user passed `phase N` arg:** Use that phase instead (validate its dependencies are satisfied; error if blocked).

**Edge cases:**

- No phases found → error: "No project found. Stop and suggest running `/mpx-setup`"
- All phases complete → done: "All phases complete! Project finished."
- All remaining phases blocked → error: "All remaining phases are blocked. Check dependencies in ROADMAP.md."

**Log:** `Auto-selected Phase N: [Name] (X remaining tasks)`

### Step 3: Batch Grouping

Read selected phase's `CHECKLIST.md`. Collect all unchecked tasks (`- [ ]`).

**If `task` arg:** Single task mode — take only the first unchecked task, skip to Step 4 (single task).

**Default / `all` arg:** Group unchecked tasks into batches:

1. Group tasks by their `### Section` heading in CHECKLIST.md
2. Each batch = tasks under the same section heading, max 3 tasks per batch
3. If a section has >3 tasks, split into multiple batches of 1-3
4. Preserve task order within and across batches

**Log:** `Scope: N tasks in M batches — executing entire phase`

### Step 4: Execute — Single Task

For `task` mode only:

1. Find first unchecked task (`- [ ]`) — task text includes inline spec paragraph
2. Delegate to executor (Step 5, single-task prompt)
3. Report results (Step 7)

### Step 4: Execute — Batch Loop

For default/`all` mode:

1. Initialize tracking: `completed = []`, `failed = []`, `skipped = []`

**For each batch sequentially:**

a. Delegate to executor (Step 5, batch prompt with 1-3 tasks)
b. **On success:** Add tasks to `completed[]`, continue to next batch
c. **On failure/blocker:** Report issue to user, ask fix/skip/stop:
   - **Fix:** Re-dispatch executor with specific issues, loop until pass
   - **Skip:** Add failed tasks to `skipped[]`, continue to next batch
   - **Stop:** Halt execution, report partial progress
d. Continue to next batch regardless of previous batch outcome

After all batches processed → check if phase complete → Step 6.5 if yes, else Step 7.

### Agent Tracking

Track every Task tool dispatch throughout execution: agent type, model, purpose, result (✅/❌). Use this data for Step 7 report.

### Step 5: Delegate to Executor Agent

> **Full prompt templates:** See `references/agent-prompts.md`

Spawn `mpx-executor` agent (model: opus) with project context from CHECKLIST.md header + handoff context (if any) + task details. Single-task mode sends one task; batch mode sends 1-3 tasks grouped by section.

### Step 6: Track Batch Results

After executor returns for each batch:

1. Parse executor report — which tasks completed, which failed
2. Update tracking arrays (`completed[]`, `failed[]`, `skipped[]`)
3. If all phase tasks complete → proceed to Step 6.5 (phase wrap-up review)
4. If batches remain → continue to next batch
5. If all batches done but phase incomplete → proceed to Step 7

**On Blocker:**

1. Update Blockers section in phase CHECKLIST.md
2. Report to user

**Important:** Do NOT mark the phase complete in ROADMAP.md here. That happens in Step 6.5 after the wrap-up review passes.

### Step 6.5: Phase Wrap-Up Review

**Trigger:** ALL tasks in the current phase are complete (no unchecked `- [ ]` tasks remain).

If the phase is not fully complete, skip this step entirely.

**Model selection:**
- Phase had **3+ tasks** → spawn with `model: opus`
- Phase had **1-2 tasks** → spawn with `model: sonnet`

**6.5a: Code quality review — dispatch the phase reviewer:**

```
Task tool:
  subagent_type: "mpx-phase-reviewer"
  model: [opus or sonnet per above]
  description: "Phase N wrap-up review"
  prompt: |
    Review the completed Phase N: [Phase Name].

    ## Phase CHECKLIST.md
    [Full content of the phase's CHECKLIST.md]

    ## Instructions
    1. Run `git diff` for commits made during this phase to see full diff
    2. **Spec compliance check** — for each completed task:
       - Read the task's spec paragraph from CHECKLIST.md
       - Read the actual implementation code
       - Verify implementation matches spec: all requirements met, nothing missing
       - Flag YAGNI violations (built things not requested)
       - Flag misunderstandings (solved wrong problem, misinterpreted requirements)
    3. Flag which docs need updates (AGENTS.md, CLAUDE.md, README.md) — do NOT update them
    4. Verify mxp tracking accuracy (CHECKLIST.md decisions, ROADMAP.md status) — flag discrepancies, do NOT fix them
    5. Assess cross-task integration and pattern consistency
    6. Code quality review: naming, DRY, error handling, security, conventions
    7. Report findings with severity (Critical / Important / Minor) and assessment (PASS / NEEDS FIXES)
    8. Use category labels: spec-compliance, duplication, type-safety, readability, separation-of-concerns, pattern-consistency, integration, security

    ## Working Directory
    [Current working directory]
```

**6.5b: Documentation update — spawn doc updater after reviewer completes:**

Regardless of reviewer PASS/NEEDS FIXES outcome, spawn the doc updater:

```
Task tool:
  subagent_type: "general-purpose"
  model: sonnet
  description: "Phase N doc update"
  prompt: |
    Run the /mp-update-docs skill in auto mode.

    mode: auto
    context: phase N completion

    Scope: all (instructions + readme + mpx tracking)

    Phase reviewer flagged these documentation gaps:
    [Include Documentation Gaps section from reviewer report]

    Working directory: [Current working directory]
```

The doc updater handles all documentation commits independently.

**6.5c: Act on code quality findings:**

Based on the **6.5a reviewer report** (not the doc update):

**If reviewer reports PASS (no critical or important issues):**
1. Mark phase complete in ROADMAP.md (`- [ ]` → `- [x]`)
2. Store review summary for Step 7 report
3. Proceed to Step 7

**If reviewer reports NEEDS FIXES (critical and/or important issues found):**
1. Report all critical + important issues to user
2. Ask: **fix / skip / stop**
   - **Fix:** Dispatch executor agent (Step 5) with all critical + important issues as fix instructions. After executor completes, re-run the phase reviewer (loop back to 6.5a). Loop until PASS or user says skip/stop.
   - **Skip:** Mark phase complete in ROADMAP.md despite issues. Note skipped issues in Step 7 report.
   - **Stop:** Do NOT mark phase complete. Report partial progress. User can re-run `/mpx-execute` later.

**If reviewer agent fails/errors:** Report failure to user, ask whether to mark phase complete anyway or stop. Do not silently proceed.

### Step 7: Report Results

**Single task mode report (`task`):**

```
Task Completed: [Task Description]
Phase: N - [Phase Name]

Phase Progress: X/Y tasks complete

[If phase NOT complete:]
Next Task:
  [] [Next task description]

[If phase complete:]
Phase N Complete!

Comprehensive Review: [PASS / NEEDS FIXES (N fix rounds) / Skipped]
  Code Quality: [assessment summary]
  Doc Updates: [list of files updated, or "None needed"]
  [If issues were skipped: "⚠️ Skipped issues: [list]"]

Agents Dispatched:
  mpx-executor (opus) — [task description] — [✅/❌]
  mpx-phase-reviewer (opus|sonnet) — Code quality review — [PASS / N fix rounds]
  mp-update-docs (sonnet) — Documentation update — [files updated / no changes]

Commits Made: N

Run `/mpx-execute` to continue.
Run `/mpx-show-project-status` for full progress overview.
```

**Batch mode report (default/`all`):**

```
Phase N Execution Summary: [Phase Name]

Results:
  ✅ Completed: X tasks
  ❌ Failed:    Y tasks
  ⏭️ Skipped:   Z tasks

Batch Details:
  Batch 1 ([Section Name]): N/N tasks ✅
  Batch 2 ([Section Name]): N/N tasks ✅
  Batch 3 ([Section Name]): N/N tasks [✅/⚠️ partial]

Task Details:
  ✅ [Task 1 description]
  ✅ [Task 2 description]
  ❌ [Task 3 description] — [failure reason]
  ✅ [Task 4 description]

Phase Progress: X/Y tasks complete
[If failed tasks exist: "Failed tasks may need manual intervention or re-execution."]

[If phase complete:]
Phase N Complete!

Comprehensive Review: [PASS / NEEDS FIXES (N fix rounds) / Skipped]
  Spec Compliance: [summary]
  Code Quality: [summary]
  Doc Updates: [list of files updated, or "None needed"]
  Fix Rounds: [N — only if fixes were needed]
  [If issues were skipped: "⚠️ Skipped issues: [list]"]

Agents Dispatched: (N total)
  mpx-executor (opus) × N — Batch execution (N success, N retry)
  mpx-phase-reviewer (opus|sonnet) — Code quality review — [PASS / N fix rounds]
  mp-update-docs (sonnet) — Documentation update — [files updated / no changes]

Commits Made: N

Run `/mpx-execute` to continue with next phase.
Run `/mpx-show-project-status` for full progress overview.
```

## Error Handling

- **No phases found:** "No project found. Run `/mpx-setup` or `/mpx-parse-spec` first."
- **All phases complete:** "All phases complete! Project finished."
- **No eligible phases:** "All remaining phases are blocked. Check dependencies in ROADMAP.md."
- **Agent fails:** Report error, record in `failed[]` (batch mode) or suggest manual intervention (single task mode)

## Troubleshooting

| Problem | Solution |
|---------|----------|
| "No project found" | Run `/mpx-setup` or `/mpx-parse-spec` first to create `.mpx/` structure |
| "All phases complete" | Project is finished — verify with `/mpx-show-project-status` |
| "All remaining phases blocked" | Check dependency chain in `ROADMAP.md` — a predecessor may need completion |
| Executor agent fails | Check task spec in CHECKLIST.md — may be too vague or have missing context |
| Phase reviewer loops | After 2 fix rounds, consider skipping remaining issues |

## Parallel Execution Note

Multiple `/mpx-execute` commands can run in parallel on different phases if:

- The phases have no mutual dependencies
- Both phases' dependencies are already satisfied

Example: Phase 2 and Phase 3 can both run if they only depend on Phase 1 (completed).

## Notes

- The subagent gets fresh 200k context, preventing degradation
- Each task should be atomic and completable in one execution
- CHECKLIST.md is the single source of truth per phase (specs + tasks + state)
- Agent commits per batch (not per task) to reduce commit noise
- ROADMAP.md is the source of truth for phase completion status
- Batch mode continues on failure — all batches get attempted
- Reviews consolidated at phase end — no per-task review overhead
- HANDOFF.md is ephemeral — read once from project root at start, then deleted
- Autonomous by default — phase and scope are auto-decided; user is only prompted for fix/skip/stop after batch failures or review failures
- Use args (`phase N`, `task`, `all`) to override autonomous decisions when needed
