#!/bin/bash
#
# Emacs = data (JSON via kd/org-pomodoro-json)
# This script = display, animation, colors
#

trap 'exit 0' TERM INT HUP PIPE

FETCH_INTERVAL=25  # ticks between emacsclient calls (25 * 0.2s = 5s)
RENDER_INTERVAL=0.1
GAUGE_LEN=30

# State from Emacs (JSON fields)
state="off" remaining=0 total=0 heading="" clocked=0 effort="" points=0
frame=0 tick=0

# Gauge cache (rebuilt on fetch)
gauge_done=0 gauge_will=0 gauge_color="" gauge_highlight=""
gauge_base="" gauge_rest=""

fetch() {
    local raw json
    raw=$(emacsclient -e '(kd/org-pomodoro-json)' 2>/dev/null)
    [ -z "$raw" ] && return

    # Strip outer quotes and unescape from emacsclient output
    json="${raw#\"}"
    json="${json%\"}"
    json="${json//\\\"/\"}"

    # Parse all fields in one jq call
    eval "$(echo "$json" | jq -r '
        "state=\(.state | ltrimstr(":"))",
        "remaining=\(.remaining)",
        "total=\(.total)",
        "heading=\(.heading | @sh)",
        "clocked=\(.clocked)",
        "effort=\(.effort)",
        "points=\(.points)"
    ')"

    # Rebuild gauge cache
    local elapsed_pct=0
    [ "$total" -gt 0 ] && elapsed_pct=$(( (total - remaining) * 100 / total ))
    gauge_done=$(( elapsed_pct * GAUGE_LEN / 100 ))
    gauge_will=$(( GAUGE_LEN - gauge_done ))

    gauge_color="#4caf50"; gauge_highlight="#b9f6ca"
    if [ "$elapsed_pct" -ge 75 ]; then
        gauge_color="#f44336"; gauge_highlight="#ff8a80"
    elif [ "$elapsed_pct" -ge 50 ]; then
        gauge_color="#ff9800"; gauge_highlight="#ffe082"
    fi

    # Pre-build base filled and empty strings
    gauge_base=""; gauge_rest=""
    [ "$gauge_done" -gt 0 ] && gauge_base=$(printf '█%.0s' $(seq 1 "$gauge_done"))
    [ "$gauge_will" -gt 0 ] && gauge_rest=$(printf '░%.0s' $(seq 1 "$gauge_will"))
}

gauge() {
    # Note: outputs ...  without closing     # Caller must switch font explicitly after gauge (e.g. )
    if [ "$gauge_done" -eq 0 ]; then
        echo -n "%{F#333333}${gauge_rest}%{F-}"
        return
    fi

    local pos=$(( frame % (gauge_done + 2) ))

    if [ "$pos" -ge "$gauge_done" ]; then
        echo -n "%{F${gauge_color}}${gauge_base}%{F-}%{F#333333}${gauge_rest}%{F-}"
    else
        local before=${gauge_base:0:$pos}
        local shim_end=$(( pos + 2 ))
        [ "$shim_end" -gt "$gauge_done" ] && shim_end=$gauge_done
        local shimmer=${gauge_base:$pos:$((shim_end - pos))}
        local after=${gauge_base:$shim_end}
        echo -n "%{F${gauge_color}}${before}%{F-}%{F${gauge_highlight}}${shimmer}%{F-}%{F${gauge_color}}${after}%{F-}%{F#333333}${gauge_rest}%{F-}"
    fi
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
            echo "$(gauge) ${label}: $(( remaining / 60 ))m${pts}%{T-}"
            ;;
        overtime)
            if [ $(( frame % 5 )) -lt 3 ]; then
                echo "%{F#ff1744}Overtime! $(( remaining / 60 ))m${pts}%{F-}"
            else
                echo "%{F#ff8a80}Overtime! $(( remaining / 60 ))m${pts}%{F-}"
            fi
            ;;
        pomodoro)
            echo "$(gauge) $(( remaining / 60 ))m %{F#000000}${heading}%{F-}${pts}%{T-}"
            ;;
        clocking)
            echo "(${clocked}m) %{F#000000}${heading}%{F-}${pts}%{T-}"
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
