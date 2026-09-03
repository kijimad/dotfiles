#!/bin/bash
# Write Claude Code running status to a single file.
# Usage: claude-code-status.sh <active|stopped>

STATUS_FILE=/tmp/claude-code-status

# Migrate away from the old per-project directory scheme (worktrees piled up
# one file per checkout there and never got cleaned).
[[ -d "$STATUS_FILE" ]] && rm -rf "$STATUS_FILE"

printf '%s' "$1" > "$STATUS_FILE"
