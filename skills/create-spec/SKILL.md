---
name: create-spec
description: Create project specification interactively. Asks about your idea, suggests tech stack, determines complexity.
disable-model-invocation: true
allowed-tools: Read, Write, Bash, AskUserQuestion
---

# Create Project Specification

Interactive specification creation with intelligent tech stack suggestions and automatic complexity detection.

## Workflow

### Step 1: Gather Project Idea

Ask the user to describe their project idea in free-form text:

> "What would you like to build? Describe your project idea - what it does, who it's for, and any key features you have in mind."

### Step 2: Analyze and Extract

From the user's description, identify:
- Core functionality
- Target users
- Key features (list them)
- Potential technical requirements

### Step 3: Tech Stack Questions

Use `AskUserQuestion` to ask about technology choices. Ask contextually relevant questions based on the project type:

**Language Selection:**
```
question: "What programming language would you like to use?"
options:
  - TypeScript (Recommended for web projects)
  - Python (Great for backends, data, ML)
  - Go (High-performance services)
  - Other (specify)
```

**If TypeScript/JavaScript selected:**
```
question: "Which package manager do you prefer?"
options:
  - npm (Default, widely supported)
  - yarn (Fast, reliable)
  - pnpm (Efficient disk space)
  - bun (Fast, all-in-one)
```

**Framework (contextual based on project type):**

For web frontend:
```
question: "Which frontend framework?"
options:
  - React (Most popular, large ecosystem)
  - Vue (Progressive, easy to learn)
  - Svelte (Compiled, fast)
  - Vanilla JS (No framework)
```

For backend API:
```
question: "Which backend framework?"
options:
  - Express (Node.js, minimal)
  - Fastify (Node.js, fast)
  - FastAPI (Python, modern)
  - Hono (Edge-first, fast)
```

**Database (if needed):**
```
question: "Do you need a database?"
options:
  - SQLite (File-based, simple)
  - PostgreSQL (Robust, scalable)
  - MongoDB (Document-based)
  - None (No database needed)
```

**Testing:**
```
question: "Which testing framework?"
options:
  - Vitest (Fast, Vite-native)
  - Jest (Popular, full-featured)
  - Pytest (Python standard)
  - None (Skip for now)
```

### Step 4: Determine Complexity

Based on the features identified, automatically determine complexity:

**Simple Project** (generates single CHECKLIST.md):
- 1-3 core features
- Single component/service
- No complex integrations
- Can be completed in one focused session

**Complex Project** (generates phases + STATE.md + ROADMAP.md):
- 4+ features
- Multiple components/services
- External integrations
- Multi-session effort

Inform the user of the detected complexity:

> "Based on your requirements, this looks like a **[simple/complex]** project. I'll create [a single checklist / phased implementation plan]."

### Step 5: Generate SPEC.md

Create `.claude/SPEC.md` with all gathered information:

```markdown
# Project Specification

## Project Name
[Name from user]

## Description
[User's description, cleaned up]

## Tech Stack
- Language: [selected]
- Package Manager: [selected]
- Framework: [selected]
- Database: [selected]
- Testing: [selected]

## Complexity
[Simple/Complex] - [reason]

## Core Features
1. [Feature 1]
2. [Feature 2]
...

## Technical Requirements
- [ ] [Auto-generated based on tech stack]
- [ ] [e.g., "Set up TypeScript configuration"]
- [ ] [e.g., "Configure ESLint and Prettier"]

## Success Criteria
- [Generated from features]

## Notes
[Any additional context from conversation]
```

### Step 6: Summary

Show the user what was created and suggest next steps:

> "Created `.claude/SPEC.md` with your project specification.
>
> **Summary:**
> - Project: [name]
> - Tech: [stack summary]
> - Complexity: [simple/complex]
> - Features: [count]
>
> **Next steps:**
> - Run `/parse-spec` to generate implementation checklist
> - Or run `/init-project` to also initialize git"

## Notes

- Always create SPEC.md in `.claude/` directory
- If `.claude/` doesn't exist, create it
- If SPEC.md already exists, ask before overwriting
- Be helpful with tech stack suggestions based on project type
