# Voice Notify

Audio notifications for CLI AI agents. Get spoken summaries when your agent completes a response.

## Features

- **Universal**: Works with Claude Code, Gemini CLI, Codex CLI, and OpenCode
- **Cross-Platform**: macOS (say) and Linux (espeak-ng)
- **Customizable**: Agents add `<!-- VOICE: message -->` for custom speech
- **Controllable**: Say "quiet voice" to mute, "voice on" to unmute

## Quick Install

### Using skills.sh (Vercel)
```bash
npx add-skill jeffscottward/voice-notify
```

### Using OpenSkills
```bash
npx openskills install jeffscottward/voice-notify
```

### Manual Installation
```bash
git clone https://github.com/jeffscottward/voice-notify
cd voice-notify
./install/install.sh
```

## Agent-Specific Installation

If you only want to install for one agent:

```bash
# Claude Code
./install/claude-code.sh

# Gemini CLI
./install/gemini-cli.sh

# Codex CLI
./install/codex-cli.sh
```

## Usage

Once installed, the agent will automatically speak summaries after responses. You can control it with natural language:

- **"quiet voice"** or **"mute voice"** - Mutes notifications
- **"voice on"** or **"unmute"** - Re-enables notifications

## How It Works

1. A hook triggers when the agent completes a response
2. The hook extracts `<!-- VOICE: ... -->` from the response
3. Your system's TTS engine speaks the message

### Supported Agents & Hooks

| Agent | Hook Type | Config Location |
|-------|-----------|-----------------|
| Claude Code | `Stop` hook | `~/.claude/settings.json` |
| Gemini CLI | `AfterAgent` hook | `~/gemini/settings.json` |
| Codex CLI | `notify` | `config.toml` |

## Platform Requirements

### macOS
Built-in `say` command - no installation needed.

### Linux
Requires espeak-ng:
```bash
# Debian/Ubuntu
sudo apt install espeak-ng

# Fedora
sudo dnf install espeak-ng

# Arch
sudo pacman -S espeak-ng
```

### Windows
Coming in v1.1 with PowerShell TTS support.

## File Structure

```
voice-notify/
├── SKILL.md                    # Agent skill instructions
├── README.md                   # This file
├── LICENSE                     # MIT License
├── scripts/
│   └── voice-notify.sh         # Cross-platform TTS wrapper
├── install/
│   ├── install.sh              # Interactive installer
│   ├── claude-code.sh          # Claude Code setup
│   ├── gemini-cli.sh           # Gemini CLI setup
│   └── codex-cli.sh            # Codex CLI setup
└── hooks/
    ├── claude-stop.sh          # Claude Code Stop hook
    ├── gemini-afteragent.sh    # Gemini CLI AfterAgent hook
    └── codex-notify.sh         # Codex CLI notify handler
```

## Troubleshooting

### No sound on macOS
Check that your volume is up and `say "test"` works in Terminal.

### No sound on Linux
Ensure espeak-ng is installed: `which espeak-ng`

### Hook not triggering
Verify the hook is configured in your agent's settings file.

## License

MIT License - see [LICENSE](LICENSE)

## Author

Jeff Scott Ward ([@jeffscottward](https://github.com/jeffscottward))

## Contributing

Issues and PRs welcome at [github.com/jeffscottward/voice-notify](https://github.com/jeffscottward/voice-notify)
