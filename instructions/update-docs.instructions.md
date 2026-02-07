---
description: 'Auto-sync documentation with code changes'
applyTo: '**/*.{md,js,ts,tsx,jsx,py,java,go,rs,rb,php}'
---

# Update Documentation on Code Change

## Trigger Conditions

Check if docs need updates when:

- New features/functionality added
- API endpoints, methods, interfaces change
- Breaking changes introduced
- Dependencies or requirements change
- Configuration options modified
- Installation/setup procedures change
- CLI commands or scripts updated

## What to Update

### README.md

Update when:
- Adding features → Add to "Features" section
- Changing setup → Update "Installation"/"Getting Started"
- New CLI commands → Document syntax + examples
- Config changes → Update examples + env vars

### API Documentation

Update when:
- New endpoints → Document method, path, params
- Signature changes → Update params + response schema
- Auth changes → Update security requirements

### Code Examples

Verify when:
- Function signatures change → Update all snippets
- API interfaces change → Update request/response examples
- Best practices evolve → Replace outdated patterns

### Configuration

Update when:
- New env vars → Add to `.env.example` + docs
- Config structure changes → Update example files
- Deployment config changes → Update guides

## Changelog Entry

Add entry for:
- **Added**: New features
- **Changed**: Behavior changes, **BREAKING** prefix for breaking
- **Fixed**: Bug fixes
- **Deprecated**: Features to be removed
- **Security**: Security fixes

Format:
```markdown
## [Version] - YYYY-MM-DD

### Added
- New feature description (#PR)

### Changed
- **BREAKING**: Description of breaking change
```

## Verification Checklist

Before completing:
- [ ] README reflects current state
- [ ] New features documented
- [ ] Code examples tested and working
- [ ] API docs complete
- [ ] Config examples accurate
- [ ] Breaking changes have migration guide
- [ ] CHANGELOG updated
- [ ] Links valid
- [ ] Installation steps current
- [ ] Env vars documented

## Best Practices

**DO:**
- Update docs in same commit as code
- Test code examples before committing
- Provide migration paths for breaking changes
- Use consistent terminology

**DON'T:**
- Commit code without updating docs
- Leave outdated examples
- Document unimplemented features
- Forget changelog entries
