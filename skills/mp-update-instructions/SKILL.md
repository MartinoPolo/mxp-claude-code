---
name: mp-update-instructions
description: 'Analyze conversation history to identify gaps and suggest improvements to CLAUDE.md/AGENTS.md. Use when: "update instructions", "improve CLAUDE.md", "improve AGENTS.md"'
disable-model-invocation: true
allowed-tools: Read, Glob, Grep, Write, Task, AskUserQuestion
metadata:
  author: MartinoPolo
  version: "0.1"
  category: utility
---

# Update Instructions

Analyzes recent conversation history to identify patterns, violated instructions, and gaps in CLAUDE.md/AGENTS.md configuration files.

## Purpose

Continuous improvement of Claude Code instructions based on actual usage patterns rather than guesswork. Identifies:
- Instructions that were violated (need reinforcement)
- Patterns worth documenting (new conventions)
- Outdated or unnecessary content (cleanup)
- Project-specific vs global patterns

## Workflow

### Step 1: Locate Conversation History

Find conversation logs in `~/.claude/projects/`:

```bash
# Convert current project path to folder name (slashes become dashes)
# e.g., /c/Users/snapy/myproject -> -c-Users-snapy-myproject
```

Look for:
- `~/.claude/projects/[project-folder]/`
- Files ending in `.jsonl` (conversation transcripts)

### Step 2: Extract Recent Conversations

Read the 10-15 most recent conversation files:
- Parse JSONL format
- Extract user and assistant messages
- Focus on recent sessions (last few days)

### Step 3: Read Current Instructions

Load current instruction files:
- `~/.claude/CLAUDE.md` or `~/.claude/AGENTS.md` (global)
- `.claude/CLAUDE.md` (project-specific, if exists)

### Step 4: Analyze Conversations

For each conversation, identify:

**Violated Instructions:**
- Cases where Claude didn't follow existing rules
- Instructions that need to be more explicit

**Missing Patterns:**
- Repeated corrections from user
- Conventions followed but not documented
- Workarounds used multiple times

**Project-Specific Patterns:**
- Patterns only relevant to current project
- Should go in project's `.claude/CLAUDE.md`

**Global Patterns:**
- Universal patterns applicable everywhere
- Should go in `~/.claude/AGENTS.md`

**Outdated Content:**
- Instructions no longer relevant
- Deprecated patterns or tools

### Step 5: Generate Suggestions

Create a summary organized by category:

```markdown
## Instruction Update Suggestions

### Violated Instructions (Need Reinforcement)
- [Instruction] was violated when [context]
  - Suggested change: [make more explicit]

### Suggested Additions (Global)
- [Pattern]: [description]
  - Reason: Observed in [X] conversations

### Suggested Additions (Project-Specific)
- [Pattern]: [description]
  - Reason: Specific to this project

### Potentially Outdated
- [Instruction]: May no longer be relevant
  - Reason: [not used in recent sessions]
```

### Step 6: Ask User

Use `AskUserQuestion` to confirm changes:

```
question: "Which suggestions should I apply?"
options:
  - Apply all suggestions
  - Review each one individually
  - Show me the full analysis first
  - Cancel
```

### Step 7: Apply Changes

If approved, edit the relevant files:
- Add new patterns to appropriate file
- Reinforce violated instructions
- Remove outdated content (with user confirmation)

## Notes

- Never modify instructions without user approval
- Distinguish between global and project-specific patterns
- Focus on patterns that appeared multiple times
- Keep instructions concise (per AGENTS.md style)
