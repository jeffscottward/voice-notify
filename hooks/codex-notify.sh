#!/bin/bash
# codex-notify.sh - Codex CLI notify handler for voice notifications
# Triggered on agent-turn-complete event

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VOICE_SCRIPT="${SCRIPT_DIR}/../scripts/voice-notify.sh"

# Source sanitization library
source "${SCRIPT_DIR}/../scripts/sanitize.sh"

# Codex CLI notify event
EVENT_TYPE="${1:-}"

# Only handle agent-turn-complete events
if [[ "$EVENT_TYPE" != "agent-turn-complete" ]]; then
    exit 0
fi

# Read any additional data from stdin
HOOK_DATA=$(cat 2>/dev/null || echo "")

# Default message
MESSAGE="Done"

# Try to extract voice marker if content is available
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
