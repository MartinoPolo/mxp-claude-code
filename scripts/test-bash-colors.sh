#!/bin/bash
# Test script for bash color output
# Usage: bash ~/.claude/scripts/test-bash-colors.sh

# Colors
RESET='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'
UNDERLINE='\033[4m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
BOLD_RED='\033[1;31m'
BOLD_GREEN='\033[1;32m'
BOLD_YELLOW='\033[1;33m'
BOLD_BLUE='\033[1;34m'
BG_RED='\033[41m'
BG_GREEN='\033[42m'
BG_YELLOW='\033[43m'
BG_BLUE='\033[44m'

echo ""
echo "=== Text Styles ==="
echo -e "${BOLD}Bold text${RESET}"
echo -e "${DIM}Dim text${RESET}"
echo -e "${UNDERLINE}Underlined text${RESET}"

echo ""
echo "=== Regular Colors ==="
echo -e "${RED}Red${RESET} ${GREEN}Green${RESET} ${YELLOW}Yellow${RESET} ${BLUE}Blue${RESET} ${MAGENTA}Magenta${RESET} ${CYAN}Cyan${RESET} ${WHITE}White${RESET}"

echo ""
echo "=== Bold Colors ==="
echo -e "${BOLD_RED}Bold Red${RESET} ${BOLD_GREEN}Bold Green${RESET} ${BOLD_YELLOW}Bold Yellow${RESET} ${BOLD_BLUE}Bold Blue${RESET}"

echo ""
echo "=== Background Colors ==="
echo -e "${BG_RED}${WHITE} Red BG ${RESET} ${BG_GREEN}${WHITE} Green BG ${RESET} ${BG_YELLOW} Yellow BG ${RESET} ${BG_BLUE}${WHITE} Blue BG ${RESET}"

echo ""
echo "=== Script Usage Patterns ==="
echo -e "${GREEN}✓${RESET} Success message"
echo -e "${RED}✗${RESET} Error message"
echo -e "${YELLOW}⚠${RESET} Warning message"
echo -e "${CYAN}→${RESET} Info message"
echo -e "  ${DIM}Secondary details${RESET}"

echo ""
echo "=== Path Highlight Box ==="
echo -e "   ┌────────────────────────────────┐"
echo -e "   │  ${BOLD}cd ../worktrees/feature-name${RESET}  │"
echo -e "   └────────────────────────────────┘"

echo ""
