#!/bin/bash

# uBlacklist.txt からドメインを抽出して hosts フォーマットで出力
# 使い方: ./scripts/ublacklist_to_hosts.sh >> adguard/hosts

cd `dirname $0`
cd ..

UBLACKLIST_FILE="${1:-chrome/uBlacklist.txt}"

if [ ! -f "$UBLACKLIST_FILE" ]; then
    echo "Error: $UBLACKLIST_FILE not found" >&2
    exit 1
fi

# *://*.domain.com/* 形式の行からドメインを抽出
grep -E '^\*://\*\.' "$UBLACKLIST_FILE" | \
    sed 's|^\*://\*\.||' | \
    sed 's|/\*$||' | \
    sort -u | \
    awk '{print "||" $0 "^"}'
