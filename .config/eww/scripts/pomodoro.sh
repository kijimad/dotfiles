#!/bin/bash
#
# Emacs (kd/org-pomodoro-json) の状態を JSON 行にして eww に流す。
# pomodoro 中の HP はボスの体力のように 1 分ごとに削れ、削れた分を残像 (trail) として遅れて縮める
#

trap 'kill 0; exit 0' TERM INT HUP PIPE

TICK=0.25
DRAIN_TICK=0.04  # 残像が縮む間だけ細かく描く
FETCH_SEC=5
TRAIL_HOLD_MS=1000   # 被弾後、残像が縮み始めるまで
TRAIL_DRAIN_MS=1500  # 残像が縮みきるまで

state=off end=0 total=0 heading="" points=0 clocked=0
trail=0 trail_from=0 hit_at=0 fetched_at=0

fetch() {
    local vars rem
    # emacsclient は Lisp の文字列として返すが、その表記は JSON の文字列としても読める
    vars=$(timeout 3 emacsclient -e '(kd/org-pomodoro-json)' 2>/dev/null |
        jq -r 'fromjson | @sh "state=\(.state | ltrimstr(":")) rem=\(.remaining) total=\(.total) heading=\(.heading) points=\(.points) clocked=\(.clocked)"' 2>/dev/null)
    [ -n "$vars" ] || return
    eval "$vars"
    end=$(( EPOCHSECONDS + rem ))
}

# 0.1% 単位の整数を "12.3" にする
pct() { printf '%d.%d' $(( $1 / 10 )) $(( $1 % 10 )); }

mmss() { printf '%s%02d:%02d' "$1" $(( $2 / 60 )) $(( $2 % 60 )); }

now_ms() { echo $(( ${EPOCHREALTIME/./} / 1000 )); }

# 削れたら少し留まり、その後縮む。回復・状態変化では即座に合わせる
update_trail() {
    local cls="$1" hp="$2" now="$3"
    if [ "$cls" != pomodoro ] || [ "$trail" -le "$hp" ]; then
        trail=$hp hit_at=0
        return
    fi
    [ "$hit_at" -eq 0 ] && trail_from=$trail hit_at=$now
    local t=$(( now - hit_at - TRAIL_HOLD_MS ))
    if [ "$t" -ge "$TRAIL_DRAIN_MS" ]; then
        trail=$hp hit_at=0
    elif [ "$t" -gt 0 ]; then
        trail=$(( trail_from - (trail_from - hp) * t / TRAIL_DRAIN_MS ))
    fi
}

emit() {
    local cls="$state" hp=0 time="" label="$heading"
    local remaining=$(( end - EPOCHSECONDS ))
    case "$state" in
        pomodoro)
            # 残り分数を切り上げた値で、1 分ごとに一段削れる
            [ "$total" -gt 0 ] && hp=$(( (remaining + 59) / 60 * 60 * 1000 / total ))
            time=$(mmss "" "$remaining")
            ;;
        short-break|long-break)
            [ "$total" -gt 0 ] && hp=$(( (total - remaining) * 1000 / total ))
            time=$(mmss "" "$remaining")
            cls=break
            label="SHORT REST"
            [ "$state" = long-break ] && label="LONG REST"
            ;;
        overtime)
            time=$(mmss "+" $(( remaining < 0 ? -remaining : remaining )))
            ;;
        clocking)
            hp=1000
            time="${clocked}m"
            ;;
        *)
            cls=off label=""
            ;;
    esac
    [ "$hp" -lt 0 ] && hp=0
    [ "$hp" -gt 1000 ] && hp=1000
    update_trail "$cls" "$hp" "$(now_ms)"

    label="${label//\\/\\\\}"
    label="${label//\"/\\\"}"
    printf '{"cls":"%s","gauge":%s,"trail":%s,"time":"%s","label":"%s","points":%d}\n' \
        "$cls" "$(pct "$hp")" "$(pct "$trail")" "$time" "$label" "$points"
}

while true; do
    if [ $(( EPOCHSECONDS - fetched_at )) -ge "$FETCH_SEC" ]; then
        fetch
        fetched_at=$EPOCHSECONDS
    fi
    emit
    if [ "$hit_at" -ne 0 ]; then sleep "$DRAIN_TICK" & else sleep "$TICK" & fi
    wait $!
done
