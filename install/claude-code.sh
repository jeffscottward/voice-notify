#!/bin/bash
# claude-code.sh - Claude Code hook installer
# Configures the Stop hook for voice notifications

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
HOOK_SCRIPT="$ROOT_DIR/hooks/claude-stop.sh"
SETTINGS_FILE="$HOME/.claude/settings.json"

echo "Installing voice-notify for Claude Code..."

# Ensure .claude directory exists
mkdir -p "$HOME/.claude"

# Make hook executable
chmod +x "$HOOK_SCRIPT"
chmod +x "$ROOT_DIR/scripts/voice-notify.sh"

# Check if settings.json exists
if [[ -f "$SETTINGS_FILE" ]]; then
    # Backup existing settings
    cp "$SETTINGS_FILE" "${SETTINGS_FILE}.backup"
    echo "✓ Backed up existing settings to ${SETTINGS_FILE}.backup"

    # Check if hooks already configured
    if grep -q '"hooks"' "$SETTINGS_FILE"; then
        echo ""
        echo "⚠ Hooks already configured in settings.json"
        echo "  Please add the following Stop hook manually:"
        echo ""
        echo '  "Stop": ['
        echo "    \"$HOOK_SCRIPT\""
        echo '  ]'
        echo ""
        echo "  Or merge with existing hooks."
        exit 0
    fi

    # Add hooks to existing settings
    # This is a simple append - for complex JSON manipulation, use jq
    if command -v jq &> /dev/null; then
        # Use jq if available
        jq --arg hook "$HOOK_SCRIPT" '.hooks = (.hooks // {}) | .hooks.Stop = [$hook]' "$SETTINGS_FILE" > "${SETTINGS_FILE}.tmp"
        mv "${SETTINGS_FILE}.tmp" "$SETTINGS_FILE"
        echo "✓ Added Stop hook to settings.json"
    else
        echo ""
        echo "⚠ jq not installed. Please add hooks manually to $SETTINGS_FILE:"
        echo ""
        echo '  "hooks": {'
        echo '    "Stop": ['
        echo "      \"$HOOK_SCRIPT\""
        echo '    ]'
        echo '  }'
        exit 0
    fi
else
    # Create new settings.json
    cat > "$SETTINGS_FILE" << EOF
{
  "hooks": {
    "Stop": [
      "$HOOK_SCRIPT"
    ]
  }
}
EOF
    echo "✓ Created settings.json with Stop hook"
fi

echo ""
echo "✓ Claude Code voice-notify installed!"
echo ""
echo "The hook will trigger after each response."
echo "Add <!-- VOICE: message --> to responses for custom speech."
