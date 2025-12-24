#!/bin/bash

# hosts から uBlacklist 形式に変換
# 使い方: ./scripts/hosts_to_ublacklist.sh >> chrome/uBlacklist.txt

cd `dirname $0`
cd ..

HOSTS_FILE="${1:-adguard/hosts}"

if [ ! -f "$HOSTS_FILE" ]; then
    echo "Error: $HOSTS_FILE not found" >&2
    exit 1
fi

# ||domain.com^ 形式の行からドメインを抽出して uBlacklist 形式に変換
grep -E '^\|\|.*\^$' "$HOSTS_FILE" | \
    sed 's/^||//' | \
    sed 's/\^$//' | \
    sort -u | \
    awk '{print "*://*." $0 "/*"}'
