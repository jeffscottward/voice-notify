#!/bin/bash
# codex-cli.sh - Codex CLI hook installer
# Configures the notify handler for voice notifications

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
HOOK_SCRIPT="$ROOT_DIR/hooks/codex-notify.sh"
CONFIG_FILE="$HOME/.config/codex/config.toml"
CONFIG_DIR="$HOME/.config/codex"

echo "Installing voice-notify for Codex CLI..."

# Make hook executable
chmod +x "$HOOK_SCRIPT"
chmod +x "$ROOT_DIR/scripts/voice-notify.sh"

# Ensure config directory exists
mkdir -p "$CONFIG_DIR"

if [[ -f "$CONFIG_FILE" ]]; then
    # Backup existing config
    cp "$CONFIG_FILE" "${CONFIG_FILE}.backup"
    echo "✓ Backed up existing config to ${CONFIG_FILE}.backup"

    # Check if notify already configured
    if grep -q '\[notify\]' "$CONFIG_FILE"; then
        echo ""
        echo "⚠ [notify] section already exists in config.toml"
        echo "  Please add the following manually:"
        echo ""
        echo "  [notify]"
        echo "  agent-turn-complete = \"$HOOK_SCRIPT\""
        exit 0
    fi

    # Append notify configuration
    cat >> "$CONFIG_FILE" << EOF

[notify]
agent-turn-complete = "$HOOK_SCRIPT"
EOF
    echo "✓ Added notify configuration to config.toml"
else
    # Create new config.toml
    cat > "$CONFIG_FILE" << EOF
# Codex CLI Configuration

[notify]
agent-turn-complete = "$HOOK_SCRIPT"
EOF
    echo "✓ Created config.toml with notify handler"
fi

echo ""
echo "✓ Codex CLI voice-notify installed!"
echo ""
echo "The notify handler will trigger on agent-turn-complete events."
