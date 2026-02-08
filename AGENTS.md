# User-Level Instructions

## Communication Style

- **Concise** - Be extremely concise. Sacrifice grammar for the sake of concision.
- **Imperative mood** - "Return value", "Handle errors"
- **Present tense** - "Handles", not "Will handle"
- **Why over what** - Reasons > descriptions

## Code Standards

- **Dead Code**: Remove unused code, exports, commented code, unreachable paths
- **DRY**: Extract reusable logic. Share types. Don't extract single-use code
- **Verbose Naming**: Full descriptive names. No abbreviations. Clear intent
- **Docs**: Update when functionality changes. Keep comments minimal

## Iron Laws

Violating the letter IS violating the spirit. No exceptions.

1. **NO COMPLETION CLAIMS WITHOUT VERIFICATION** — Run command, read output, THEN claim
2. **NO FIXES WITHOUT ROOT CAUSE** — Understand why before changing code
3. **NO COMMITS WITH FAILING CHECKS** — /mp-check-fix before /mp-commit
4. **NEVER TRUST SUBAGENT REPORTS** — Verify independently (git diff, test output)

## Forbidden Responses

- "Should work now" / "Probably fixed" (without verification evidence)
- "You're absolutely right!" / "Great point!" (performative agreement)
- "I'm confident this works" (confidence != evidence)
- "Let me just quickly..." (skipping process)

## Red Flags — STOP

If thinking any of these, follow the process instead:
- "Quick fix for now, investigate later"
- "Just try changing X and see"
- "Skip the test, I'll verify manually"
- "Too simple to need process"
- "I'll write tests after"

## MCP Tools

Use `ToolSearch` to load deferred tools only when needed.

| Need            | Search            | Instead Of |
| --------------- | ----------------- | ---------- |
| Docs            | `context7`        | Web search |
| GitHub          | `github`          | `gh` CLI   |
| Browser testing | `chrome-devtools` | Manual     |

## Agent Auto-Spawn Rules

**Spawn `mp-context7-docs-fetcher` agent when:**

- User asks about library APIs, syntax, or best practices
- Questions mention: React, Svelte, Typescript, Next.js, Tailwind, etc.
- Question mentions context7 or library documentation
- "Use [library] best practices", "How do I use [library]?", "What's the best way to [library task]?"

**Spawn `mp-css-layout-debugger` agent when:**

- Layout issues: "fix layout", "elements overlapping", "overflow"
- CSS systems: "flexbox not working", "grid issues", "centering"
- Responsive: "mobile layout broken", "responsive design"

**Spawn `mp-ux-designer` agent when:**

- "Design a [feature]", "UX for..."

**Spawn `mp-bash-script-colorizer` agent when:**

- Creating new bash/shell scripts
- Adding echo/printf output to scripts
- Scripts have success/error/warning messages

**Use `/mp-commit` skill when:**

- User asks to commit changes
- "Commit this", "Stage and commit", "Make a commit"

**Use `/mp-pr-create` skill when:**

- User asks to create a PR (without committing)
- "Create PR", "Open pull request", "Make a PR"

**Use `/mp-check-fix` skill when:**

- "Fix lint errors", "Fix type errors", "Check and fix", "Run checks"
- Before committing if build/lint issues suspected

**Use `/mp-brainstorm` skill when:**

- User wants to explore/design before coding
- "Brainstorm", "Design a...", "How should we approach..."
- "Let's think about...", "What's the best way to..."
- Before any large feature implementation

## Self-Improvement Protocol

When encountering errors, unexpected behavior, or workflow friction:

1. **Analyze** - root cause, why instructions didn't prevent it
2. **Fix** - resolve immediate issue
3. **Update instructions** - modify AGENTS.md or relevant files
4. **Document** - note what changed and why

**Trigger examples**: silent command failures, missing workflow steps, ambiguous instructions, unreliable tools

## Documentation Maintenance

Update docs when behavior, patterns, or structure changes.

## Plan Mode

- Extremely concise plans. Sacrifice grammar for the sake of concision.
- End each plan with unresolved questions (if any)

## Summary Requirements

Concise. Include reasoning, sources.

Use these emoji indicators in summaries:
Choose one of these:

- 🟢 Success/completed
- 🔴 Issues occurred (briefly describe)
- ⚪ No action
  Add any number of these:
- 🟡 Committed (mention branch/message)
- 🟠 Pushed (mention remote/branch)
- 🔵 PR created/updated (include link)
- 🟣 Question/needs input

## Git Commits

Conventional commits: `type(scope): description`

**Types**: feat, fix, refactor, chore, docs, style, test, perf, ci, build, revert
