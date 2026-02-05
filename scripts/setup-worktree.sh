#!/bin/bash
# Creates a new git worktree for isolated development
# Usage: bash setup-worktree.sh <name>

set -e

# Colors
RESET='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'

NAME=$1

if [ -z "$NAME" ]; then
  echo -e "${RED}✗${RESET} Usage: bash setup-worktree.sh <name>"
  exit 1
fi

CURRENT_BRANCH=$(git branch --show-current)
WORKTREE_DIR="../worktrees"
WORKTREE_PATH="$WORKTREE_DIR/$NAME"
MAIN_REPO=$(pwd)

copy_dir() {
  local source="$1"
  local target="$2"
  if [ -d "$source" ]; then
    [ -e "$target" ] && rm -rf "$target"
    cp -r "$source" "$target"
    echo -e "  ${DIM}Copied: $(basename "$source")/${RESET}"
  fi
}

copy_file() {
  local source="$1"
  local target="$2"
  if [ -f "$source" ]; then
    mkdir -p "$(dirname "$target")"
    cp "$source" "$target"
    echo -e "  ${DIM}Copied: $(basename "$source")${RESET}"
  fi
}

mkdir -p "$WORKTREE_DIR"

echo -e "${CYAN}→${RESET} Creating worktree '${BOLD}$NAME${RESET}' from '${BOLD}$CURRENT_BRANCH${RESET}'..."
git worktree add -b "$NAME" "$WORKTREE_PATH"

cd "$WORKTREE_PATH"

echo -e "${CYAN}→${RESET} Copying IDE configs..."
copy_dir "$MAIN_REPO/.vscode" "$PWD/.vscode"
copy_dir "$MAIN_REPO/.cursor" "$PWD/.cursor"

echo -e "${CYAN}→${RESET} Copying Claude Code local settings..."
copy_file "$MAIN_REPO/.claude/settings.local.json" "$PWD/.claude/settings.local.json"

echo ""
echo -e "${CYAN}?${RESET} How should .env files be set up?"
echo "  1) Copy current .env files from main repo (default)"
echo "  2) Create from .env.example files"
read -p "  Choose [1/2]: " ENV_CHOICE
ENV_CHOICE=${ENV_CHOICE:-1}

if [ "$ENV_CHOICE" = "2" ]; then
  echo -e "${CYAN}→${RESET} Creating .env from .env.example files..."
  find . -name ".env.example" -exec sh -c '
    cp "$1" "${1%.example}"
    echo "  Copied: $1 -> ${1%.example}"
  ' _ {} \;
else
  echo -e "${CYAN}→${RESET} Copying .env files from main repo..."
  find "$MAIN_REPO" -name ".env" -not -path "*/node_modules/*" -not -path "*/.git/*" | while read -r envfile; do
    rel_path="${envfile#$MAIN_REPO/}"
    target="$PWD/$rel_path"
    mkdir -p "$(dirname "$target")"
    cp "$envfile" "$target"
    echo -e "  ${DIM}Copied: $rel_path${RESET}"
  done
  # Fallback: create from .env.example if .env doesn't exist
  find . -name ".env.example" | while read -r example; do
    target="${example%.example}"
    if [ ! -f "$target" ]; then
      cp "$example" "$target"
      echo -e "  ${DIM}Created: $target (from example)${RESET}"
    fi
  done
fi

echo -e "${CYAN}→${RESET} Opening VSCode..."
code .

echo -e "${CYAN}→${RESET} Installing dependencies..."
if [ -f "pnpm-lock.yaml" ]; then
  pnpm install
elif [ -f "yarn.lock" ]; then
  yarn install
elif [ -f "package-lock.json" ]; then
  npm install
elif [ -f "package.json" ]; then
  npm install
fi

echo ""
echo -e "${GREEN}✓${RESET} Done! Worktree ready"
echo ""
echo -e "   ┌──────────────────────────────────┐"
printf "   │  ${BOLD}cd ../worktrees/%-15s${RESET}  │\n" "$NAME"
echo -e "   └──────────────────────────────────┘"
echo ""
