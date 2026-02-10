# mpx — Claude Code Customization Toolkit

A collection of skills, agents, scripts, and instructions that extend [Claude Code](https://docs.anthropic.com/en/docs/claude-code) with spec-driven project development workflows and general-purpose dev tools.

**Two ways to use it:**
- **Full mpx workflow** — spec-driven, phase-based project development from scratch
- **Individual skills** — cherry-pick general-purpose tools (commits, PRs, reviews, etc.)

## Installation

### Prerequisites

- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) installed and working

### Setup

1. **Clone this repo:**

```bash
git clone https://github.com/user/mxp-claude-code.git
cd mxp-claude-code
```

2. **Symlink into `~/.claude/`:**

Claude Code loads skills, agents, and instructions from `~/.claude/`. Create symlinks so this repo's contents are available globally.

**macOS / Linux:**

```bash
ln -s "$(pwd)/skills" ~/.claude/skills
ln -s "$(pwd)/agents" ~/.claude/agents
ln -s "$(pwd)/scripts" ~/.claude/scripts
ln -s "$(pwd)/instructions" ~/.claude/instructions
ln -s "$(pwd)/assets" ~/.claude/assets
ln -s "$(pwd)/CLAUDE.md" ~/.claude/CLAUDE.md
ln -s "$(pwd)/AGENTS.md" ~/.claude/AGENTS.md
```

**Windows (run as Administrator):**

```cmd
mklink /D "%USERPROFILE%\.claude\skills" "C:\path\to\mxp-claude-code\skills"
mklink /D "%USERPROFILE%\.claude\agents" "C:\path\to\mxp-claude-code\agents"
mklink /D "%USERPROFILE%\.claude\scripts" "C:\path\to\mxp-claude-code\scripts"
mklink /D "%USERPROFILE%\.claude\instructions" "C:\path\to\mxp-claude-code\instructions"
mklink /D "%USERPROFILE%\.claude\assets" "C:\path\to\mxp-claude-code\assets"
mklink "%USERPROFILE%\.claude\CLAUDE.md" "C:\path\to\mxp-claude-code\CLAUDE.md"
mklink "%USERPROFILE%\.claude\AGENTS.md" "C:\path\to\mxp-claude-code\AGENTS.md"
```

3. **Verify:** Launch Claude Code in any project — skills should appear when you type `/mp` or `/mpx`.

## Quick Start

**New project:**

```bash
cd your-project
# Then in Claude Code:
/mpx-setup
```

Auto-detects project state — fresh init, existing codebase, or restructure. Creates spec, initializes git, generates phased roadmap and checklists.

## MPX Workflow

```
/mpx-setup                 ◄── Auto-detects: fresh init, convert existing, or restructure
        │
        ▼
/mpx-create-spec           ◄── Interactive tech stack Q&A → SPEC.md
        │
        ▼
/mpx-init-repo             ◄── Git setup (.gitignore, .editorconfig, etc.)
        │
        ▼
/mpx-parse-spec            ◄── SPEC.md → ROADMAP.md + phase folders
        │
        ▼
/mpx-execute               ◄── Pick phase, execute tasks (loop)
        │
        ▼
/mpx-show-project-status   ◄── Check progress anytime
```

Between sessions, optionally use `/mpx-handoff` to save context to phase `HANDOFF.md` for continuity.

## Project Structure

All mpx projects use phase-based organization inside `.mpx/`:

```
.mpx/
├── SPEC.md              # Master project specification
├── ROADMAP.md           # Phase overview + tracking + decisions + blockers
└── phases/
    ├── 01-foundation/
    │   ├── CHECKLIST.md  # Phase specs + tasks + state
    │   └── HANDOFF.md    # (optional) Ephemeral session handoff — only if /mpx-handoff was run
    ├── 02-core-feature/
    │   └── CHECKLIST.md
    └── 03-polish/
        └── CHECKLIST.md
```

- `ROADMAP.md` — tracks phase completion, project-level decisions and blockers
- Each phase has `CHECKLIST.md` (single source of truth for specs + tasks + state)
- `HANDOFF.md` is ephemeral and optional — created only if `/mpx-handoff` was run, consumed by `/mpx-execute`

## Skills Reference

### mpx- Skills (Spec-Driven Workflow)

| Skill | Description |
|-------|-------------|
| `/mpx-setup` | Unified project setup (auto-detects: fresh init, convert existing, restructure) |
| `/mpx-create-spec` | Interactive spec creation |
| `/mpx-init-repo` | Initialize git repo |
| `/mpx-parse-spec` | Parse SPEC.md → ROADMAP.md + phases |
| `/mpx-execute` | Select phase, execute tasks (full phase or single) |
| `/mpx-show-project-status` | Show progress |
| `/mpx-add-requirements` | Add requirements with conflict detection |
| `/mpx-handoff` | Create ephemeral HANDOFF.md for session bridging |

### mp- Skills (General Purpose)

| Skill | Description |
|-------|-------------|
| `/mp-commit` | Stage and commit with conventional format |
| `/mp-pr-create` | Create draft PR from existing commits |
| `/mp-commit-push-pr` | Full workflow — commit, push, create draft PR |
| `/mp-review-branch` | Multi-agent code review of current branch |
| `/mp-review-pr` | PR review with confidence scoring |
| `/mp-review-design` | Visual design inspection via chrome-devtools |
| `/mp-gh-issue-fix` | Investigate and fix GitHub issues |
| `/mp-update-readme` | Update README.md |
| `/mp-update-instructions` | Analyze history, improve CLAUDE.md/AGENTS.md |
| `/mp-check-fix` | Auto-detect and fix build/typecheck/lint errors |
| `/mp-gemini-fetch` | Fetch blocked sites via Gemini CLI |

## Agents

| Agent | Model | Description |
|-------|-------|-------------|
| mpx-executor | Opus | Executes tasks with fresh context |
| mpx-spec-analyzer | Sonnet | Analyzes specs and creates phase structure |
| mpx-codebase-scanner | Sonnet | Scans codebase for tech stack, features, structure |
| mp-gh-issue-analyzer | Opus | Analyzes GitHub issues, creates fix plans |
| mp-context7-docs-fetcher | Sonnet | Fetches library docs via Context7 MCP |
| mp-css-layout-debugger | Haiku | CSS layout debugging |
| mp-bash-script-colorizer | Haiku | Bash script coloring guidelines |
| mp-ux-designer | Sonnet | UX research and design artifacts |

Agents are auto-spawned based on rules in `AGENTS.md` — no manual invocation needed.

## Custom Status Line

![Status Line](assets/status-line.png)

3-line status bar showing:
- **Line 1**: Model, directory, git branch
- **Line 2**: Context usage bar (█/░), % tokens, session cost (USD/CZK)
- **Line 3**: 5-hour & 7-day quota utilization

Configured via `scripts/context-bar.sh`.

## Review Skills

Review skills (`/mp-review-branch`, `/mp-review-pr`, `/mp-review-design`) are **read-only** — no files modified, no commits, no GitHub comments posted.

**Categories checked:** tech stack best practices, security (OWASP top 10), performance, error handling, code quality.

**Confidence scoring** (0–100): >80 must fix, 66–80 should address, 40–65 worth reviewing, <40 minor/stylistic.
