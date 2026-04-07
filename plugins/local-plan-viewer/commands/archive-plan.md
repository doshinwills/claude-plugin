---
description: Manually archive the current session plan with timestamps
allowed-tools: ["Bash"]
---

# Archive Plan Command

Manually archives the current Claude Code plan file to `.claude/claude-execution-info/plans/` with timestamp organization and version control.

## Implementation

Execute the archive script located at:
```bash
${CLAUDE_PLUGIN_ROOT}/scripts/archive-plan.sh
```

## Usage

```
/archive-plan
```

## What It Does

1. Finds the most recently modified plan in `~/.claude/plans/` (within last 2 hours)
2. Calculates checksum to detect if plan was already archived
3. Archives to `.claude/claude-execution-info/plans/YYYY-MM-DD/HH-MM-SS_description.md`
4. Maintains version numbers if same plan archived multiple times (`_v2`, `_v3`, etc.)
5. Prevents duplicate archiving of unchanged plans

## Archive Location

Plans are archived in your project root:
```
.claude/claude-execution-info/plans/
├── 2026-04-06/
│   ├── 15-42-30_implementation-plan.md
│   ├── 15-45-10_plan-update_v2.md
│   └── 15-58-32_copy-command.md
└── .archived_checksums
```

## Notes

- This is the same script that runs automatically via hooks on PermissionRequest events
- Archives are organized by date with timestamps
- Duplicate detection prevents re-archiving unchanged plans
- Version numbering tracks iterations of the same plan
