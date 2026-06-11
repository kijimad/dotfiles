#!/bin/bash
# Write Claude Code status per project
# Usage: claude-code-status.sh <active|stopped>

STATUS_DIR=/tmp/claude-code-status
PROJECT=$(basename "$PWD")

mkdir -p "$STATUS_DIR"
echo "$1" > "$STATUS_DIR/$PROJECT"
