# Claude Plugins Marketplace

Claude Code plugin marketplace. Extends Claude Code with productivity tools, automation workflows, and integration capabilities.

## Table of Contents

- [Quick Start](#quick-start)
  - [Step 1: Add the Marketplace](#step-1-add-the-marketplace)
  - [Step 2: Update the Marketplace](#step-2-update-the-marketplace)
  - [Step 3: Install Plugins](#step-3-install-plugins)
- [Available Plugins](#available-plugins)
- [Uninstall a Plugin](#uninstall-a-plugin)
- [For Plugin Developers](#for-plugin-developers)
- [Troubleshooting](#troubleshooting)
  - [CLI Command Not Found](#cli-command-not-found)
  - [Marketplace Not Found (CLI/Git URL Methods)](#marketplace-not-found-cligit-url-methods)
  - [Marketplace Not Found (Local Path Method)](#marketplace-not-found-local-path-method)
  - [Git Authentication Issues](#git-authentication-issues)
  - [Plugin Not Available](#plugin-not-available)
  - [Plugin Install Fails](#plugin-install-fails)
- [Ownership](#ownership)

## Quick Start

### Step 1: Add the Marketplace

Choose one of the following methods to add this marketplace to Claude Code:

#### Option 1: CLI Command (Recommended for End Users)

The simplest method - just run one command:

```bash
claude plugin marketplace add doshin/claude-plugin
```

This automatically configures the marketplace and manages updates through Claude Code.

#### Option 2: Git URL (Direct GitHub Integration)

For Git-based installation with automatic updates from GitHub:

1. Edit your Claude Code settings:
   ```bash
   claude config edit
   ```

2. Add to your settings file (`~/.config/claude-code/settings.json`):

```json
{
  "extraKnownMarketplaces": {
    "claude-plugin": {
      "source": {
        "source": "github",
        "repo": "doshin/claude-plugin"
      }
    }
  }
}
```

4. Restart Claude Code

#### Verify Installation

After using any method above, verify the marketplace was added:

```bash
claude plugin list --marketplace claude-plugin
```

### Step 2: Update the Marketplace

Keep your marketplace up-to-date to get the latest plugins and improvements.

```bash
claude plugin marketplace update claude-plugin
```

Run updates periodically to stay current with new plugins and improvements.

### Step 3: Install Plugins

After adding the marketplace, install individual plugins using the Claude CLI:

```bash
# General syntax
claude plugin install <plugin-name>@claude-plugin

# Example: Install sound notification plugin
claude plugin install claude-signal-alert@claude-plugin
```

**Browse available plugins:**

```bash
claude plugin list --marketplace claude-plugin
```

## Available Plugins

| Plugin | Version | Installation Command | Description |
|--------|---------|---------------------|-------------|
| [bash-execution-info](plugins/bash-execution-info) | 1.0.0 | `claude plugin install bash-execution-info@claude-plugin` | Automatically logs all bash commands executed by Claude Code with full execution details (command, output, exit code, timestamps). Organized by date and session. Includes `/clear-bash-logs` cleanup command. |
| [claude-signal-alert](plugins/claude-signal-alert) | 1.0.0 | `claude plugin install claude-signal-alert@claude-plugin` | Sound notifications for Claude Code events. Plays macOS system sounds when Claude needs input or completes tasks. |
| [local-plan-viewer](plugins/local-plan-viewer) | 1.0.0 | `claude plugin install local-plan-viewer@claude-plugin` | Archives Claude Code session plans to a local directory with timestamps. Provides automatic archiving via hooks and manual archiving via `/archive-plan` command. Includes `/clear-archives` cleanup command. |

Click plugin names for detailed documentation and configuration options.

## Uninstall a Plugin

```bash
claude plugin uninstall <plugin-name>
```

## For Plugin Developers

Want to create your own plugin for the team? See [CONTRIBUTING.md](CONTRIBUTING.md) for a complete guide to plugin development.

## Troubleshooting

### CLI Command Not Found

**Problem:** `claude plugin marketplace add` command not recognized

**Solution:**
1. Ensure you have the latest version of Claude Code CLI
2. Update Claude Code: Check for updates in your installation method
3. Verify installation: `claude --version`
4. If command is unavailable, use Git URL or Local Path method instead

### Marketplace Not Found (CLI/Git URL Methods)

**Problem:** `claude plugin list --marketplace claude-plugin` shows no plugins after configuration

**Solution:**
1. Verify marketplace was added: `claude config edit` and check for `extraKnownMarketplaces` or CLI registration
2. Restart Claude Code completely
3. Check Claude Code logs: `~/.claude/logs/claude-code.log`
4. Try re-adding: `claude plugin marketplace add doshin/claude-plugin`

### Marketplace Not Found (Local Path Method)

**Problem:** `claude plugin list --marketplace claude-plugin` shows no plugins

**Solution:**
1. Verify marketplace path in settings: `claude config edit`
2. Check the path exists: `ls /path/to/claude-plugin`
3. Verify marketplace.json exists: `ls /path/to/claude-plugin/.claude-plugin/marketplace.json`
4. Ensure path is absolute, not relative

### Git Authentication Issues

**Problem:** Cannot access marketplace via Git URL method

**Solution:**
1. Verify repository is public or you have access
2. If private, ensure GitHub credentials are configured
3. Try SSH URL in settings if HTTPS fails
4. As fallback, use Local Path method with `git clone`

### Plugin Not Available

**Problem:** Can't find a plugin when trying to install

**Solution:**
1. Update the marketplace (method-specific):
   - CLI: `claude plugin marketplace update claude-plugin`
   - Git URL: Restart Claude Code or run update command
   - Local Path: `cd /path/to/claude-plugin && git pull`
2. List available plugins: `claude plugin list --marketplace claude-plugin`
3. Check plugin exists in repository
4. Validate registry: `cd scripts && python3 lint_marketplace.py`

### Plugin Install Fails

**Problem:** `claude plugin install` command fails

**Solution:**
1. Ensure Claude Code CLI is properly installed
2. Check you're using the correct marketplace name: `claude-plugin`
3. Verify plugin name matches exactly (case-sensitive)
4. Update marketplace first (see method-specific instructions above)
5. Check Claude Code logs for errors: `~/.claude/logs/claude-code.log`

## Ownership

**Maintained by**: doshin
**Contact**: doshin@example.com
**Repository**: https://github.com/doshin/claude-plugin
