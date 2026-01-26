#!/bin/bash
# gemini-cli.sh - Gemini CLI hook installer
# Configures the AfterAgent hook for voice notifications

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
HOOK_SCRIPT="$ROOT_DIR/hooks/gemini-afteragent.sh"

# Gemini CLI settings location (may vary)
SETTINGS_DIRS=(
    "$HOME/gemini"
    "$HOME/.gemini"
    "$HOME/.config/gemini"
)

echo "Installing voice-notify for Gemini CLI..."

# Make hook executable
chmod +x "$HOOK_SCRIPT"
chmod +x "$ROOT_DIR/scripts/voice-notify.sh"

# Find Gemini settings directory
GEMINI_DIR=""
for dir in "${SETTINGS_DIRS[@]}"; do
    if [[ -d "$dir" ]]; then
        GEMINI_DIR="$dir"
        break
    fi
done

if [[ -z "$GEMINI_DIR" ]]; then
    # Create default directory
    GEMINI_DIR="$HOME/.gemini"
    mkdir -p "$GEMINI_DIR"
    echo "✓ Created $GEMINI_DIR"
fi

SETTINGS_FILE="$GEMINI_DIR/settings.json"

if [[ -f "$SETTINGS_FILE" ]]; then
    # Backup existing settings
    cp "$SETTINGS_FILE" "${SETTINGS_FILE}.backup"
    echo "✓ Backed up existing settings"

    if grep -q '"hooks"' "$SETTINGS_FILE"; then
        echo ""
        echo "⚠ Hooks already configured in settings.json"
        echo "  Please add the AfterAgent hook manually:"
        echo ""
        echo '  "AfterAgent": ['
        echo "    \"$HOOK_SCRIPT\""
        echo '  ]'
        exit 0
    fi

    if command -v jq &> /dev/null; then
        jq --arg hook "$HOOK_SCRIPT" '.hooks = (.hooks // {}) | .hooks.AfterAgent = [$hook]' "$SETTINGS_FILE" > "${SETTINGS_FILE}.tmp"
        mv "${SETTINGS_FILE}.tmp" "$SETTINGS_FILE"
        echo "✓ Added AfterAgent hook to settings.json"
    else
        echo ""
        echo "⚠ jq not installed. Add hooks manually to $SETTINGS_FILE:"
        echo ""
        echo '  "hooks": {'
        echo '    "AfterAgent": ['
        echo "      \"$HOOK_SCRIPT\""
        echo '    ]'
        echo '  }'
        exit 0
    fi
else
    cat > "$SETTINGS_FILE" << EOF
{
  "hooks": {
    "AfterAgent": [
      "$HOOK_SCRIPT"
    ]
  }
}
EOF
    echo "✓ Created settings.json with AfterAgent hook"
fi

echo ""
echo "✓ Gemini CLI voice-notify installed!"
echo ""
echo "The hook will trigger after each agent response."
