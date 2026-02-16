# Review Agent Specifications

### Agent 1: Tech Stack Best Practices
Based on detected tech stack, check for:

**TypeScript/JavaScript:** Strict mode, proper typing, no `any` abuse, modern ES features, async/await patterns

**React:** Hooks rules, key props, effect cleanup, memoization, side effect abuse (useEffect for derived state)

**Solid.js:** Signal usage, createMemo vs createEffect, Show/For/Switch components, onCleanup

**Svelte:** Reactive declarations, store subscriptions, lifecycle, unnecessary reactivity

**Node.js:** Async patterns, stream handling, error propagation, env handling

**Python:** Type hints, PEP 8, context managers, exception patterns

**Go:** Error handling, goroutine leaks, interface usage

**Rust:** Ownership, Result/Option, unsafe usage

### Agent 2: Security Review (OWASP Focus)
- SQL/NoSQL injection
- XSS (Cross-Site Scripting)
- Command injection
- Path traversal
- CSRF vulnerabilities
- Auth/authz issues
- Secrets exposure
- Sensitive data in logs
- Input validation gaps

### Agent 3: Performance Analysis
- N+1 query patterns
- Unnecessary re-renders
- Memory leaks
- Bundle size impact
- Expensive operations in hot paths
- Inefficient algorithms

### Agent 4: Error Handling & Reliability
- Try/catch usage
- Error boundary patterns
- Graceful degradation
- User-facing error messages
- Retry patterns
- Timeout handling
- Race conditions

### Agent 5: Code Quality & CLAUDE.md
- DRY violations
- Cyclomatic complexity
- Naming conventions
- Type safety
- Edge cases
- Test coverage gaps
- CLAUDE.md compliance
- Overcomplicated code - over-abstraction, premature optimization, convoluted logic, excessive indirection, feature creep beyond requirements

### Agent 6: Spec/Plan Alignment
- Requirements coverage — all spec requirements implemented?
- YAGNI — extra features not in requirements?
- Requirement misinterpretation — solved the right problem?
- Missing edge cases from spec
- Scope creep detection
- Do NOT trust implementer summary — verify by reading actual code
