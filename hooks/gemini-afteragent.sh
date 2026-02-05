#!/bin/bash
# gemini-afteragent.sh - Gemini CLI AfterAgent hook for voice notifications
# Triggered after Gemini CLI completes a response

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VOICE_SCRIPT="${SCRIPT_DIR}/../scripts/voice-notify.sh"

# Source sanitization library
source "${SCRIPT_DIR}/../scripts/sanitize.sh"

# Read hook data from stdin (JSON payload from Gemini)
HOOK_DATA=$(cat)

# Default message
MESSAGE="Done"

# Try to extract response content from hook data
if echo "$HOOK_DATA" | grep -q '<!-- VOICE:'; then
    MESSAGE=$(echo "$HOOK_DATA" | grep -o '<!-- VOICE:[^>]*-->' | tail -1 | sed 's/<!-- VOICE: *\(.*\) *-->/\1/' | sed 's/^ *//;s/ *$//')
else
    # Fallback: extract text and find first sentence
    RAW_TEXT=$(echo "$HOOK_DATA" | grep -o '"text":"[^"]*"' | tail -1 | sed 's/"text":"//;s/"$//' | sed 's/\\n/ /g' | sed 's/\\"/"/g' || echo "")
    if [[ -n "$RAW_TEXT" ]]; then
        MESSAGE=$(extract_first_sentence "$RAW_TEXT")
    fi
fi

# Speak the message
if [[ -x "$VOICE_SCRIPT" ]]; then
    "$VOICE_SCRIPT" "$MESSAGE"
else
    chmod +x "$VOICE_SCRIPT"
    "$VOICE_SCRIPT" "$MESSAGE"
fi
