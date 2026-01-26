#!/bin/bash
# codex-notify.sh - Codex CLI notify handler for voice notifications
# Triggered on agent-turn-complete event

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VOICE_SCRIPT="${SCRIPT_DIR}/../scripts/voice-notify.sh"

# Codex CLI notify event
# The event type is passed as argument, content may come from stdin
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
fi

# Speak the message
if [[ -x "$VOICE_SCRIPT" ]]; then
    "$VOICE_SCRIPT" "$MESSAGE"
else
    chmod +x "$VOICE_SCRIPT"
    "$VOICE_SCRIPT" "$MESSAGE"
fi
