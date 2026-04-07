#!/usr/bin/env bash
set -euo pipefail

# Local Plan Viewer - Archives session plans with timestamps
# Command script to manually archive the current session plan

echo "[archive-plan] Searching for current plan file..." >&2

# Find the most recently modified plan file in ~/.claude/plans/
# Plan files are named with generated names like "wondrous-mixing-waffle.md"
PLANS_DIR="$HOME/.claude/plans"

if [ -d "$PLANS_DIR" ]; then
  # Find the most recently modified .md file in the last 2 hours (active session)
  plan_file=$(find "$PLANS_DIR" -name "*.md" -type f -mmin -120 -exec ls -t {} + 2>/dev/null | head -1)
else
  plan_file=""
fi

# Verify the plan file exists
if [ -z "$plan_file" ] || [ ! -f "$plan_file" ]; then
  echo "[archive-plan] ❌ No plan file found in the current session" >&2
  echo "Make sure you're in an active session with a plan file." >&2
  exit 1
fi

echo "[archive-plan] Found plan file: $plan_file" >&2

# Calculate checksum of the plan file to detect duplicates
plan_checksum=$(shasum -a 256 "$plan_file" | awk '{print $1}')

# Configuration: Base directory for archived plans
# Store in .claude/claude-execution-info/plans under the project root
PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
BASE_DIR="$PROJECT_ROOT/.claude/claude-execution-info/plans"
CHECKSUM_CACHE="$BASE_DIR/.archived_checksums"

# Create base directory and checksum cache if needed
mkdir -p "$BASE_DIR"
touch "$CHECKSUM_CACHE"

# Check if we've already archived this exact plan
if grep -q "^${plan_checksum}$" "$CHECKSUM_CACHE" 2>/dev/null; then
  echo "[archive-plan] ⚠️  This plan has already been archived (checksum match)" >&2
  echo "No changes detected since last archive." >&2
  exit 0
fi

echo "[archive-plan] New or modified plan detected, archiving..." >&2

# Generate current date and time
current_date=$(date +%Y-%m-%d)
current_time=$(date +%H-%M-%S)

# Create the dated subdirectory
dated_dir="$BASE_DIR/$current_date"
mkdir -p "$dated_dir"

# Extract a brief description from the plan content
# Look for the first heading or meaningful line
description=$(head -20 "$plan_file" | grep -E '^#+ ' | head -1 | sed 's/^#* *//' || head -1 "$plan_file")

# Sanitize description: lowercase, keep only alphanumeric and spaces, limit to 3 words
description=$(echo "$description" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9 ]//g' | awk '{print $1"-"$2"-"$3}' | sed 's/-$//')

# Fallback to "plan" if description is empty
if [ -z "$description" ]; then
  description="plan"
fi

# Get file extension from original file
extension="${plan_file##*.}"

# Find existing files with the same description in today's folder
# Look for patterns: HH-MM-SS_description.ext or HH-MM-SS_description_vN.ext
existing_files=$(find "$dated_dir" -maxdepth 1 -name "*_${description}*.${extension}" 2>/dev/null || true)

if [ -z "$existing_files" ]; then
  # First version - no version number appended
  destination="$dated_dir/${current_time}_${description}.${extension}"
else
  # Find the highest version number
  max_version=$(echo "$existing_files" | grep -oE '_v[0-9]+' | grep -oE '[0-9]+' | sort -n | tail -1 || true)

  if [ -z "$max_version" ]; then
    # Existing file has no version number, so this is v2
    next_version=2
  else
    # Increment the version
    next_version=$((max_version + 1))
  fi

  # Get the timestamp from the first file to maintain consistency
  first_file=$(echo "$existing_files" | head -1)
  original_timestamp=$(basename "$first_file" | grep -oE '^[0-9]{2}-[0-9]{2}-[0-9]{2}')

  destination="$dated_dir/${original_timestamp}_${description}_v${next_version}.${extension}"
fi

# Copy the plan file to the archive
cp "$plan_file" "$destination"

# Record the checksum to prevent duplicate archiving
echo "$plan_checksum" >> "$CHECKSUM_CACHE"

echo "[archive-plan] ✓ Plan archived successfully!" >&2
echo "[archive-plan] Location: $destination" >&2
exit 0
