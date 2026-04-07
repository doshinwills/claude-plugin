# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Claude Code plugin marketplace for developers. It hosts plugins that extend Claude Code with custom commands, skills, hooks, and MCP server integrations.

## Repository Structure

```
claude-plugin/
├── .claude-plugin/
│   └── marketplace.json           # Marketplace metadata and plugin registry
├── plugins/
│   ├── bash-execution-info/       # Bash command logging plugin
│   ├── claude-signal-alert/       # Sound notification plugin
│   └── local-plan-viewer/         # Plan archiving plugin
└── scripts/
    └── lint_marketplace.py        # Validates marketplace.json and plugin structure
```

## Development Commands

### Linting

Validate marketplace.json and all plugin.json files for consistency:

```bash
cd scripts && python3 lint_marketplace.py
```

This checks:
- marketplace.json has required fields (name, description, owner, plugins)
- Each plugin has .claude-plugin/plugin.json with required fields (name, description, author, version)
- Plugin names match between marketplace.json and plugin.json
- Plugin sources exist and are directories
- Commands directory contains .md files (if it exists)
- Skills directories contain SKILL.md files
- .mcp.json is valid JSON (if it exists)

### Plugin Structure Requirements

Every plugin MUST have:

```
plugin-name/
├── .claude-plugin/
│   └── plugin.json    # Metadata: name, description, version, author (with name/email)
└── [one or more of:]
    ├── commands/      # Slash commands (.md files with frontmatter)
    ├── skills/        # Model-invoked skills (subdirs with SKILL.md)
    ├── hooks/         # Event hooks (hooks.json + scripts)
    └── .mcp.json      # MCP server configurations
```

### marketplace.json Structure

The root .claude-plugin/marketplace.json registers all plugins:

- `name`: Marketplace identifier
- `description`: Marketplace description
- `owner`: Object with name and email (doshin / doshin@example.com)
- `plugins[]`: Array of plugin entries
  - `name`: Must match plugin.json name
  - `version`: Plugin version
  - `source`: Relative path starting with `./plugins/`
  - `description`: Plugin description
  - `keywords`: Optional tags

### Plugin Types

**Commands** (`commands/*.md`): User-invoked slash commands with YAML frontmatter defining description, argument-hint, and allowed-tools.

**Skills** (`skills/<skillname>/SKILL.md`): Model-invoked capabilities with YAML frontmatter defining name, description, version, and trigger patterns.

**Hooks** (`hooks/hooks.json`): Event-driven scripts that run on Claude Code events (e.g., PermissionRequest). The hooks.json defines hook type, command path, and timeout.

**MCP Servers** (`.mcp.json`): External tool integrations via Model Context Protocol.

## Current Plugins

See `plugins/` directory for available plugins. Each plugin contains its own README.md with documentation.

### bash-execution-info

Automatically logs all bash commands executed by Claude Code. Captures command, description, exit code, stdout/stderr, and timestamps. Logs are organized by date and session. Includes `/clear-bash-logs` command for cleanup.

**Features:**
- Automatic logging via PostToolUse hooks
- Date and session organization
- Complete execution details
- Log cleanup command

### claude-signal-alert

Sound notifications for Claude Code events. Plays macOS system sounds when Claude needs user attention or completes tasks.

**Features:**
- Sound alerts for user input needed
- Completion notifications
- Stop/error notifications

### local-plan-viewer

Archives Claude Code session plans with timestamps and versioning. Automatically saves plans when exiting plan mode and provides manual archiving via commands.

**Features:**
- Automatic plan archiving via PostToolUse hooks
- Manual archiving with `/archive-plan`
- Cleanup old archives with `/clear-archives`
- Date-based organization

## Adding New Plugins

1. Create plugin directory under `plugins/`
2. Add `.claude-plugin/plugin.json` with required fields:
   ```json
   {
     "name": "plugin-name",
     "description": "What this plugin does",
     "version": "1.0.0",
     "author": {
       "name": "Your Team Name",
       "email": "you@example.com"
     }
   }
   ```
3. Implement commands, skills, hooks, or MCP servers
4. Register plugin in `.claude-plugin/marketplace.json`:
   ```json
   {
     "name": "plugin-name",
     "version": "1.0.0",
     "source": "./plugins/plugin-name",
     "description": "Brief description",
     "keywords": ["tag1", "tag2"]
   }
   ```
5. Run `cd scripts && python3 lint_marketplace.py` to validate
6. Commit changes

## Shell Script Requirements

All shell scripts in plugins must:
1. Have shebang: `#!/usr/bin/env bash`
2. Include error handling: `set -euo pipefail`
3. Be executable: `chmod +x script.sh`
4. Use proper exit codes: 0=success, 1=failure
5. Accept input via stdin when needed (especially for hooks)
6. Output structured data to stdout (JSON preferred)
7. Log debug info to stderr

Example hook script structure:
```bash
#!/usr/bin/env bash
set -euo pipefail

input=$(cat)  # Read JSON from stdin
tool=$(echo "$input" | jq -r '.tool')

# Decision logic
if [ "$tool" = "Read" ]; then
  echo "Auto-approving Read operation" >&2
  exit 0  # Auto-approve
else
  echo "Manual approval required" >&2
  exit 1  # Require user prompt
fi
```

## Security Considerations for Auto-Approval Hooks

When creating permission auto-approval hooks:

### Safe to Auto-Approve (Read-Only)
- ✅ Read tool (file reading)
- ✅ Glob tool (file pattern matching)
- ✅ Grep tool (content search)
- ✅ Git read operations: status, log, diff, show, branch (listing only)
- ✅ Basic bash: ls, pwd, cat (if read-only)
- ✅ Test execution: npm test, pytest, cargo test (no side effects)
- ✅ Linting: eslint, pylint (analysis only)

### Require Manual Approval (Write Operations)
- 🔒 Write tool (file creation/modification)
- 🔒 Edit tool (file editing)
- 🔒 Git write operations: commit, push, add, reset, rebase, merge
- 🔒 Package installations: npm install, pip install
- 🔒 Network operations: curl, wget, ssh, scp
- 🔒 File deletions: rm, git clean
- 🔒 System changes: anything that modifies state

**Default to deny**: Use whitelist approach (explicitly allow safe operations, deny everything else).

**Start conservative**: Begin with minimal auto-approval (Read/Glob/Grep only) and expand based on team needs.

## Testing Plugins Locally

Before adding to marketplace, test plugins locally:

1. **Add to Claude Code settings**:
   ```json
   {
     "plugins": [
       {
         "path": "/Users/doshin/development/claude-plugin/plugins/plugin-name"
       }
     ]
   }
   ```

2. **Test each extension type**:
   - Commands: Type `/command-name` in Claude Code
   - Skills: Have conversations matching trigger patterns
   - Hooks: Trigger events and verify behavior (check logs)
   - MCP: Use tools provided by MCP server

3. **Manual hook testing**:
   ```bash
   echo '{"tool":"Read","description":"test"}' | ./hooks/scripts/script.sh
   echo $?  # Check exit code (0=approve, 1=deny)
   ```

4. **Check logs**:
   ```bash
   tail -f ~/.claude/logs/claude-code.log | grep "AUTO-APPROVE"
   ```

## Validation

Always run validation before committing:

```bash
cd scripts
python3 lint_marketplace.py
```

Expected output on success:
```
✓ Marketplace.json is valid: claude-plugin-local
✓ Owner: doshin <doshin@example.com>
✓ Plugins registered: 3

Validating Plugin: claude-signal-alert
✓ Plugin directory exists: /path/to/plugins/claude-signal-alert
✓ plugin.json is valid: claude-signal-alert v1.0.0
✓ Extension types found: hooks

Validating Plugin: local-plan-viewer
✓ Plugin directory exists: /path/to/plugins/local-plan-viewer
✓ plugin.json is valid: local-plan-viewer v1.0.0
✓ Extension types found: commands (2 files), hooks

Validating Plugin: bash-execution-info
✓ Plugin directory exists: /path/to/plugins/bash-execution-info
✓ plugin.json is valid: bash-execution-info v1.0.0
✓ Extension types found: commands (1 files), hooks

Validation Summary
✓ All validations passed! ✨
```

## Marketplace Owner

**Maintainer**: doshin
**Contact**: doshin@example.com

## Additional Plugin Architecture Docs

For complete documentation, see:
- [Claude Code Plugin Guide](https://code.claude.com/docs/en/plugins)
- [Plugin Marketplaces](https://code.claude.com/docs/en/plugin-marketplaces)
- [Plugins Reference](https://code.claude.com/docs/en/plugins-reference)
