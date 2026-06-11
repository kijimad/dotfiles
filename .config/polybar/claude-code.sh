#!/bin/bash
#
# Polybar module: Claude Code status (tail mode)
# Aggregates per-project status from /tmp/claude-code-status/
#

STATUS_DIR=/tmp/claude-code-status
STALE_SEC=30
INTERVAL=0.1

frames=("▁" "▂" "▃" "▄" "▅" "▆" "▇" "█" "▇" "▆" "▅" "▄" "▃" "▂")
frame_idx=0

while true; do
    active_projects=()
    idle_projects=()
    now=$(date +%s)

    if [[ -d "$STATUS_DIR" ]]; then
        for f in "$STATUS_DIR"/*; do
            [[ -f "$f" ]] || continue
            name=$(basename "$f")
            val=$(cat "$f" 2>/dev/null | tr -d '[:space:]')
            mtime=$(stat -c %Y "$f" 2>/dev/null || echo 0)

            if [[ "$val" == "active" ]] && (( now - mtime <= STALE_SEC )); then
                active_projects+=("$name")
            elif [[ "$val" != "stopped" ]]; then
                idle_projects+=("$name")
            fi
        done
    fi

    if (( ${#active_projects[@]} > 0 )); then
        names=$(IFS=' '; echo "${active_projects[*]}")
        echo "%{F#4caf50}${frames[$frame_idx]} ${names}%{F-}"
        frame_idx=$(( (frame_idx + 1) % ${#frames[@]} ))
    elif (( ${#idle_projects[@]} > 0 )); then
        names=$(IFS=' '; echo "${idle_projects[*]}")
        echo "%{F#ff9800}● ${names}%{F-}"
        frame_idx=0
    else
        echo ""
        frame_idx=0
    fi

    sleep "$INTERVAL"
done
