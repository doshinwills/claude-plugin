#!/usr/bin/env bash
set -euo pipefail

# clear-archives.sh - Clean up old archived plan files
# Usage: clear-archives.sh [--days N | --all]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(git -C "$SCRIPT_DIR" rev-parse --show-toplevel 2>/dev/null || echo "$PWD")"
ARCHIVES_DIR="$PROJECT_ROOT/.claude/claude-execution-info/plans"
CHECKSUM_CACHE="$ARCHIVES_DIR/.archived_checksums"

# Default: delete all archives
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
      echo "  --days N  Delete archives older than N days" >&2
      echo "  --all     Delete all archives (default)" >&2
      exit 1
      ;;
  esac
done

echo "[clear-archives] Starting archive cleanup..." >&2

# Check if archives directory exists
if [ ! -d "$ARCHIVES_DIR" ]; then
  echo "[clear-archives] No archives directory found at: $ARCHIVES_DIR" >&2
  echo "[clear-archives] Nothing to clean up." >&2
  exit 0
fi

# Count total archives before cleanup
total_archives=$(find "$ARCHIVES_DIR" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
echo "[clear-archives] Found $total_archives archived plan(s)" >&2

if [ "$total_archives" -eq 0 ]; then
  echo "[clear-archives] No archives to clean up." >&2
  exit 0
fi

# Perform cleanup
deleted_count=0

if [ "$DELETE_ALL" = true ]; then
  echo "[clear-archives] Deleting ALL archives..." >&2

  # Delete all .md files
  while IFS= read -r -d '' file; do
    rm -f "$file"
    deleted_count=$((deleted_count + 1))
    echo "[clear-archives]   Deleted: $(basename "$(dirname "$file")")/$(basename "$file")" >&2
  done < <(find "$ARCHIVES_DIR" -name "*.md" -type f -print0 2>/dev/null)

  # Clean up empty date directories
  find "$ARCHIVES_DIR" -type d -empty -delete 2>/dev/null || true

  # Clear checksum cache
  if [ -f "$CHECKSUM_CACHE" ]; then
    rm -f "$CHECKSUM_CACHE"
    echo "[clear-archives] Cleared checksum cache" >&2
  fi

else
  echo "[clear-archives] Deleting archives older than $DAYS_TO_KEEP days..." >&2

  # Delete files older than specified days
  while IFS= read -r -d '' file; do
    rm -f "$file"
    deleted_count=$((deleted_count + 1))
    echo "[clear-archives]   Deleted: $(basename "$(dirname "$file")")/$(basename "$file")" >&2
  done < <(find "$ARCHIVES_DIR" -name "*.md" -type f -mtime +${DAYS_TO_KEEP} -print0 2>/dev/null)

  # Clean up empty date directories
  find "$ARCHIVES_DIR" -type d -empty -delete 2>/dev/null || true

  # Rebuild checksum cache with remaining files
  if [ -f "$CHECKSUM_CACHE" ]; then
    temp_cache=$(mktemp)
    if find "$ARCHIVES_DIR" -name "*.md" -type f -exec shasum -a 256 {} \; 2>/dev/null | awk '{print $1}' | sort -u > "$temp_cache"; then
      mv "$temp_cache" "$CHECKSUM_CACHE"
      echo "[clear-archives] Rebuilt checksum cache" >&2
    else
      rm -f "$temp_cache"
    fi
  fi
fi

# Summary
remaining_archives=$(find "$ARCHIVES_DIR" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')

echo "[clear-archives] ✓ Cleanup complete!" >&2
echo "[clear-archives] Deleted: $deleted_count archive(s)" >&2
echo "[clear-archives] Remaining: $remaining_archives archive(s)" >&2

if [ "$remaining_archives" -eq 0 ]; then
  echo "[clear-archives] Archive directory is now empty." >&2
fi

exit 0
