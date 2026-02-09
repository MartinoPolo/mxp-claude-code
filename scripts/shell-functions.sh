#!/bin/bash
# Shell wrapper functions for worktree scripts
# Source this in your .bashrc/.zshrc:
#
#   source /path/to/mxp-claude-code/scripts/shell-functions.sh

_MXP_SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"

setup-worktree() {
  bash "$_MXP_SCRIPTS_DIR/setup-worktree.sh" "$@"
  local target
  target=$(cat "${TMPDIR:-/tmp}/worktree-cd-path" 2>/dev/null)
  rm -f "${TMPDIR:-/tmp}/worktree-cd-path"
  if [ -n "$target" ] && [ -d "$target" ]; then
    cd "$target" || return
    cc
  fi
}

remove-worktree() {
  bash "$_MXP_SCRIPTS_DIR/remove-worktree.sh" "$@"
}
