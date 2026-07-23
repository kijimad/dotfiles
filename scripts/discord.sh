#!/bin/bash
set -eu

###########
# discord に通知する
# メッセージ本文はハードコード。作業文脈 (プロジェクト/ブランチ/ホスト) を付けて送る。
###########

# Stop フックは cwd=作業中プロジェクトで実行されるので $PWD をそのまま使える。
# cd はしない: cd すると $PWD が変わって文脈を拾えなくなる。.env は絶対パスで読む
proj=$(basename "$PWD")

# git リポジトリ内ならブランチ名を拾う
branch=""
if command -v git >/dev/null 2>&1; then
  branch=$(git -C "$PWD" rev-parse --abbrev-ref HEAD 2>/dev/null || true)
fi

host=$(hostname 2>/dev/null || echo "${HOSTNAME:-unknown}")

# 本文を組み立てる。実際の改行を含む
body=$(printf '✅️ claude 実行終了\nproject: %s%s\nhost:    %s' \
  "$proj" "${branch:+ ($branch)}" "$host")

# .secret submodule が未チェックアウトの環境もあるので、あるときだけ読む
if [ -f ~/dotfiles/.secret/.env ]; then
  source ~/dotfiles/.secret/.env
fi

# webhook が無ければ何もせず正常終了
if [ -z "${DISCORD_CLAUDE_WEBHOOK:-}" ]; then
  echo "discord.sh: DISCORD_CLAUDE_WEBHOOK 未設定のため通知をスキップ" >&2
  exit 0
fi

# コードブロックで囲み、jq で JSON を安全にエンコード。改行/記号のエスケープを任せる
content=$(printf '```\n%s\n```' "$body")
payload=$(jq -n --arg content "$content" '{content: $content}')

curl -s -H "Content-Type: application/json" \
  -d "$payload" \
  "$DISCORD_CLAUDE_WEBHOOK"
