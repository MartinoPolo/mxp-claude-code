# User-Level Instructions

## Windows Command Workaround

**On Windows, `yarn`, `npm`, `pnpm`, and `docker` commands produce no output when run directly.**

This is a known Claude Code issue. Always wrap these commands with Node's child_process:

```bash
# Instead of: yarn lint
node -e "require('child_process').execSync('yarn lint', {stdio:'inherit'})"

# Instead of: yarn build
node -e "require('child_process').execSync('yarn build', {stdio:'inherit'})"

# Instead of: yarn --version
node -e "console.log(require('child_process').execSync('yarn --version', {encoding:'utf8'}).trim())"
```

**Also use this workaround whenever you'd expect any output and see none (no content).**

**Pattern**:
- Use `stdio:'inherit'` for commands where you need live output (build, lint, test)
- Use `encoding:'utf8'` + `console.log()` when you need to capture output as a string

**Applies to**: `yarn`, `npm`, `pnpm`, `docker`, and similar tools that don't work with TTY detection.

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

## MCP Tools

Use `ToolSearch` to load deferred tools only when needed.

| Need | Search | Instead Of |
|------|--------|------------|
| Docs | `context7` | Web search |
| GitHub | `github` | `gh` CLI |
| Browser testing | `chrome-devtools` | Manual |

## Self-Improvement Protocol

When encountering errors, unexpected behavior, or workflow friction:

1. **Analyze** - root cause, why instructions didn't prevent it
2. **Fix** - resolve immediate issue
3. **Update instructions** - modify AGENTS.md or relevant files
4. **Document** - note what changed and why

**Trigger examples**: silent command failures, missing workflow steps, ambiguous instructions, unreliable tools

## Documentation Maintenance

Update docs when behavior, patterns, or structure changes.

| Change Type | Update Target |
|-------------|---------------|
| New pattern/convention | `~/.claude/AGENTS.md` |
| Workflow changes | `~/.claude/skills/*.md`, `README.md` |
| Agent behavior | `~/.claude/agents/*.md` |
| Project tasks | `.claude/phases/*/CHECKLIST.md` |

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

## Testing

- Create tests when adding new features
- Run existing tests after changes to verify nothing broke
- Tests enable autonomous problem-solving and verification
