#!/bin/bash
#
# Emacs = data (JSON via kd/org-pomodoro-json)
# This script = display, animation, colors
#

cleanup() { kill 0; exit 0; }
trap cleanup TERM INT HUP PIPE

FETCH_INTERVAL=25  # ticks between emacsclient calls (25 * 0.2s = 5s)
RENDER_INTERVAL=0.1
BAR_WIDTH=20       # character width of the progress bar / marquee area
MARQUEE_PAD="　　　"  # full-width space gap for loop scroll

# State from Emacs (JSON fields)
state="off" remaining=0 total=0 heading="" clocked=0 effort="" points=0
frame=0 tick=0

# Gauge cache (rebuilt on fetch)
gauge_done=0 gauge_fg=""

fetch() {
    local raw json
    raw=$(emacsclient -e '(kd/org-pomodoro-json)' 2>/dev/null)
    [ -z "$raw" ] && return

    json="${raw#\"}"
    json="${json%\"}"
    json="${json//\\\"/\"}"

    eval "$(echo "$json" | jq -r '
        "state=\(.state | ltrimstr(":"))",
        "remaining=\(.remaining)",
        "total=\(.total)",
        "heading=\(.heading | @sh)",
        "clocked=\(.clocked)",
        "effort=\(.effort)",
        "points=\(.points)"
    ')"

    # Gauge progress (how many chars are "filled")
    local elapsed_pct=0
    [ "$total" -gt 0 ] && elapsed_pct=$(( (total - remaining) * 100 / total ))
    gauge_done=$(( elapsed_pct * BAR_WIDTH / 100 ))

    # Color for overline/underline/text on filled portion
    gauge_fg="#4caf50"
    if [ "$elapsed_pct" -ge 75 ]; then
        gauge_fg="#f44336"
    elif [ "$elapsed_pct" -ge 50 ]; then
        gauge_fg="#ff9800"
    fi
}

# Scrolling text, padded to BAR_WIDTH
marquee() {
    local text="$1"
    while [ ${#text} -lt "$BAR_WIDTH" ]; do
        text+="　"
    done
    local looped="${text}${MARQUEE_PAD}${text}"
    local total_len=$(( ${#text} + ${#MARQUEE_PAD} ))
    local offset=$(( (frame / 2) % total_len ))
    echo -n "${looped:$offset:$BAR_WIDTH}"
}

# Progress bar: ▓ as fill, task text overlaid (replaces spaces)
progress_bar() {
    local text
    text=$(marquee "$1")

    local out=""
    for (( i=0; i<BAR_WIDTH; i++ )); do
        local ch="${text:$i:1}"
        local color
        if [ "$i" -lt "$gauge_done" ]; then
            color="$gauge_fg"
        else
            color="#333333"
        fi
        # Show text char or █ for spaces
        if [ "$ch" = " " ] || [ "$ch" = "　" ] || [ -z "$ch" ]; then
            out+="%{F${color}}█%{F-}"
        else
            out+="%{F#aaaaaa}${ch}%{F-}"
        fi
    done
    echo -n "$out"
}

points_display() {
    local all_min=$(( points * 25 ))
    local h=$(( all_min / 60 ))
    local m=$(( all_min % 60 ))
    local eff=""
    if [ -n "$effort" ] && [ "$clocked" -gt 0 ]; then
        eff="[${clocked}m/${effort}] "
    elif [ "$clocked" -gt 0 ]; then
        eff="[effort not set] "
    fi
    printf " %s%dpts/%02dh%02dm" "$eff" "$points" "$h" "$m"
}

render() {
    local pts
    pts=$(points_display)

    case "$state" in
        off)
            if [ "$points" -gt 0 ]; then
                echo "%{F#666666}%{F-}${pts}"
            else
                echo "%{F#666666}%{F-}"
            fi
            ;;
        short-break|long-break)
            local label="Short break"
            [ "$state" = "long-break" ] && label="Long break"
            echo "$(progress_bar "$label") $(( remaining / 60 ))m${pts}"
            ;;
        overtime)
            if [ $(( frame % 5 )) -lt 3 ]; then
                echo "%{F#ff1744}Overtime! $(( remaining / 60 ))m${pts}%{F-}"
            else
                echo "%{F#ff8a80}Overtime! $(( remaining / 60 ))m${pts}%{F-}"
            fi
            ;;
        pomodoro)
            echo "$(progress_bar "$heading") $(( remaining / 60 ))m${pts}"
            ;;
        clocking)
            echo "(${clocked}m) %{F#000000}$(marquee "$heading")%{F-}${pts}"
            ;;
    esac
    frame=$(( frame + 1 ))
}

# Initial fetch
fetch

while true; do
    if [ $(( tick % FETCH_INTERVAL )) -eq 0 ]; then
        fetch
    fi
    render
    tick=$(( tick + 1 ))
    sleep "$RENDER_INTERVAL" &
    wait $!
done
