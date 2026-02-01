---
name: mp-gemini-fetch
description: Fetch content from sites Claude cannot access (Reddit, etc.) using Gemini CLI as fallback.
disable-model-invocation: true
allowed-tools: Bash, Read, Write
---

# Gemini CLI Fetch

Fetches content from websites that Claude cannot directly access using Gemini CLI as a fallback.

## Prerequisites

- Gemini CLI must be installed: `npm install -g @anthropic/gemini-cli` or equivalent
- Gemini must be authenticated (run `gemini auth` first)

## Usage

Invoke with a URL:
```
/mp-gemini-fetch https://reddit.com/r/programming/top
```

## Workflow

### Step 1: Validate URL

Check if the URL is provided and valid.

### Step 2: Execute Gemini CLI (Windows-compatible)

Use Node.js child_process for Windows compatibility:

```bash
node -e "const {execSync} = require('child_process'); console.log(execSync('gemini \"Fetch and summarize the content from: [URL]\"', {encoding:'utf8', timeout:60000}))"
```

Alternative direct execution:
```bash
gemini "Fetch and summarize the main content from this URL: [URL]. Include key points, any code snippets, and relevant discussion highlights."
```

### Step 3: Capture Output

Parse the Gemini response and format it for use.

### Step 4: Return Results

Present the fetched content to the user:

> "**Fetched from:** [URL]
>
> **Content:**
> [Gemini's summary/content]
>
> **Note:** This content was fetched via Gemini CLI as a fallback."

## Common Use Cases

- Reddit threads (blocked by default)
- Sites with aggressive bot detection
- Content behind soft paywalls
- Forums and discussion boards

## Error Handling

If Gemini CLI fails:
1. Check if Gemini is installed: `gemini --version`
2. Check authentication: `gemini auth`
3. Try with simpler prompt
4. Report error to user with troubleshooting steps

## Notes

- This is a fallback for sites Claude cannot access directly
- Gemini CLI must be installed and authenticated separately
- Response quality depends on Gemini's access to the site
- Some sites may still be inaccessible
