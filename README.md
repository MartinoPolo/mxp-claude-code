# Claude Code Custom Configuration

## Custom Status Line

![Status Line](assets/status-line.png)

3-line status bar showing:
- **Line 1**: Model, directory, git branch
- **Line 2**: Context usage bar (█/░), % tokens, session cost (USD/CZK)
- **Line 3**: 5-hour & 7-day quota utilization

Configured via `scripts/context-bar.sh`.

## Skills

| Skill | Description |
|-------|-------------|
| `/mp-init-project` | Full project setup (spec + git + phases) |
| `/mp-create-spec` | Interactive spec creation |
| `/mp-init-repo` | Initialize git repo |
| `/mp-parse-spec` | Parse SPEC.md → ROADMAP.md + phases |
| `/mp-execute` | Select phase, execute next task |
| `/mp-project-status` | Show progress |
| `/mp-add-requirements` | Add requirements with conflict detection |
| `/mp-review-branch` | Multi-agent code review |
| `/mp-review-pr` | PR review |
| `/mp-update-readme` | Update README.md |
| `/mp-handoff` | Update STATE.md with session handoff info |
| `/mp-gemini-fetch` | Fetch blocked sites via Gemini CLI |
| `/mp-update-instructions` | Analyze history, improve CLAUDE.md/AGENTS.md |

## Workflow

```
┌───────────────────┐
│  /mp-init-project │  ◄── Start here for new projects
└────────┬──────────┘
         │
         ▼
┌───────────────────┐
│  /mp-create-spec  │  ◄── Interactive tech stack Q&A
└────────┬──────────┘
         │
         ▼
┌───────────────────┐
│  /mp-init-repo    │  ◄── Git setup
└────────┬──────────┘
         │
         ▼
┌───────────────────┐
│  /mp-parse-spec   │  ◄── Generate ROADMAP.md + phases
└────────┬──────────┘
         │
         ▼
┌───────────────────┐
│  /mp-execute      │  ◄── Execute tasks (loop)
└────────┬──────────┘
         │
         ▼
┌───────────────────┐
│  /mp-project-status │  ◄── Check progress anytime
└───────────────────┘
```

## Project Structure

All projects use phase-based organization:

```
.claude/
├── SPEC.md              # Master project specification
├── ROADMAP.md           # Phase overview + high-level tracking
├── STATE.md             # Global state + session handoff
└── phases/
    ├── 01-foundation/
    │   ├── SPEC.md      # Phase requirements
    │   ├── CHECKLIST.md # Phase tasks
    │   └── STATE.md     # Phase state + session handoff
    ├── 02-core-feature/
    │   ├── SPEC.md
    │   ├── CHECKLIST.md
    │   └── STATE.md
    └── 03-polish/
        ├── SPEC.md
        ├── CHECKLIST.md
        └── STATE.md
```

**Key files:**
- `ROADMAP.md` - tracks phase completion (Status column)
- `STATE.md` - includes session handoff section
- Each phase folder has its own `CHECKLIST.md` for task tracking

## Usage Examples

```bash
# Start a new project
/mp-init-project

# Or step by step:
/mp-create-spec           # Create specification
/mp-init-repo             # Initialize git
/mp-parse-spec            # Generate ROADMAP.md + phases

# Execute tasks
/mp-execute               # Select phase, execute next task

# Check progress
/mp-project-status        # See progress and next steps

# Add new requirements mid-project
/mp-add-requirements "Add dark mode support"

# Review skills
/mp-review-branch         # Review current branch
/mp-review-pr 123         # Review specific PR
```

## Review Skills Details

### Safety Guarantees

**Review skills are read-only:**
- No files are modified
- No commits are made
- No GitHub comments are posted
- No PRs are approved/rejected

Only `/mp-update-readme` can modify files (the README.md).

### Review Categories

Both review skills check:
1. **Tech Stack Best Practices** - Framework-specific patterns
2. **Security** - OWASP top 10, injection, XSS, auth issues
3. **Performance** - N+1 queries, memory leaks, bundle size
4. **Error Handling** - Try/catch, boundaries, graceful degradation
5. **Code Quality** - DRY, complexity, naming, CLAUDE.md compliance

### Confidence Scoring

Issues are scored 0-100:
- **Top (>80)**: Must fix before merge
- **High (66-80)**: Should address
- **Medium (40-65)**: Worth reviewing
- **Low (<40)**: Stylistic or minor

## Agents

| Agent | Model | Description |
|-------|-------|-------------|
| mp-executor-agent | Opus | Executes tasks with fresh context |
| mp-spec-analyzer | Sonnet | Analyzes specs and creates phase structure |
