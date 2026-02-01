# Claude Code Status Line - WSL Compatibility Fixes

## Environment

| Component | Value |
|-----------|-------|
| Host OS | Windows |
| Claude Code | Runs from PowerShell (`claude` command) |
| Status Script | Executed in **WSL:Ubuntu** (not Git Bash) |
| Shell | `/bin/bash` (WSL) |
| OSTYPE | `linux-gnu` |

**Key insight**: Claude Code on Windows invokes bash scripts through WSL, but provides Windows-style paths in the JSON input.

## The Problem

Claude Code sends paths like:
```json
{
  "cwd": "C:\\Users\\snapy",
  "transcript_path": "C:\\Users\\snapy\\.claude\\projects\\..."
}
```

WSL cannot access these paths directly. It needs:
```
/mnt/c/Users/snapy
```

## Fixes Applied

### 1. Path Conversion Function

```bash
win_to_unix_path() {
    local path="$1"
    [[ -z "$path" || "$path" == "null" ]] && return

    # Already Unix path
    if [[ ! "$path" =~ ^[A-Za-z]:\\ && ! "$path" =~ ^[A-Za-z]:/ ]]; then
        echo "$path"
        return
    fi

    # Use wslpath if available
    if command -v wslpath >/dev/null 2>&1; then
        wslpath -u "$path" 2>/dev/null && return
    fi

    # Manual conversion for WSL
    if [[ -d "/mnt/c" ]]; then
        local drive="${path:0:1}"
        drive="${drive,,}"
        local rest="${path:2}"
        rest="${rest//\\//}"
        rest="${rest#/}"
        echo "/mnt/$drive/$rest"
    fi
}
```

### 2. Directory Basename Extraction

**Before** (broken):
```bash
dir=$(basename "$cwd")  # Returns "C:\Users\snapy" unchanged
```

**After** (fixed):
```bash
dir=$(echo "$cwd" | sed 's|.*[/\\]||')  # Returns "snapy"
```

### 3. Convert Paths Before Use

```bash
unix_cwd=$(win_to_unix_path "$cwd")
unix_transcript=$(win_to_unix_path "$transcript_path")

# Then use unix_cwd for git operations
if [[ -d "$unix_cwd" ]]; then
    git_head="$unix_cwd/.git/HEAD"
    ...
fi

# And unix_transcript for file reading
if [[ -f "$unix_transcript" ]]; then
    jq -s '...' < "$unix_transcript"
fi
```

### 4. Context Percentage - Use JSON Value First

**Before**: Only parsed transcript file (failed due to path issues)

**After**: Use `used_percentage` from input JSON as primary method:
```bash
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
if [[ -n "$used_pct" && "$used_pct" != "null" ]]; then
    pct=$(echo "$used_pct" | cut -d. -f1)
fi
```

### 5. OAuth Token Lookup for WSL

Added fallback path for WSL environment:
```bash
win_creds="/mnt/c/Users/$USER/.claude/.credentials.json"
if [[ -f "$win_creds" ]]; then
    tok=$(jq -r '.claudeAiOauth.accessToken // empty' "$win_creds")
fi
```

## Debug Script

`context-bar-debug.sh` outputs diagnostic information:
- Environment detection
- Path conversions
- JSON parsing results
- Git accessibility
- Transcript file status

To enable: Change `settings.json` statusLine command to point to `context-bar-debug.sh`.
