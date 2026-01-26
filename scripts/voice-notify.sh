#!/bin/bash
# voice-notify.sh - Cross-platform TTS wrapper
# v1.0: macOS + Linux support

set -euo pipefail

TEXT="${1:-Done}"

# Skip if muted
MUTE_FILE="${HOME}/.voice-notify-muted"
if [[ -f "$MUTE_FILE" ]]; then
    exit 0
fi

# Handle mute/unmute commands
if [[ "$TEXT" == "muted" ]]; then
    touch "$MUTE_FILE"
    TEXT="Voice muted"
elif [[ "$TEXT" == "voice enabled" ]]; then
    rm -f "$MUTE_FILE"
fi

# Detect OS and use appropriate TTS
case "$(uname -s)" in
    Darwin)
        # macOS - use built-in 'say' command
        say "$TEXT" &
        ;;
    Linux)
        # Linux - prefer espeak-ng, fallback to espeak
        if command -v espeak-ng &> /dev/null; then
            espeak-ng "$TEXT" &
        elif command -v espeak &> /dev/null; then
            espeak "$TEXT" &
        else
            echo "Error: No TTS engine found. Install espeak-ng:" >&2
            echo "  sudo apt install espeak-ng" >&2
            exit 1
        fi
        ;;
    MINGW*|MSYS*|CYGWIN*)
        # Windows (Git Bash, MSYS, Cygwin) - planned for v1.1
        echo "Windows support coming in v1.1" >&2
        echo "For now, use PowerShell: Add-Type -AssemblyName System.Speech; (New-Object System.Speech.Synthesis.SpeechSynthesizer).Speak('$TEXT')" >&2
        ;;
    *)
        echo "Unsupported OS: $(uname -s)" >&2
        exit 1
        ;;
esac
