#!/usr/bin/env bash
set -euo pipefail

# Read JSON input from stdin
INPUT=$(cat)

# Extract fields using jq
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"')
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""')
DESCRIPTION=$(echo "$INPUT" | jq -r '.tool_input.description // "No description"')
EXIT_CODE=$(echo "$INPUT" | jq -r '.tool_response.exitCode // "N/A"')
STDOUT=$(echo "$INPUT" | jq -r '.tool_response.stdout // ""')
STDERR=$(echo "$INPUT" | jq -r '.tool_response.stderr // ""')

# Validate required fields
if [ -z "$COMMAND" ] || [ "$SESSION_ID" = "unknown" ]; then
  echo "[bash-execution-info] ⚠️  Missing required fields, skipping log" >&2
  exit 0
fi

# Determine project root
PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)

# Create log directory structure
CURRENT_DATE=$(date +%Y-%m-%d)
LOG_DIR="$PROJECT_ROOT/.claude/claude-execution-info/bash/$CURRENT_DATE"
mkdir -p "$LOG_DIR"

# Log file path
LOG_FILE="$LOG_DIR/${SESSION_ID}.txt"

# Append log entry
{
  echo ""
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] ========================================"
  echo "Command: $COMMAND"
  echo "Description: $DESCRIPTION"
  echo "Exit Code: $EXIT_CODE"
  echo "Stdout:"
  echo "$STDOUT"
  echo ""
  echo "Stderr:"
  if [ -z "$STDERR" ]; then
    echo "(empty)"
  else
    echo "$STDERR"
  fi
  echo ""
  echo "========================================"
} >> "$LOG_FILE"

echo "[bash-execution-info] ✓ Logged to: $LOG_FILE" >&2
exit 0
