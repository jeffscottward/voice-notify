#!/bin/bash
# install.sh - Interactive installer for voice-notify
# Detects installed CLI agents and configures hooks

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

echo "╔════════════════════════════════════════════╗"
echo "║       Voice Notify Installer v1.0.0        ║"
echo "╚════════════════════════════════════════════╝"
echo ""

# Detect OS
OS="$(uname -s)"
case "$OS" in
    Darwin)
        echo "✓ Detected macOS - using 'say' for TTS"
        ;;
    Linux)
        echo "✓ Detected Linux"
        if command -v espeak-ng &> /dev/null; then
            echo "✓ espeak-ng is installed"
        elif command -v espeak &> /dev/null; then
            echo "✓ espeak is installed (espeak-ng recommended)"
        else
            echo "⚠ No TTS engine found. Please install espeak-ng:"
            echo "  sudo apt install espeak-ng"
            exit 1
        fi
        ;;
    *)
        echo "⚠ Unsupported OS: $OS"
        echo "  Windows support coming in v1.1"
        exit 1
        ;;
esac

echo ""
echo "Detecting installed CLI agents..."
echo ""

# Track detected agents
AGENTS_FOUND=()

# Check for Claude Code
if command -v claude &> /dev/null || [[ -d "$HOME/.claude" ]]; then
    echo "✓ Claude Code detected"
    AGENTS_FOUND+=("claude-code")
else
    echo "○ Claude Code not detected"
fi

# Check for Gemini CLI
if command -v gemini &> /dev/null || [[ -d "$HOME/gemini" ]] || [[ -d "$HOME/.gemini" ]]; then
    echo "✓ Gemini CLI detected"
    AGENTS_FOUND+=("gemini-cli")
else
    echo "○ Gemini CLI not detected"
fi

# Check for Codex CLI
if command -v codex &> /dev/null || [[ -f "$HOME/.config/codex/config.toml" ]]; then
    echo "✓ Codex CLI detected"
    AGENTS_FOUND+=("codex-cli")
else
    echo "○ Codex CLI not detected"
fi

# Check for OpenCode
if command -v opencode &> /dev/null; then
    echo "✓ OpenCode detected"
    AGENTS_FOUND+=("opencode")
else
    echo "○ OpenCode not detected"
fi

echo ""

if [[ ${#AGENTS_FOUND[@]} -eq 0 ]]; then
    echo "No supported CLI agents detected."
    echo "You can still install manually for:"
    echo "  - Claude Code:  ./install/claude-code.sh"
    echo "  - Gemini CLI:   ./install/gemini-cli.sh"
    echo "  - Codex CLI:    ./install/codex-cli.sh"
    exit 0
fi

echo "Select agents to configure (space-separated numbers, or 'all'):"
echo ""

i=1
for agent in "${AGENTS_FOUND[@]}"; do
    echo "  $i) $agent"
    ((i++))
done

echo ""
read -rp "Selection: " SELECTION

# Parse selection
SELECTED_AGENTS=()
if [[ "$SELECTION" == "all" ]]; then
    SELECTED_AGENTS=("${AGENTS_FOUND[@]}")
else
    for num in $SELECTION; do
        idx=$((num - 1))
        if [[ $idx -ge 0 && $idx -lt ${#AGENTS_FOUND[@]} ]]; then
            SELECTED_AGENTS+=("${AGENTS_FOUND[$idx]}")
        fi
    done
fi

if [[ ${#SELECTED_AGENTS[@]} -eq 0 ]]; then
    echo "No agents selected. Exiting."
    exit 0
fi

echo ""
echo "Installing for: ${SELECTED_AGENTS[*]}"
echo ""

# Make scripts executable
chmod +x "$ROOT_DIR/scripts/voice-notify.sh"
chmod +x "$ROOT_DIR/hooks/"*.sh

# Install for each selected agent
for agent in "${SELECTED_AGENTS[@]}"; do
    case "$agent" in
        claude-code)
            echo "Installing Claude Code hook..."
            "$SCRIPT_DIR/claude-code.sh"
            ;;
        gemini-cli)
            echo "Installing Gemini CLI hook..."
            "$SCRIPT_DIR/gemini-cli.sh"
            ;;
        codex-cli)
            echo "Installing Codex CLI hook..."
            "$SCRIPT_DIR/codex-cli.sh"
            ;;
        opencode)
            echo "⚠ OpenCode configuration: Manual setup required"
            echo "  Add the Stop hook script to your OpenCode configuration"
            ;;
    esac
    echo ""
done

echo "╔════════════════════════════════════════════╗"
echo "║         Installation Complete!             ║"
echo "╚════════════════════════════════════════════╝"
echo ""
echo "Test it by running your CLI agent and checking for audio."
echo ""
echo "Commands:"
echo "  'quiet voice' - Mute notifications"
echo "  'voice on'    - Enable notifications"
