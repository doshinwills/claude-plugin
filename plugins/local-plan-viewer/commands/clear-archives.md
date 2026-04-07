---
description: Clean up old archived plan files from .claude/claude-execution-info/plans
argument-hint: "[--days N | --all]"
allowed-tools: ["Bash"]
---

# Clear Archives Command

Clean up old archived plan files from `.claude/claude-execution-info/plans` to free up disk space and remove outdated plans.

## Implementation

Execute the cleanup script located at:
```bash
${CLAUDE_PLUGIN_ROOT}/scripts/clear-archives.sh
```

## Usage

```bash
# Delete ALL archives (default)
/clear-archives

# Delete archives older than 7 days
/clear-archives --days 7

# Delete ALL archives (explicit)
/clear-archives --all
```

## Options

- **No arguments** (default): Deletes all archived plans
- **`--days N`**: Deletes archives older than N days (keeps recent archives)
- **`--all`**: Deletes all archived plans (same as default)

## What It Does

1. Scans `.claude/claude-execution-info/plans/` for archived plan files
2. Deletes files based on the specified criteria:
   - Default: All archived plans
   - Custom: Plans older than specified days (with `--days N`)
3. Cleans up empty date directories after deletion
4. Clears the `.archived_checksums` cache (or rebuilds it with `--days`)
5. Provides summary of deleted and remaining archives

## Examples

**Delete all archives (default):**
```
/clear-archives
```

Output:
```
[clear-archives] Starting archive cleanup...
[clear-archives] Found 15 archived plan(s)
[clear-archives] Deleting ALL archives...
[clear-archives]   Deleted: 2026-04-01/14-30-00_old-plan.md
[clear-archives]   Deleted: 2026-04-05/09-15-30_recent-plan.md
[clear-archives] Cleared checksum cache
[clear-archives] ✓ Cleanup complete!
[clear-archives] Deleted: 15 archive(s)
[clear-archives] Remaining: 0 archive(s)
[clear-archives] Archive directory is now empty.
```

**Keep only last week's plans:**
```
/clear-archives --days 7
```

Output:
```
[clear-archives] Starting archive cleanup...
[clear-archives] Found 15 archived plan(s)
[clear-archives] Deleting archives older than 7 days...
[clear-archives]   Deleted: 2026-03-28/14-30-00_old-plan.md
[clear-archives] Rebuilt checksum cache
[clear-archives] ✓ Cleanup complete!
[clear-archives] Deleted: 10 archive(s)
[clear-archives] Remaining: 5 archive(s)
```

## Safety Features

- Only deletes `.md` files in the archives directory
- Cleans up empty date directories automatically
- Rebuilds checksum cache when using `--days` option
- Provides detailed logging of deleted files
- Shows summary of deleted and remaining archives

## Notes

- Archives are organized by date: `YYYY-MM-DD/HH-MM-SS_description.md`
- The command uses file modification time to determine age
- Deleted plans cannot be recovered - use with caution
- The checksum cache prevents duplicate archiving, so clearing it may cause re-archiving of existing plans
