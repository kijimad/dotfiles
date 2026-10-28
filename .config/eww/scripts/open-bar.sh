#!/bin/bash
#
# bar を開き、実際の高さ (物理ピクセル) を struts に渡し直す。
# eww は X11 の struts に GDK の倍率を掛けず、高さも中身で決まるため、開いてから測る
#

eww open bar --arg strut=0px

for _ in {1..20}; do
    h=$(xwininfo -name 'Eww - bar' 2>/dev/null | awk '/Height:/ {print $2}')
    [ -n "$h" ] && break
    sleep 0.1
done

[ -n "$h" ] || exit 1
eww close bar
eww open bar --arg strut="${h}px"
