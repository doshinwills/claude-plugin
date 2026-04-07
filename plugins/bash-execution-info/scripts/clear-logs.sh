#!/usr/bin/env bash
set -euo pipefail

# clear-logs.sh - Clean up old bash execution logs
# Usage: clear-logs.sh [--days N | --all]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(git -C "$SCRIPT_DIR" rev-parse --show-toplevel 2>/dev/null || echo "$PWD")"
LOGS_DIR="$PROJECT_ROOT/.claude/claude-execution-info/bash"

# Default: delete all logs
DAYS_TO_KEEP=30
DELETE_ALL=true

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --days)
      DAYS_TO_KEEP="$2"
      DELETE_ALL=false
      shift 2
      ;;
    --all)
      DELETE_ALL=true
      shift
      ;;
    *)
      echo "Usage: $0 [--days N | --all]" >&2
      echo "  --days N  Delete logs older than N days" >&2
      echo "  --all     Delete all logs (default)" >&2
      exit 1
      ;;
  esac
done

echo "[clear-bash-logs] Starting log cleanup..." >&2

# Check if logs directory exists
if [ ! -d "$LOGS_DIR" ]; then
  echo "[clear-bash-logs] No logs directory found at: $LOGS_DIR" >&2
  echo "[clear-bash-logs] Nothing to clean up." >&2
  exit 0
fi

# Count total logs before cleanup
total_logs=$(find "$LOGS_DIR" -name "*.txt" -type f 2>/dev/null | wc -l | tr -d ' ')
echo "[clear-bash-logs] Found $total_logs log file(s)" >&2

if [ "$total_logs" -eq 0 ]; then
  echo "[clear-bash-logs] No logs to clean up." >&2
  exit 0
fi

# Perform cleanup
deleted_count=0

if [ "$DELETE_ALL" = true ]; then
  echo "[clear-bash-logs] Deleting ALL logs..." >&2

  # Delete all .txt files
  while IFS= read -r -d '' file; do
    rm -f "$file"
    deleted_count=$((deleted_count + 1))
    echo "[clear-bash-logs]   Deleted: $(basename "$(dirname "$file")")/$(basename "$file")" >&2
  done < <(find "$LOGS_DIR" -name "*.txt" -type f -print0 2>/dev/null)

  # Clean up empty date directories
  find "$LOGS_DIR" -type d -empty -delete 2>/dev/null || true

else
  echo "[clear-bash-logs] Deleting logs older than $DAYS_TO_KEEP days..." >&2

  # Delete files older than specified days
  while IFS= read -r -d '' file; do
    rm -f "$file"
    deleted_count=$((deleted_count + 1))
    echo "[clear-bash-logs]   Deleted: $(basename "$(dirname "$file")")/$(basename "$file")" >&2
  done < <(find "$LOGS_DIR" -name "*.txt" -type f -mtime +${DAYS_TO_KEEP} -print0 2>/dev/null)

  # Clean up empty date directories
  find "$LOGS_DIR" -type d -empty -delete 2>/dev/null || true
fi

# Summary
remaining_logs=$(find "$LOGS_DIR" -name "*.txt" -type f 2>/dev/null | wc -l | tr -d ' ')

echo "[clear-bash-logs] ✓ Cleanup complete!" >&2
echo "[clear-bash-logs] Deleted: $deleted_count log(s)" >&2
echo "[clear-bash-logs] Remaining: $remaining_logs log(s)" >&2

if [ "$remaining_logs" -eq 0 ]; then
  echo "[clear-bash-logs] Logs directory is now empty." >&2
fi

exit 0
