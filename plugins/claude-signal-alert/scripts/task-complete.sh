#!/bin/bash

# task-complete.sh - Plays Pop.aiff when a task completes
#
# Triggered by Stop hook
#
# Environment variables:
# - CLAUDE_ALERT_ENABLED: Must be "true" to run (global on/off, default: enabled)
# - CLAUDE_ALERT_TASK_COMPLETE_ENABLED: Control task completion sounds (default: enabled)

# Global enable/disable check (default: enabled)
if [ "${CLAUDE_ALERT_ENABLED:-true}" != "true" ]; then
  exit 0
fi

# Task completion-specific enable/disable check (default: enabled if blank or "true")
if [ "${CLAUDE_ALERT_TASK_COMPLETE_ENABLED:-true}" != "true" ]; then
  exit 0
fi

# Read input from stdin (required for proper hook behavior)
INPUT=$(cat)

# Play sound if afplay is available
if command -v afplay &> /dev/null; then
  afplay /System/Library/Sounds/Pop.aiff
fi

exit 0
