#!/bin/bash

# COMPREHENSIVE DEBUG STATUS LINE SCRIPT
# This script outputs extensive debug information to diagnose status line issues

# Color codes for visible output
C_RESET='\033[0m'
C_RED='\033[38;5;196m'
C_GREEN='\033[38;5;46m'
C_YELLOW='\033[38;5;226m'
C_BLUE='\033[38;5;74m'
C_GRAY='\033[38;5;245m'

# Read input from Claude Code
input=$(cat)

# ============================================================================
# SECTION 1: ENVIRONMENT DEBUG
# ============================================================================
printf '%b\n' "${C_YELLOW}=== ENVIRONMENT ===${C_RESET}"
printf "OSTYPE: %s\n" "$OSTYPE"
printf "SHELL: %s\n" "$SHELL"
printf "BASH_VERSION: %s\n" "$BASH_VERSION"
printf "HOME: %s\n" "$HOME"
printf "PWD: %s\n" "$PWD"
printf "WSL_DISTRO_NAME: %s\n" "${WSL_DISTRO_NAME:-<unset>}"
printf "/mnt/c exists: %s\n" "$([[ -d "/mnt/c" ]] && echo "YES" || echo "NO")"
printf "/c exists: %s\n" "$([[ -d "/c" ]] && echo "YES" || echo "NO")"

# Detect environment type
env_type="unknown"
[[ "$OSTYPE" == "msys" ]] && env_type="GitBash"
[[ "$OSTYPE" == "cygwin" ]] && env_type="Cygwin"
[[ -d "/mnt/c" ]] && env_type="WSL"
[[ -n "$WSL_DISTRO_NAME" ]] && env_type="WSL:$WSL_DISTRO_NAME"
[[ "$OSTYPE" == "linux-gnu"* && ! -d "/mnt/c" ]] && env_type="Linux"
[[ "$OSTYPE" == "darwin"* ]] && env_type="macOS"
printf "Detected env: %s\n" "$env_type"

# ============================================================================
# SECTION 2: TOOL AVAILABILITY
# ============================================================================
printf '%b\n' "${C_YELLOW}=== TOOLS ===${C_RESET}"
printf "jq path: %s\n" "$(which jq 2>/dev/null || echo 'NOT FOUND')"
printf "jq version: %s\n" "$(jq --version 2>/dev/null || echo 'FAILED')"
printf "git path: %s\n" "$(which git 2>/dev/null || echo 'NOT FOUND')"
printf "git version: %s\n" "$(git --version 2>/dev/null || echo 'FAILED')"
printf "curl path: %s\n" "$(which curl 2>/dev/null || echo 'NOT FOUND')"

# ============================================================================
# SECTION 3: INPUT JSON ANALYSIS
# ============================================================================
printf '%b\n' "${C_YELLOW}=== INPUT JSON ===${C_RESET}"
input_len=${#input}
printf "Input length: %d chars\n" "$input_len"

# Check if input is valid JSON
if echo "$input" | jq -e '.' >/dev/null 2>&1; then
    printf "JSON valid: YES\n"
else
    printf '%b\n' "${C_RED}JSON valid: NO - jq parsing failed!${C_RESET}"
    printf "First 500 chars of input:\n"
    echo "$input" | head -c 500
    printf "\n"
fi

# List top-level keys
printf "Top-level keys: %s\n" "$(echo "$input" | jq -r 'keys | join(", ")' 2>/dev/null || echo 'FAILED')"

# ============================================================================
# SECTION 4: EXTRACTED VALUES (RAW)
# ============================================================================
printf '%b\n' "${C_YELLOW}=== RAW EXTRACTED VALUES ===${C_RESET}"

# Model
model_raw=$(echo "$input" | jq -r '.model // "null"' 2>/dev/null)
model_display=$(echo "$input" | jq -r '.model.display_name // "null"' 2>/dev/null)
model_id=$(echo "$input" | jq -r '.model.id // "null"' 2>/dev/null)
printf "model (raw): %s\n" "$model_raw"
printf "model.display_name: %s\n" "$model_display"
printf "model.id: %s\n" "$model_id"

# CWD
cwd_raw=$(echo "$input" | jq -r '.cwd // "null"' 2>/dev/null)
printf "cwd (raw from JSON): %s\n" "$cwd_raw"

# Transcript path
transcript_raw=$(echo "$input" | jq -r '.transcript_path // "null"' 2>/dev/null)
printf "transcript_path (raw): %s\n" "$transcript_raw"

# Context window
context_window=$(echo "$input" | jq -r '.context_window // "null"' 2>/dev/null)
printf "context_window (raw): %.200s...\n" "$context_window"

# Cost
cost_raw=$(echo "$input" | jq -r '.cost // "null"' 2>/dev/null)
printf "cost (raw): %s\n" "$cost_raw"

# ============================================================================
# SECTION 5: PATH CONVERSIONS
# ============================================================================
printf '%b\n' "${C_YELLOW}=== PATH CONVERSIONS ===${C_RESET}"

# Helper function to convert Windows path to Unix path
win_to_unix_path() {
    local path="$1"
    if [[ ! "$path" =~ ^[A-Za-z]:\\ && ! "$path" =~ ^[A-Za-z]:/ ]]; then
        echo "$path"
        return
    fi

    if command -v wslpath >/dev/null 2>&1; then
        wslpath -u "$path" 2>/dev/null && return
    fi

    if [[ -d "/mnt/c" ]]; then
        local drive="${path:0:1}"
        drive="${drive,,}"
        local rest="${path:2}"
        rest="${rest//\\//}"
        rest="${rest#/}"
        echo "/mnt/$drive/$rest"
    else
        local drive="${path:0:1}"
        drive="${drive,,}"
        local rest="${path:2}"
        rest="${rest//\\//}"
        echo "/$drive$rest"
    fi
}

# Convert CWD
cwd="$cwd_raw"
unix_cwd=""
if [[ -n "$cwd" && "$cwd" != "null" ]]; then
    unix_cwd=$(win_to_unix_path "$cwd")
fi
printf "cwd original: %s\n" "$cwd"
printf "cwd converted (unix_cwd): %s\n" "$unix_cwd"
printf "unix_cwd exists: %s\n" "$([[ -d "$unix_cwd" ]] && echo "YES" || echo "NO")"
printf "unix_cwd/.git exists: %s\n" "$([[ -d "$unix_cwd/.git" ]] && echo "YES" || echo "NO")"

# Convert transcript path
transcript_path="$transcript_raw"
unix_transcript=""
if [[ -n "$transcript_path" && "$transcript_path" != "null" ]]; then
    unix_transcript=$(win_to_unix_path "$transcript_path")
fi
printf "transcript original: %s\n" "$transcript_path"
printf "transcript converted: %s\n" "$unix_transcript"
printf "unix_transcript exists: %s\n" "$([[ -f "$unix_transcript" ]] && echo "YES" || echo "NO")"

# ============================================================================
# SECTION 6: GIT INFORMATION
# ============================================================================
printf '%b\n' "${C_YELLOW}=== GIT INFO ===${C_RESET}"

branch=""
git_head_path="$unix_cwd/.git/HEAD"

# Method 1: Direct .git/HEAD read
printf "Trying .git/HEAD at: %s\n" "$git_head_path"
if [[ -f "$git_head_path" ]]; then
    head_content=$(cat "$git_head_path" 2>/dev/null)
    printf ".git/HEAD content: %s\n" "$head_content"
    if [[ "$head_content" == ref:* ]]; then
        branch=$(echo "$head_content" | sed 's|ref: refs/heads/||')
        printf "Branch from HEAD: %s\n" "$branch"
    else
        branch="${head_content:0:7}"
        printf "Detached HEAD SHA: %s\n" "$branch"
    fi
else
    printf ".git/HEAD: NOT FOUND\n"
fi

# Method 2: git command
if [[ -z "$branch" && -d "$unix_cwd" ]]; then
    branch_cmd=$(cd "$unix_cwd" 2>/dev/null && git branch --show-current 2>&1)
    printf "git branch --show-current output: %s\n" "$branch_cmd"
    if [[ -n "$branch_cmd" && ! "$branch_cmd" =~ ^fatal ]]; then
        branch="$branch_cmd"
    fi
fi

printf "Final branch value: %s\n" "${branch:-<empty>}"

# ============================================================================
# SECTION 7: CONTEXT WINDOW DETAILS
# ============================================================================
printf '%b\n' "${C_YELLOW}=== CONTEXT WINDOW ===${C_RESET}"

max_context=$(echo "$input" | jq -r '.context_window.context_window_size // 200000' 2>/dev/null)
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // "null"' 2>/dev/null)
total_input=$(echo "$input" | jq -r '.context_window.total_input_tokens // "null"' 2>/dev/null)
total_output=$(echo "$input" | jq -r '.context_window.total_output_tokens // "null"' 2>/dev/null)
current_input=$(echo "$input" | jq -r '.context_window.current_usage.input_tokens // "null"' 2>/dev/null)
cache_read=$(echo "$input" | jq -r '.context_window.current_usage.cache_read_input_tokens // "null"' 2>/dev/null)
cache_create=$(echo "$input" | jq -r '.context_window.current_usage.cache_creation_input_tokens // "null"' 2>/dev/null)

printf "context_window_size: %s\n" "$max_context"
printf "used_percentage: %s\n" "$used_pct"
printf "total_input_tokens: %s\n" "$total_input"
printf "total_output_tokens: %s\n" "$total_output"
printf "current_usage.input_tokens: %s\n" "$current_input"
printf "current_usage.cache_read_input_tokens: %s\n" "$cache_read"
printf "current_usage.cache_creation_input_tokens: %s\n" "$cache_create"

# Calculate percentage
pct=""
pct_method="none"

if [[ -n "$used_pct" && "$used_pct" != "null" && "$used_pct" != "0" ]]; then
    pct=$(echo "$used_pct" | cut -d. -f1)
    pct_method="used_percentage"
fi

if [[ -z "$pct" || "$pct" == "0" ]]; then
    if [[ "$current_input" != "null" ]]; then
        ci=${current_input:-0}
        cr=${cache_read:-0}
        cc=${cache_create:-0}
        [[ "$cr" == "null" ]] && cr=0
        [[ "$cc" == "null" ]] && cc=0
        total=$((ci + cr + cc))
        if [[ "$total" -gt 0 ]]; then
            pct=$((total * 100 / max_context))
            pct_method="current_usage"
        fi
    fi
fi

if [[ -z "$pct" || "$pct" == "0" ]]; then
    if [[ "$total_input" != "null" && "$total_input" -gt 0 ]] 2>/dev/null; then
        pct=$((total_input * 100 / max_context))
        pct_method="total_input"
    fi
fi

printf "Calculated pct: %s%% (method: %s)\n" "${pct:-0}" "$pct_method"

# ============================================================================
# SECTION 8: TRANSCRIPT FILE ANALYSIS
# ============================================================================
printf '%b\n' "${C_YELLOW}=== TRANSCRIPT ANALYSIS ===${C_RESET}"

if [[ -f "$unix_transcript" ]]; then
    printf "Transcript file size: %s bytes\n" "$(wc -c < "$unix_transcript")"
    printf "Transcript line count: %s\n" "$(wc -l < "$unix_transcript")"
    printf "First 200 chars:\n"
    head -c 200 "$unix_transcript"
    printf "\n"

    # Try to parse transcript
    transcript_tokens=$(jq -s '
        map(select(.message.usage and .isSidechain != true and .isApiErrorMessage != true)) |
        last |
        if . then
            (.message.usage.input_tokens // 0) +
            (.message.usage.cache_read_input_tokens // 0) +
            (.message.usage.cache_creation_input_tokens // 0)
        else 0 end
    ' < "$unix_transcript" 2>&1)
    printf "Transcript token calc result: %s\n" "$transcript_tokens"
else
    printf "Transcript file: NOT ACCESSIBLE\n"
fi

# ============================================================================
# SECTION 9: COST INFORMATION
# ============================================================================
printf '%b\n' "${C_YELLOW}=== COST ===${C_RESET}"

cost_usd=$(echo "$input" | jq -r '.cost.total_cost_usd // "null"' 2>/dev/null)
printf "total_cost_usd: %s\n" "$cost_usd"

# ============================================================================
# SECTION 10: OAUTH TOKEN CHECK
# ============================================================================
printf '%b\n' "${C_YELLOW}=== OAUTH ===${C_RESET}"

oauth_token=""
if [[ -n "${CLAUDE_CODE_OAUTH_TOKEN:-}" ]]; then
    oauth_token="${CLAUDE_CODE_OAUTH_TOKEN:0:20}..."
    printf "OAuth from env: %s\n" "$oauth_token"
fi

creds_file="$HOME/.claude/.credentials.json"
if [[ -f "$creds_file" ]]; then
    printf "Credentials file exists: YES\n"
    tok=$(jq -r '.claudeAiOauth.accessToken // "null"' "$creds_file" 2>/dev/null)
    if [[ -n "$tok" && "$tok" != "null" ]]; then
        printf "OAuth from credentials: %s...\n" "${tok:0:20}"
        oauth_token="$tok"
    else
        printf "OAuth from credentials: NOT FOUND in file\n"
    fi
else
    printf "Credentials file: NOT FOUND at %s\n" "$creds_file"
fi

# ============================================================================
# SECTION 11: FINAL STATUS LINE (what would be shown)
# ============================================================================
printf '%b\n' "${C_YELLOW}=== FINAL OUTPUT ===${C_RESET}"

model="${model_display:-${model_id:-?}}"
dir=$(basename "$cwd" 2>/dev/null || echo "?")

printf "Model: %s\n" "$model"
printf "Dir: %s\n" "$dir"
printf "Branch: %s\n" "${branch:-<none>}"
printf "Context: %s%% of %sk\n" "${pct:-~10}" "$((max_context / 1000))"

# ============================================================================
# SECTION 12: FULL INPUT JSON (truncated)
# ============================================================================
printf '%b\n' "${C_YELLOW}=== FULL INPUT (first 2000 chars) ===${C_RESET}"
echo "$input" | head -c 2000
printf "\n"
