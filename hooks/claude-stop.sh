#!/bin/bash
# claude-stop.sh - Claude Code Stop hook for voice notifications
# Triggered after Claude Code completes a response

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VOICE_SCRIPT="${SCRIPT_DIR}/../scripts/voice-notify.sh"

# Source sanitization library
source "${SCRIPT_DIR}/../scripts/sanitize.sh"

# Read hook data from stdin (JSON with transcript_path, etc.)
HOOK_DATA=$(cat)

# Extract transcript path from hook data
TRANSCRIPT_PATH=$(echo "$HOOK_DATA" | grep -o '"transcript_path"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*: *"\([^"]*\)".*/\1/' || echo "")

# Default message
MESSAGE="Done"

if [[ -n "$TRANSCRIPT_PATH" && -f "$TRANSCRIPT_PATH" ]]; then
    # Get the last assistant response from transcript
    LAST_CONTENT=$(tail -100 "$TRANSCRIPT_PATH" 2>/dev/null || echo "")

    # Extract voice marker if present
    if echo "$LAST_CONTENT" | grep -q '<!-- VOICE:'; then
        MESSAGE=$(echo "$LAST_CONTENT" | grep -o '<!-- VOICE:[^>]*-->' | tail -1 | sed 's/<!-- VOICE: *\(.*\) *-->/\1/' | sed 's/^ *//;s/ *$//')
    else
        # Fallback: extract raw text and find first sentence
        RAW_TEXT=$(echo "$LAST_CONTENT" | grep -o '"text":"[^"]*"' | tail -1 | sed 's/"text":"//;s/"$//' | sed 's/\\n/ /g' | sed 's/\\"/"/g' || echo "")
        if [[ -n "$RAW_TEXT" ]]; then
            MESSAGE=$(extract_first_sentence "$RAW_TEXT")
        fi
    fi
fi

# Speak the message
if [[ -x "$VOICE_SCRIPT" ]]; then
    "$VOICE_SCRIPT" "$MESSAGE"
else
    chmod +x "$VOICE_SCRIPT"
    "$VOICE_SCRIPT" "$MESSAGE"
fi
