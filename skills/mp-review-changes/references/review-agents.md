# Review Agents for Uncommitted Changes

### Agent 1: Code Quality & DRY/SoC

Review uncommitted changes for:

- **Duplication** — repeated logic, copy-paste code, patterns that should be extracted
- **Redundant logic** — dead code paths, unnecessary conditions, over-defensive checks
- **Separation of concerns** — mixed responsibilities, business logic in UI, data access in controllers
- **Naming** — unclear names, abbreviations, misleading identifiers
- **Type safety** — `any` abuse, missing types, unsafe casts, unvalidated inputs
- **Overcomplicated code** — over-abstraction, premature optimization, convoluted logic, excessive indirection

Classify each issue as **Critical**, **Important**, or **Minor**.

Output format per issue:
```
[Critical/Important/Minor] `file:line` — Title
Description (1-2 sentences: what + why it's a problem).
Suggested fix: [concrete action]
```

### Agent 2: Best Practices & Conventions

Based on detected tech stack, check for:

**TypeScript/JavaScript:** Strict mode, proper typing, modern ES features, async/await patterns, no `any` abuse

**React:** Hooks rules, key props, effect cleanup, memoization, side effect abuse

**Svelte:** Reactive declarations, store subscriptions, lifecycle, unnecessary reactivity

**Node.js:** Async patterns, stream handling, error propagation, env handling

**Python:** Type hints, PEP 8, context managers, exception patterns

**Go:** Error handling, goroutine leaks, interface usage

**Rust:** Ownership, Result/Option, unsafe usage

**CLAUDE.md compliance:** If CLAUDE.md exists, verify changes follow its conventions.

**Language conventions:** Idiomatic patterns for the language, standard library usage over reinvention.

Classify each issue as **Critical**, **Important**, or **Minor**.

### Agent 3: Spec Alignment (Conditional)

**Only spawned if** `.mpx/SPEC.md`, `SPEC.md`, or an active checklist (`.mpx/phases/*/CHECKLIST.md` with unchecked tasks) exists.

Review changes against requirements:
- **Requirements coverage** — do changes implement what's specified?
- **YAGNI** — extra features not in requirements?
- **Scope creep** — changes beyond current task/phase scope?
- **Requirement misinterpretation** — solved the right problem?
- **Missing edge cases** from spec

Classify each issue as **Critical**, **Important**, or **Minor**.
