#!/bin/bash
# Claude Code Workflow Skills Installer
# Usage: curl -fsSL https://raw.githubusercontent.com/{username}/claude-workflow-skills/main/install.sh | bash

set -e

CLAUDE_DIR="$HOME/.claude"
REPO_URL="https://github.com/{username}/claude-workflow-skills.git"
TEMP_DIR=$(mktemp -d)

echo "Installing Claude Code Workflow Skills..."

# Check if ~/.claude exists
if [ ! -d "$CLAUDE_DIR" ]; then
    echo "Creating ~/.claude directory..."
    mkdir -p "$CLAUDE_DIR"
fi

# Clone to temp directory
echo "Downloading skills..."
git clone --depth 1 "$REPO_URL" "$TEMP_DIR" 2>/dev/null || {
    echo "Error: Failed to clone repository"
    exit 1
}

# Backup existing skills if present
if [ -d "$CLAUDE_DIR/skills" ]; then
    echo "Backing up existing skills to skills.backup..."
    mv "$CLAUDE_DIR/skills" "$CLAUDE_DIR/skills.backup.$(date +%Y%m%d%H%M%S)"
fi

# Copy skills and agents
echo "Installing skills..."
cp -r "$TEMP_DIR/skills" "$CLAUDE_DIR/"

echo "Installing agents..."
mkdir -p "$CLAUDE_DIR/agents"
cp -r "$TEMP_DIR/agents/"* "$CLAUDE_DIR/agents/" 2>/dev/null || true

echo "Installing scripts..."
mkdir -p "$CLAUDE_DIR/scripts"
cp -r "$TEMP_DIR/scripts/"* "$CLAUDE_DIR/scripts/" 2>/dev/null || true
chmod +x "$CLAUDE_DIR/scripts/"*.sh 2>/dev/null || true

# Add .gitignore if not present
if [ ! -f "$CLAUDE_DIR/.gitignore" ]; then
    echo "Adding .gitignore..."
    cp "$TEMP_DIR/.gitignore" "$CLAUDE_DIR/"
fi

# Cleanup
rm -rf "$TEMP_DIR"

echo ""
echo "Installation complete!"
echo ""
echo "Available skills:"
echo "  /init-repo      - Initialize git repository"
echo "  /create-spec    - Create project specification"
echo "  /parse-spec     - Parse spec into checklist/phases"
echo "  /init-project   - All-in-one project setup"
echo "  /execute-phase  - Execute a specific phase"
echo "  /project-status - Show project progress"
echo ""
echo "Restart Claude Code to load the new skills."
