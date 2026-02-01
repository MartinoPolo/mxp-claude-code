# Claude Code Workflow Skills

A modular skill system for automating Claude Code project initialization with smart specification creation, complexity detection, and phase-based execution.

## Features

- **Smart `/create-spec`**: Interactive tech stack Q&A with intelligent suggestions
- **Auto-complexity detection**: Simple projects get a single checklist, complex projects get phased execution
- **Session handoff tracking**: STATE.md and ROADMAP.md for multi-session projects
- **Context isolation**: Subagents for phase execution to prevent context degradation

## Installation

### Quick Install

```bash
curl -fsSL https://raw.githubusercontent.com/{username}/claude-workflow-skills/main/install.sh | bash
```

### Manual Install

1. Clone this repo into your `~/.claude/` directory:
```bash
cd ~
git clone https://github.com/{username}/claude-workflow-skills.git .claude-skills
cp -r .claude-skills/skills ~/.claude/
cp -r .claude-skills/agents ~/.claude/
cp -r .claude-skills/scripts ~/.claude/
```

2. Restart Claude Code to load the new skills.

## Available Skills

| Skill | Description |
|-------|-------------|
| `/init-repo` | Initialize git repository with comprehensive .gitignore |
| `/create-spec` | Create project specification interactively with tech stack Q&A |
| `/parse-spec` | Convert SPEC.md into actionable checklists or phases |
| `/init-project` | All-in-one orchestrator (spec + repo + checklist) |
| `/execute-phase N` | Execute phase N with fresh context isolation |
| `/project-status` | Show current progress and next steps |

## Workflow

### Simple Projects (1-3 features)
```
/init-project → Creates SPEC.md → Creates CHECKLIST.md → Done
```

### Complex Projects (4+ features)
```
/init-project → Creates SPEC.md → Creates phases/ + STATE.md + ROADMAP.md
/execute-phase 1 → Executes with fresh context → Updates STATE.md
/execute-phase 2 → ...
/project-status → Shows progress
```

## File Structure

After running `/init-project` on a new project:

```
your-project/
├── .git/
├── .gitignore                  # Comprehensive, multi-language
└── .claude/
    ├── CLAUDE.md               # Project context
    ├── SPEC.md                 # Requirements
    ├── CHECKLIST.md            # Tasks (simple) or phase overview (complex)
    └── phases/                 # Only for complex projects
        ├── 01-foundation.md
        ├── 02-core-feature.md
        └── ...
    ├── STATE.md                # Session handoff (complex only)
    └── ROADMAP.md              # Phase overview (complex only)
```

## Configuration

Skills are stored in `~/.claude/skills/` and agents in `~/.claude/agents/`.

Sensitive files (settings.json, session data) are protected via `.gitignore`.

## License

MIT
