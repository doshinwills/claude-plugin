#!/bin/bash

# user-input.sh - Plays Ping.aiff when Claude asks for user input
#
# Triggered by Notification hook with matcher: permission_prompt|elicitation_dialog
#
# Environment variables:
# - CLAUDE_ALERT_ENABLED: Must be "true" to run (global on/off, default: enabled)
# - CLAUDE_ALERT_USER_INPUT_ENABLED: Control notification sounds (default: enabled)

# Global enable/disable check (default: enabled)
if [ "${CLAUDE_ALERT_ENABLED:-true}" != "true" ]; then
  exit 0
fi

# Notification-specific enable/disable check (default: enabled if blank or "true")
if [ "${CLAUDE_ALERT_USER_INPUT_ENABLED:-true}" != "true" ]; then
  exit 0
fi

# Read input from stdin (required for proper hook behavior)
INPUT=$(cat)

# Play sound (matcher already filtered for permission_prompt|elicitation_dialog)
if command -v afplay &> /dev/null; then
  afplay /System/Library/Sounds/Ping.aiff &
fi

exit 0
