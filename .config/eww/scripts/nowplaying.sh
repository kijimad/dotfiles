#!/bin/bash
#
# playerctl の変化を待ち受けて、eww 用の JSON 行にする
#

trap 'kill 0; exit 0' TERM INT HUP PIPE

emit() {
    jq -nc --arg status "$1" --arg line "$2" '{status: $status, line: $line}'
}

emit "" ""
# プレイヤーが居ないと playerctl は終了するので、待ち直す
while true; do
    playerctl --follow metadata --format $'{{status}}\t{{title}}\t{{artist}}' 2>/dev/null |
        while IFS=$'\t' read -r status title artist; do
            line="$title"
            [ -n "$artist" ] && line="$title — $artist"
            emit "$status" "$line"
        done
    emit "" ""
    sleep 3
done
