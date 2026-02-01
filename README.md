# Claude Code Custom Configuration

## Skills

| Skill | Description |
|-------|-------------|
| `/mp-init-project` | Full project setup (spec + git + checklist) |
| `/mp-create-spec` | Interactive spec creation |
| `/mp-init-repo` | Initialize git repo |
| `/mp-parse-spec` | Parse SPEC.md → checklist/phases |
| `/mp-execute` | Execute next task |
| `/mp-project-status` | Show progress |
| `/mp-add-requirements` | Add requirements with conflict detection |
| `/mp-review-branch` | Multi-agent code review |
| `/mp-review-pr` | PR review |
| `/mp-update-readme` | Update README.md |

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
│  /mp-parse-spec   │  ◄── Generate checklist/phases
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

## Simple vs Complex Projects

**Simple Projects** (1-3 features):
- Single `.claude/CHECKLIST.md`
- Run `/mp-execute` to work through tasks

**Complex Projects** (4+ features):
- Phase folders with individual SPEC.md, CHECKLIST.md, STATE.md
- Global ROADMAP.md and STATE.md
- Run `/mp-execute` to work through phase tasks

### Complex Project Structure

```
.claude/
├── SPEC.md              # Master project specification
├── CHECKLIST.md         # High-level phase tracking
├── ROADMAP.md           # Phase overview and dependencies
├── STATE.md             # Global project state
└── phases/
    ├── 01-foundation/
    │   ├── SPEC.md      # Phase requirements
    │   ├── CHECKLIST.md # Phase tasks
    │   └── STATE.md     # Phase progress
    ├── 02-core-feature/
    │   ├── SPEC.md
    │   ├── CHECKLIST.md
    │   └── STATE.md
    └── 03-polish/
        ├── SPEC.md
        ├── CHECKLIST.md
        └── STATE.md
```

## Usage Examples

```bash
# Start a new project
/mp-init-project

# Or step by step:
/mp-create-spec           # Create specification
/mp-init-repo             # Initialize git
/mp-parse-spec            # Generate checklist/phases

# Execute tasks
/mp-execute               # Execute next task (auto-detects project type)

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
