#!/bin/bash

# Color theme: gray, orange, blue, teal, green, lavender, rose, gold, slate, cyan
# Preview colors with: bash scripts/color-preview.sh
COLOR="blue"

# Color codes
C_RESET='\033[0m'
C_GRAY='\033[38;5;245m'  # explicit gray for default text
C_BAR_EMPTY='\033[38;5;238m'
case "$COLOR" in
    orange)   C_ACCENT='\033[38;5;173m' ;;
    blue)     C_ACCENT='\033[38;5;74m' ;;
    teal)     C_ACCENT='\033[38;5;66m' ;;
    green)    C_ACCENT='\033[38;5;71m' ;;
    lavender) C_ACCENT='\033[38;5;139m' ;;
    rose)     C_ACCENT='\033[38;5;132m' ;;
    gold)     C_ACCENT='\033[38;5;136m' ;;
    slate)    C_ACCENT='\033[38;5;60m' ;;
    cyan)     C_ACCENT='\033[38;5;37m' ;;
    *)        C_ACCENT="$C_GRAY" ;;  # gray: all same color
esac

input=$(cat)

# Helper function to convert Windows path to Unix path
# Detects WSL vs Git Bash and uses appropriate format
win_to_unix_path() {
    local path="$1"
    # Return as-is if empty or null
    [[ -z "$path" || "$path" == "null" ]] && return

    # Return as-is if already a Unix path
    if [[ ! "$path" =~ ^[A-Za-z]:\\ && ! "$path" =~ ^[A-Za-z]:/ ]]; then
        echo "$path"
        return
    fi

    # Use wslpath if available (running in WSL)
    if command -v wslpath >/dev/null 2>&1; then
        wslpath -u "$path" 2>/dev/null && return
    fi

    # Check if we're in WSL by looking for /mnt/c
    if [[ -d "/mnt/c" ]]; then
        # WSL style: C:\foo -> /mnt/c/foo
        local drive="${path:0:1}"
        drive="${drive,,}"  # lowercase
        local rest="${path:2}"
        rest="${rest//\\//}"  # backslash to forward slash
        rest="${rest#/}"      # remove leading slash if present
        echo "/mnt/$drive/$rest"
    else
        # Git Bash style: C:\foo -> /c/foo
        local drive="${path:0:1}"
        drive="${drive,,}"  # lowercase
        local rest="${path:2}"
        rest="${rest//\\//}"  # backslash to forward slash
        echo "/$drive$rest"
    fi
}

# Extract model, directory, and cwd
model=$(echo "$input" | jq -r '.model.display_name // .model.id // "?"')
cwd=$(echo "$input" | jq -r '.cwd // empty')

# Get directory basename - handle both Windows and Unix paths
if [[ -n "$cwd" ]]; then
    # For Windows paths, extract after last backslash or forward slash
    dir=$(echo "$cwd" | sed 's|.*[/\\]||')
    [[ -z "$dir" ]] && dir=$(basename "$cwd" 2>/dev/null || echo "?")
else
    dir="?"
fi

# Convert cwd to Unix path for file system operations
unix_cwd=""
if [[ -n "$cwd" ]]; then
    unix_cwd=$(win_to_unix_path "$cwd")
fi

# Git branch (compact)
branch=""
if [[ -n "$unix_cwd" && -d "$unix_cwd" ]]; then
    # Method 1: Try reading .git/HEAD directly (most reliable)
    git_head="$unix_cwd/.git/HEAD"
    if [[ -f "$git_head" ]]; then
        head_content=$(cat "$git_head" 2>/dev/null)
        if [[ "$head_content" == ref:* ]]; then
            branch=$(echo "$head_content" | sed 's|ref: refs/heads/||')
        else
            # Detached HEAD - show short SHA
            branch="${head_content:0:7}"
        fi
    fi

    # Method 2: Fallback to git command
    if [[ -z "$branch" ]]; then
        branch=$(cd "$unix_cwd" 2>/dev/null && git branch --show-current 2>/dev/null)
    fi
fi

# Transcript path for context + last message
transcript_path=$(echo "$input" | jq -r '.transcript_path // empty')
unix_transcript=""
if [[ -n "$transcript_path" ]]; then
    unix_transcript=$(win_to_unix_path "$transcript_path")
fi

# Context window size (accurate)
max_context=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')
max_k=$((max_context / 1000))

# --- Context % + bar ---
pct=""
pct_prefix=""

# Method 1: Use pre-calculated used_percentage from Claude Code (most reliable)
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
if [[ -n "$used_pct" && "$used_pct" != "null" && "$used_pct" != "0" ]]; then
    pct=$(echo "$used_pct" | cut -d. -f1)
fi

# Method 2: Calculate from current_usage tokens
if [[ -z "$pct" || "$pct" == "0" ]]; then
    current_input=$(echo "$input" | jq -r '.context_window.current_usage.input_tokens // 0')
    cache_read=$(echo "$input" | jq -r '.context_window.current_usage.cache_read_input_tokens // 0')
    cache_create=$(echo "$input" | jq -r '.context_window.current_usage.cache_creation_input_tokens // 0')

    [[ "$current_input" == "null" ]] && current_input=0
    [[ "$cache_read" == "null" ]] && cache_read=0
    [[ "$cache_create" == "null" ]] && cache_create=0

    total_tokens=$((current_input + cache_read + cache_create))
    if [[ "$total_tokens" -gt 0 ]]; then
        pct=$((total_tokens * 100 / max_context))
    fi
fi

# Method 3: Calculate from total_input_tokens
if [[ -z "$pct" || "$pct" == "0" ]]; then
    total_input=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
    if [[ "$total_input" != "null" && "$total_input" -gt 0 ]] 2>/dev/null; then
        pct=$((total_input * 100 / max_context))
    fi
fi

# Method 4: Parse transcript file (fallback)
if [[ -z "$pct" || "$pct" == "0" ]]; then
    if [[ -n "$unix_transcript" && -f "$unix_transcript" ]]; then
        context_length=$(jq -s '
            map(select(.message.usage and .isSidechain != true and .isApiErrorMessage != true)) |
            last |
            if . then
                (.message.usage.input_tokens // 0) +
                (.message.usage.cache_read_input_tokens // 0) +
                (.message.usage.cache_creation_input_tokens // 0)
            else 0 end
        ' < "$unix_transcript" 2>/dev/null)

        if [[ -n "$context_length" && "$context_length" -gt 0 ]]; then
            pct=$((context_length * 100 / max_context))
        fi
    fi
fi

# Method 5: Baseline estimate
if [[ -z "$pct" || "$pct" == "0" ]]; then
    pct=10
    pct_prefix="~"
fi

[[ $pct -gt 100 ]] && pct=100

# Build progress bar
bar_width=10
ctx_bar=""
for ((i=0; i<bar_width; i++)); do
    bar_start=$((i * 10))
    progress=$((pct - bar_start))
    if [[ $progress -ge 8 ]]; then
        ctx_bar+="${C_ACCENT}█${C_RESET}"
    elif [[ $progress -ge 3 ]]; then
        ctx_bar+="${C_ACCENT}▄${C_RESET}"
    else
        ctx_bar+="${C_BAR_EMPTY}░${C_RESET}"
    fi
done

# --- Helpers ---
progress_bar() {
    local pct="$1"
    local width="${2:-10}"
    local filled=$((pct * width / 100))
    local out=""

    for ((i=0; i<width; i++)); do
        if [[ $i -lt $filled ]]; then
            out+="${C_ACCENT}█${C_RESET}"
        else
            out+="${C_BAR_EMPTY}░${C_RESET}"
        fi
    done
    printf '%b' "$out"
}

format_pct() {
    local raw="$1"
    if [[ -z "$raw" || "$raw" == "null" ]]; then
        echo ""
        return
    fi
    printf '%.0f' "$raw" 2>/dev/null
}

round_n() {
    local num="$1"
    local dec="$2"
    LC_ALL=C awk -v n="$num" -v d="$dec" 'BEGIN{ if(n=="" || n=="null") exit 1; printf("%.*f", d, n+0) }' 2>/dev/null
}

get_oauth_token() {
    # 1) env var
    if [[ -n "${CLAUDE_CODE_OAUTH_TOKEN:-}" ]]; then
        echo "$CLAUDE_CODE_OAUTH_TOKEN"
        return
    fi

    # 2) credentials files - check both WSL and Windows paths
    local f
    for f in "$HOME/.claude/.credentials.json" "$HOME/.claude/credentials.json"; do
        if [[ -f "$f" ]]; then
            local tok
            tok=$(jq -r '.claudeAiOauth.accessToken // empty' "$f" 2>/dev/null)
            if [[ -n "$tok" ]]; then
                echo "$tok"
                return
            fi
        fi
    done

    # 3) Try Windows path via WSL
    local win_creds="/mnt/c/Users/$USER/.claude/.credentials.json"
    if [[ -f "$win_creds" ]]; then
        local tok
        tok=$(jq -r '.claudeAiOauth.accessToken // empty' "$win_creds" 2>/dev/null)
        if [[ -n "$tok" ]]; then
            echo "$tok"
            return
        fi
    fi

    # 4) macOS Keychain
    if command -v security >/dev/null 2>&1; then
        local creds
        creds=$(security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null)
        if [[ -n "$creds" && "$creds" != "null" ]]; then
            local tok
            tok=$(echo "$creds" | jq -r '.claudeAiOauth.accessToken // empty' 2>/dev/null)
            if [[ -n "$tok" ]]; then
                echo "$tok"
                return
            fi
        fi
    fi
}

fetch_usage_json() {
    local token="$1"
    [[ -z "$token" ]] && return 1

    curl -s --max-time 1 "https://api.anthropic.com/api/oauth/usage" \
        -H "Accept: application/json" \
        -H "Authorization: Bearer $token" \
        -H "anthropic-beta: oauth-2025-04-20" 2>/dev/null
}

fetch_usd_czk_rate() {
    curl -s --max-time 1 "https://api.frankfurter.dev/v1/latest?base=USD&symbols=CZK" 2>/dev/null | jq -r '.rates.CZK // empty' 2>/dev/null
}

# --- Session token + cost (from statusLine JSON) ---
session_tokens_in=$(echo "$input" | jq -r '.context_window.total_input_tokens // empty' 2>/dev/null)
session_tokens_out=$(echo "$input" | jq -r '.context_window.total_output_tokens // empty' 2>/dev/null)
session_cost_usd_raw=$(echo "$input" | jq -r '.cost.total_cost_usd // empty' 2>/dev/null)

session_tokens_total=""
if [[ -n "$session_tokens_in" && -n "$session_tokens_out" ]]; then
    if [[ "$session_tokens_in" =~ ^[0-9]+$ && "$session_tokens_out" =~ ^[0-9]+$ ]]; then
        session_tokens_total=$((session_tokens_in + session_tokens_out))
    fi
fi

usd_disp=""
czk_disp=""
if [[ -n "$session_cost_usd_raw" && "$session_cost_usd_raw" != "null" ]]; then
    usd_disp=$(round_n "$session_cost_usd_raw" 3)
    if [[ -n "$usd_disp" ]]; then
        rate=$(fetch_usd_czk_rate)
        if [[ -n "$rate" && "$rate" != "null" ]]; then
            czk_val=$(LC_ALL=C awk -v u="$usd_disp" -v r="$rate" 'BEGIN{ printf("%.2f", (u+0)*(r+0)) }' 2>/dev/null)
            if [[ -n "$czk_val" ]]; then
                czk_disp="${czk_val}Kč"
            fi
        fi
    fi
fi

# --- Quota utilization (5h + 7d) ---
quota_line=""
TOKEN=$(get_oauth_token)
USAGE_DATA=""
if [[ -n "$TOKEN" ]]; then
    USAGE_DATA=$(fetch_usage_json "$TOKEN")
fi

aerr=$(echo "$USAGE_DATA" | jq -r '.error.type // empty' 2>/dev/null)
if [[ -z "$aerr" ]]; then
    five_raw=$(echo "$USAGE_DATA" | jq -r '.five_hour.utilization // empty' 2>/dev/null)
    seven_raw=$(echo "$USAGE_DATA" | jq -r '.seven_day.utilization // empty' 2>/dev/null)

    five_pct=$(format_pct "$five_raw")
    seven_pct=$(format_pct "$seven_raw")

    if [[ -n "$five_pct" && "$five_pct" =~ ^[0-9]+$ ]]; then
        [[ $five_pct -gt 100 ]] && five_pct=100
        five_bar=$(progress_bar "$five_pct" 8)
        quota_line="${C_GRAY}5h ${five_bar} ${five_pct}%"

        if [[ -n "$seven_pct" && "$seven_pct" =~ ^[0-9]+$ ]]; then
            [[ $seven_pct -gt 100 ]] && seven_pct=100
            seven_bar=$(progress_bar "$seven_pct" 8)
            quota_line+="${C_GRAY} | 7d ${seven_bar} ${seven_pct}%"
        else
            quota_line+="${C_GRAY} | 7d n/a"
        fi
        quota_line+="${C_RESET}"
    fi
else
    if [[ "$aerr" == "permission_error" ]]; then
        quota_line="${C_GRAY}5h n/a | 7d n/a${C_RESET}"
    else
        quota_line="${C_GRAY}5h n/a | 7d n/a${C_RESET}"
    fi
fi

# --- Build 3-line status output ---
line1="${C_ACCENT}${model}${C_GRAY} | 📁${dir}"
[[ -n "$branch" ]] && line1+=" | 🔀${branch}"
line1+="${C_RESET}"

line2="${C_GRAY}🔥 ${ctx_bar} ${pct_prefix}${pct}% of ${max_k}k tokens"
if [[ -n "$usd_disp" ]]; then
    line2+=" | \$${usd_disp}"
    [[ -n "$czk_disp" ]] && line2+=" | ${czk_disp}"
fi
line2+="${C_RESET}"

line3=""
if [[ -n "$quota_line" ]]; then
    line3="$quota_line"
fi

printf '%b\n' "$line1"
printf '%b\n' "$line2"
[[ -n "$line3" ]] && printf '%b\n' "$line3"

# --- Last user message (text only) ---
if [[ -n "$unix_transcript" && -f "$unix_transcript" ]]; then
    plain_line1="${model} | ${dir}"
    [[ -n "$branch" ]] && plain_line1+=" | ${branch}"
    max_len=${#plain_line1}

    last_user_msg=$(jq -rs '
        def is_unhelpful:
            startswith("[Request interrupted") or
            startswith("[Request cancelled") or
            . == "";

        [.[] | select(.type == "user") |
         select(.message.content | type == "string" or
                (type == "array" and any(.[]; .type == "text")))] |
        reverse |
        map(.message.content |
            if type == "string" then .
            else [.[] | select(.type == "text") | .text] | join(" ") end |
            gsub("\n"; " ") | gsub("  +"; " ")) |
        map(select(is_unhelpful | not)) |
        first // ""
    ' < "$unix_transcript" 2>/dev/null)

    if [[ -n "$last_user_msg" ]]; then
        if [[ ${#last_user_msg} -gt $max_len ]]; then
            echo "💬 ${last_user_msg:0:$((max_len - 3))}..."
        else
            echo "💬 ${last_user_msg}"
        fi
    fi
fi
