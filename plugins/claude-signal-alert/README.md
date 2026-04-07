# claude-signal-alert

Sound notifications for Claude Code events. Plays macOS system sounds when Claude needs your attention or completes tasks.

## Features

- **User Input Alerts**: Plays `Ping.aiff` when Claude needs user input
  - Permission prompts (tool approval requests)
  - Elicitation dialogs (clarifying questions)
- **Completion Alerts**: Plays `Pop.aiff` when Claude finishes a task
- **Environment Variable Control**: Fine-grained control over when sounds play

## Installation

```bash
claude plugin install claude-signal-alert@claude-plugin
```

## Environment Variables

Control notification behavior with these environment variables (set in your shell profile):

### Global Control

- `CLAUDE_ALERT_ENABLED`: Master on/off switch for all notification sounds
  - Default: `"true"` (enabled)
  - Set to anything else to disable all sounds

### Individual Sound Control

- `CLAUDE_ALERT_USER_INPUT_ENABLED`: Control user input sounds (Ping.aiff)
  - Default: `"true"` (enabled)
  - Set to `"false"` to disable

- `CLAUDE_ALERT_TASK_COMPLETE_ENABLED`: Control completion sounds (Pop.aiff)
  - Default: `"true"` (enabled)
  - Set to `"false"` to disable

### Examples

```bash
# Disable all notification sounds
export CLAUDE_ALERT_ENABLED="false"

# Enable all sounds (default behavior)
export CLAUDE_ALERT_ENABLED="true"
export CLAUDE_ALERT_USER_INPUT_ENABLED="true"
export CLAUDE_ALERT_TASK_COMPLETE_ENABLED="true"

# Enable only completion sounds, disable user input sounds
export CLAUDE_ALERT_ENABLED="true"
export CLAUDE_ALERT_USER_INPUT_ENABLED="false"
export CLAUDE_ALERT_TASK_COMPLETE_ENABLED="true"

# Enable only user input sounds, disable completion sounds
export CLAUDE_ALERT_ENABLED="true"
export CLAUDE_ALERT_USER_INPUT_ENABLED="true"
export CLAUDE_ALERT_TASK_COMPLETE_ENABLED="false"
```

## How It Works

This plugin uses Claude Code's hook system to trigger sounds at key moments:

### Notification Hook
Triggers when Claude needs user input:
- **Matcher**: `permission_prompt|elicitation_dialog`
- **Script**: `scripts/user-input.sh`
- **Sound**: Ping.aiff
- **Fires when**:
  - Claude requests permission to use a tool
  - Claude asks clarifying questions via AskUserQuestion

### Stop Hook
Triggers when Claude completes a response:
- **Matcher**: None (fires on all Stop events)
- **Script**: `scripts/task-complete.sh`
- **Sound**: Pop.aiff
- **Fires when**:
  - Claude finishes responding/stops working

Both hooks run asynchronously (`"async": true`) so they don't block Claude's execution.

## Platform Support

**macOS only**

This plugin uses:
- macOS system sounds in `/System/Library/Sounds/`
- `afplay` command for audio playback

## File Structure

```
claude-signal-alert/
├── .claude-plugin/
│   └── plugin.json              # Plugin metadata
├── hooks/
│   └── hooks.json               # Hook definitions
├── scripts/
│   ├── user-input.sh           # Plays Ping.aiff for user input
│   └── task-complete.sh        # Plays Pop.aiff for task completion
└── README.md
```

## Troubleshooting

### No sounds playing?

1. Check that `afplay` command is available:
   ```bash
   which afplay
   ```

2. Verify environment variables:
   ```bash
   echo $CLAUDE_ALERT_ENABLED
   echo $CLAUDE_ALERT_USER_INPUT_ENABLED
   echo $CLAUDE_ALERT_TASK_COMPLETE_ENABLED
   ```

3. Test sounds manually:
   ```bash
   afplay /System/Library/Sounds/Ping.aiff
   afplay /System/Library/Sounds/Pop.aiff
   ```

4. Check hook execution:
   ```bash
   claude --debug
   ```

### Sounds too frequent?

Disable user input sounds to reduce notification frequency:
```bash
export CLAUDE_ALERT_USER_INPUT_ENABLED="false"
```

This keeps completion sounds but removes the more frequent user-input alerts.

## Development

### Testing Scripts

Test individual scripts directly:

```bash
# Test user-input sound (bypasses hook matcher)
echo '{}' | bash plugins/claude-signal-alert/scripts/user-input.sh

# Test completion sound
echo '{}' | bash plugins/claude-signal-alert/scripts/task-complete.sh

# Syntax check
bash -n plugins/claude-signal-alert/scripts/user-input.sh
bash -n plugins/claude-signal-alert/scripts/task-complete.sh
```

### Validation

Validate hook configuration:
```bash
jq empty plugins/claude-signal-alert/hooks/hooks.json
```
