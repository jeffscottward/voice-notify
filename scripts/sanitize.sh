#!/bin/bash
# sanitize.sh - Shared text sanitization library for voice-notify
# Sources: all hooks and the TTS wrapper use these functions
# Uses Python for reliable cross-platform text processing

# sanitize_for_speech()
# Strips non-speakable content from text for TTS output
# Usage: result=$(sanitize_for_speech "text with URLs and code")
sanitize_for_speech() {
    local text="$1"
    python3 -c "
import sys, re

text = sys.stdin.read()

# Strip code blocks
text = re.sub(r'\`\`\`[\s\S]*?\`\`\`', '', text)
# Strip inline code
text = re.sub(r'\`[^\`]*\`', '', text)
# Replace URLs with 'a link'
text = re.sub(r'https?://\S+', 'a link', text)
# Replace API key patterns (before hash detection to avoid partial matches)
text = re.sub(r'(?:sk|pk|api|key)[-_][A-Za-z0-9_-]{16,}', 'an API key', text)
# Replace file paths with just filename
text = re.sub(r'(?:\.{0,2}/|~/)(?:[^\s/]+/)+([^\s/]+)', r'\1', text)
# Replace hex hashes >8 chars with 'a hash'
text = re.sub(r'\b[0-9a-f]{9,}\b', 'a hash', text)
# Replace base64 blobs with 'encoded data'
text = re.sub(r'[A-Za-z0-9+/=]{40,}', 'encoded data', text)
# Strip markdown formatting
text = re.sub(r'\*\*([^*]*)\*\*', r'\1', text)
text = re.sub(r'\*([^*]*)\*', r'\1', text)
text = re.sub(r'^#{1,6}\s+', '', text, flags=re.MULTILINE)
text = re.sub(r'\[([^\]]*)\]\([^)]*\)', r'\1', text)
# Collapse whitespace
text = text.replace('\n', ' ')
text = re.sub(r'\s+', ' ', text).strip()
# Truncate at ~150 chars on word boundary
if len(text) > 150:
    text = text[:150].rsplit(' ', 1)[0] + '...'
# Fallback if empty
if len(text) < 3:
    text = 'Done'
print(text)
" <<< "$text"
}

# extract_first_sentence()
# Finds the first natural sentence from text.
# Stops at: . ! ? : ; paragraph break (\n\n) or list start (\n- or \n1.)
# Usage: result=$(extract_first_sentence "some long text here")
extract_first_sentence() {
    local text="$1"
    python3 -c "
import sys, re

text = sys.stdin.read().strip()
if not text:
    print('Done')
    sys.exit(0)

# Strip code blocks
text = re.sub(r'\`\`\`[\s\S]*?\`\`\`', '', text)
text = re.sub(r'\`[^\`]*\`', '', text)
text = text.strip()

if not text:
    print('Done')
    sys.exit(0)

# Split on paragraph breaks first
parts = re.split(r'\n\s*\n', text)
text = parts[0].strip() if parts else text

# Split on list starts (newline followed by - or digit.)
text = re.split(r'\n\s*[-*]|\n\s*[0-9]+\.', text)[0].strip()

# Neutralize URLs before sentence boundary detection (colons in URLs aren't terminators)
text_for_scan = re.sub(r'https?://\S+', 'LINK', text)

# Find first sentence terminator (. ! ? : ;) with min 10 chars before it
best = len(text_for_scan)
for term in ['. ', '.\n', '!', '?', ':', ';']:
    idx = text_for_scan.find(term)
    if idx >= 10 and idx < best:
        best = idx

if best < len(text_for_scan):
    text = text[:best+1]

# Clean up
text = text.replace('\n', ' ')
text = re.sub(r'\s+', ' ', text).strip()

if len(text) > 150:
    text = text[:150].rsplit(' ', 1)[0] + '...'

if len(text) < 5:
    text = 'Done'

print(text)
" <<< "$text"
}
