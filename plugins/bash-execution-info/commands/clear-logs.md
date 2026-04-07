---
description: Clean up old bash execution logs from .claude/claude-execution-info/bash
argument-hint: "[--days N | --all]"
allowed-tools: ["Bash"]
---

# Clear Bash Logs Command

Clean up old bash execution logs from `.claude/claude-execution-info/bash` to free up disk space and remove outdated logs.

## Implementation

Execute the cleanup script located at:
```bash
${CLAUDE_PLUGIN_ROOT}/scripts/clear-logs.sh
```

## Usage

```bash
# Delete ALL logs (default)
/clear-bash-logs

# Delete logs older than 7 days
/clear-bash-logs --days 7

# Delete ALL logs (explicit)
/clear-bash-logs --all
```

## Options

- **No arguments** (default): Deletes all bash execution logs
- **`--days N`**: Deletes logs older than N days (keeps recent logs)
- **`--all`**: Deletes all logs (same as default)

## What It Does

1. Scans `.claude/claude-execution-info/bash/` for log files
2. Deletes files based on the specified criteria:
   - Default: All logs
   - Custom: Logs older than specified days
3. Cleans up empty date directories after deletion
4. Provides summary of deleted and remaining logs

## Examples

**Delete all logs:**
```
/clear-bash-logs
```

**Keep only last week's logs:**
```
/clear-bash-logs --days 7
```

## Safety Features

- Only deletes `.txt` files in the bash logs directory
- Cleans up empty date directories automatically
- Provides detailed logging of deleted files
- Shows summary of deleted and remaining logs

## Notes

- Logs are organized by date: `YYYY-MM-DD/{session_id}.txt`
- The command uses file modification time to determine age
- Deleted logs cannot be recovered - use with caution
