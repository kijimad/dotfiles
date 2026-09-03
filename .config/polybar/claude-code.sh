#!/bin/bash
#
# Polybar module: Claude Code status (tail mode)
# Reads a single running/stopped status file (/tmp/claude-code-status).
#

STATUS_FILE=/tmp/claude-code-status
STALE_SEC=1800
INTERVAL=0.1

frames=("▁" "▂" "▃" "▄" "▅" "▆" "▇" "█" "▇" "▆" "▅" "▄" "▃" "▂")
frame_idx=0

while true; do
    active=0

    if [[ -f "$STATUS_FILE" ]]; then
        val=$(cat "$STATUS_FILE" 2>/dev/null | tr -d '[:space:]')
        mtime=$(stat -c %Y "$STATUS_FILE" 2>/dev/null || echo 0)
        now=$(date +%s)

        # A crash can leave "active" behind without a Stop hook firing,
        # so treat a stale file as not running.
        if [[ "$val" == "active" ]] && (( now - mtime <= STALE_SEC )); then
            active=1
        fi
    fi

    if (( active )); then
        echo "%{F#4caf50}${frames[$frame_idx]} Claude%{F-}"
        frame_idx=$(( (frame_idx + 1) % ${#frames[@]} ))
    else
        echo ""
        frame_idx=0
    fi

    sleep "$INTERVAL"
done
