# bash-execution-info

Automatically logs all bash commands executed by Claude Code along with their outputs, exit codes, and timestamps.

## Overview

This plugin uses PostToolUse hooks to capture every bash command that Claude executes, logging complete execution details for audit, debugging, and analysis purposes.

## Features

- 📝 **Automatic Logging**: Captures every bash command Claude runs without manual intervention
- 📊 **Complete Details**: Logs command, description, exit code, stdout, and stderr
- 📅 **Date Organization**: Organizes logs by date in `YYYY-MM-DD/` subdirectories
- 🔗 **Session Grouping**: Groups all commands from the same Claude session in one file
- ⚡ **Non-Blocking**: Runs asynchronously so it doesn't slow down Claude
- 🛡️ **Error Handling**: Gracefully handles missing fields and write failures

## Commands

### /clear-bash-logs

Clean up old bash execution logs to free disk space.

**Usage:**
```bash
# Delete all logs
/clear-bash-logs

# Keep only last 7 days
/clear-bash-logs --days 7

# Delete all logs (explicit)
/clear-bash-logs --all
```

**Options:**
- No arguments: Deletes all logs (default)
- `--days N`: Deletes logs older than N days
- `--all`: Deletes all logs

See `commands/clear-logs.md` for full documentation.

## Log Location

Logs are stored in your project's `.claude/` directory:

```
.claude/claude-execution-info/bash/
└── YYYY-MM-DD/
    ├── session-id-1.txt
    ├── session-id-2.txt
    └── session-id-3.txt
```

## Log Format

Each log entry includes:

```
[2026-04-06 20:40:26] ========================================
Command: npm test
Description: Run test suite
Exit Code: 0
Stdout:
✓ All tests passed (42 tests)

Stderr:
(empty)

========================================
```

## Use Cases

- **Audit Trail**: Track all commands Claude has executed in your project
- **Debugging**: Review command outputs when troubleshooting issues
- **Learning**: See what commands Claude uses to accomplish tasks
- **Compliance**: Maintain records of automated operations
- **Analysis**: Analyze Claude's command patterns and execution history

## How It Works

1. Claude executes a bash command using the Bash tool
2. After execution completes, the PostToolUse hook triggers
3. The hook script receives JSON data with command details
4. Log entry is appended to the session file
5. Hook completes asynchronously without blocking Claude

## Configuration

The plugin uses these settings in `hooks/hooks.json`:

- **Hook Type**: PostToolUse (fires after command execution)
- **Matcher**: "Bash" (only captures Bash tool executions)
- **Async**: true (runs in background)
- **Timeout**: 5000ms (5 seconds)

## Requirements

- `jq` - JSON parsing tool (pre-installed on macOS)
- `git` - For determining project root
- Bash shell environment

## Installation

This plugin is part of the claude-plugin marketplace. To use it:

1. Clone the marketplace repository
2. Add to your Claude Code settings:
   ```json
   {
     "plugins": [
       {
         "path": "/path/to/claude-plugin/plugins/bash-execution-info"
       }
     ]
   }
   ```
3. Restart Claude Code

## Examples

### Example 1: Single Command

Claude runs: `git status`

Log entry:
```
[2026-04-06 16:30:45] ========================================
Command: git status
Description: Show working tree status
Exit Code: 0
Stdout:
On branch main
Your branch is up to date with 'origin/main'.

nothing to commit, working tree clean

Stderr:
(empty)

========================================
```

### Example 2: Failed Command

Claude runs: `npm test` (tests fail)

Log entry:
```
[2026-04-06 16:35:22] ========================================
Command: npm test
Description: Run test suite
Exit Code: 1
Stdout:


Stderr:
Error: Test failed: expected true, got false

========================================
```

### Example 3: Multiple Commands in Session

All commands from the same Claude session are grouped in one file, preserving execution order and timing.

## Privacy & Security

- Logs are stored locally in your project's `.claude/` directory
- No data is sent to external services
- Logs may contain sensitive information from command outputs
- Add `.claude/claude-execution-info/` to `.gitignore` to avoid committing logs

## Maintenance

### Viewing Recent Logs

```bash
# View today's logs
ls .claude/claude-execution-info/bash/$(date +%Y-%m-%d)/

# View specific session
cat .claude/claude-execution-info/bash/YYYY-MM-DD/session-id.txt

# View all commands from today
cat .claude/claude-execution-info/bash/$(date +%Y-%m-%d)/*.txt
```

### Cleaning Old Logs

```bash
# Remove logs older than 30 days
find .claude/claude-execution-info/bash/ -type d -mtime +30 -exec rm -rf {} +

# Remove all logs
rm -rf .claude/claude-execution-info/bash/
```

## Troubleshooting

### No logs being created

1. Check that `jq` is installed: `which jq`
2. Verify hook script is executable: `ls -l plugins/bash-execution-info/scripts/log-bash-execution.sh`
3. Check Claude Code logs for hook errors: `~/.claude/logs/claude-code.log`

### Logs missing commands

- The hook only captures Bash tool executions
- Commands run outside of Claude (in your terminal) are not logged
- Verify the hook is enabled in your Claude Code settings

### Permission errors

- Ensure `.claude/` directory is writable
- Check that your user has write permissions to the project directory

## Author

**doshin**
doshin@example.com

## Version

1.0.0
