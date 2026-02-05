---
name: voice-notify
description: Audio notifications after agent responses. End responses with <!-- VOICE: summary --> for custom speech. Say "quiet voice" to mute, "voice on" to unmute.
license: MIT
compatibility: macOS (say) and Linux (espeak-ng). Requires hook configuration per agent.
metadata:
  author: jeffscottward
  version: "1.0.0"
  platforms: macos,linux
  agents: claude-code,gemini-cli,codex-cli,opencode
---

# Voice Notify Skill

Audio notifications that speak a summary when an AI agent completes a response.

## Behavior

1. **Automatic Notifications**: After every response, the agent speaks a brief summary
2. **Custom Messages**: End any response with `<!-- VOICE: your message here -->` to speak specific text
3. **Mute Control**: Say "quiet voice" to mute, "voice on" to unmute

## Instructions for AI Agents

When this skill is active:

1. **ALWAYS** end your responses with a voice comment containing a brief summary:
   ```
   <!-- VOICE: brief 5-10 word summary of what you did -->
   ```

2. **Keep summaries concise** - spoken text should be under 15 words

3. **Examples**:
   - After fixing a bug: `<!-- VOICE: Fixed the authentication bug in login flow -->`
   - After creating files: `<!-- VOICE: Created three new component files -->`
   - After explaining code: `<!-- VOICE: Explained how the routing system works -->`

4. **Mute handling**:
   - If user says "quiet voice" or "mute voice": respond with `<!-- VOICE: muted -->` and stop adding voice comments
   - If user says "voice on" or "unmute": resume adding voice comments with `<!-- VOICE: voice enabled -->`

## Platform Support

| OS | TTS Engine | Status |
|----|------------|--------|
| macOS | `say` (built-in) | Supported |
| Linux | `espeak-ng` | Supported |
| Windows | PowerShell TTS | Planned v1.1 |

## Installation

The skill requires hook configuration for your specific CLI agent. Run the installer:

```bash
./install/install.sh
```

Or install for a specific agent:

```bash
./install/claude-code.sh   # Claude Code
./install/gemini-cli.sh    # Gemini CLI
./install/codex-cli.sh     # Codex CLI
```

## How It Works

1. A hook triggers after the agent completes a response
2. The hook script extracts the `<!-- VOICE: ... -->` marker from the response
3. If no marker is found, an intelligent fallback extracts the first natural sentence (stopping at `.`, `!`, `?`, `:`, `;`, paragraph breaks, or list starts)
4. All text is automatically sanitized before speech: URLs, file paths, git SHAs, API keys, base64 blobs, and code blocks are replaced with speakable descriptions
5. The cross-platform TTS script speaks the final text
