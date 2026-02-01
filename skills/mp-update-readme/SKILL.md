---
name: mp-update-readme
description: Analyze codebase and update README.md with current project information
disable-model-invocation: true
allowed-tools: Read, Glob, Grep, Edit, Write
---

# Update README

Analyze this codebase and update the README.md file. $ARGUMENTS

## Steps

1. **Gather Context**:
   - Read package.json (if exists) for name, description, scripts, dependencies
   - Read existing README.md (if exists) to understand current structure
   - Glob for src/, lib/, or app/ directories to understand project structure
   - Identify the tech stack (TypeScript, React, Node, etc.)

2. **Identify What Needs Updating**:
   - Project description and features
   - Installation instructions (based on package manager)
   - Available scripts/commands
   - Configuration options
   - API documentation (if applicable)

3. **Preserve User Content**:
   - Keep badges, license sections, contributing guides
   - Preserve custom sections marked with <!-- CUSTOM --> comments
   - Maintain overall document style

4. **Update README.md**:
   - Use Edit tool to update specific sections
   - Keep it concise and scannable
   - Include code examples where helpful
   - Ensure all commands/scripts mentioned actually exist

5. **Report Changes**:
   - Summarize what was updated
   - Note any sections that may need manual review
