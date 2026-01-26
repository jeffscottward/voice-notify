#!/bin/bash
# claude-stop.sh - Claude Code Stop hook for voice notifications
# Triggered after Claude Code completes a response

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VOICE_SCRIPT="${SCRIPT_DIR}/../scripts/voice-notify.sh"

# Read hook data from stdin (JSON with transcript_path, etc.)
HOOK_DATA=$(cat)

# Extract transcript path from hook data
TRANSCRIPT_PATH=$(echo "$HOOK_DATA" | grep -o '"transcript_path"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*: *"\([^"]*\)".*/\1/' || echo "")

# Default message
MESSAGE="Done"

if [[ -n "$TRANSCRIPT_PATH" && -f "$TRANSCRIPT_PATH" ]]; then
    # Get the last assistant response from transcript
    # Look for <!-- VOICE: ... --> marker in the last few lines
    LAST_CONTENT=$(tail -100 "$TRANSCRIPT_PATH" 2>/dev/null || echo "")

    # Extract voice marker if present
    if echo "$LAST_CONTENT" | grep -q '<!-- VOICE:'; then
        # Extract the content between <!-- VOICE: and -->
        MESSAGE=$(echo "$LAST_CONTENT" | grep -o '<!-- VOICE:[^>]*-->' | tail -1 | sed 's/<!-- VOICE: *\(.*\) *-->/\1/' | sed 's/^ *//;s/ *$//')
    fi
fi

# Speak the message
if [[ -x "$VOICE_SCRIPT" ]]; then
    "$VOICE_SCRIPT" "$MESSAGE"
else
    chmod +x "$VOICE_SCRIPT"
    "$VOICE_SCRIPT" "$MESSAGE"
fi
