#!/bin/bash
# Claude Code statusLine スクリプト
# 制限使用率 + 残り時間 + コンテキスト使用率 + Git状態 + ディレクトリ（絵文字・色付き）
# v2.1.80+ rate_limits フィールド対応版

# ANSIカラーコード
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
MAGENTA='\033[35m'
CYAN='\033[36m'
GRAY='\033[90m'
RESET='\033[0m'

# 使用率に応じた色を返す関数
get_color() {
    local pct=$1
    local base=${2:-$CYAN}
    if [ "$pct" -ge 80 ]; then
        echo "$RED"
    elif [ "$pct" -ge 50 ]; then
        echo "$YELLOW"
    else
        echo "$base"
    fi
}

# 入力JSON読み取り
input=$(cat)

# モデル名取得
model=$(echo "$input" | jq -r '.model.display_name')

# CWD取得
cwd=$(echo "$input" | jq -r '.cwd // empty')

# ディレクトリ表示（最深部2階層まで）
dir_str=""
if [ -n "$cwd" ]; then
    parent=$(basename "$(dirname "$cwd")")
    current=$(basename "$cwd")
    if [ "$parent" = "/" ] || [ "$parent" = "." ]; then
        short_cwd="$current"
    else
        short_cwd="${parent}/${current}"
    fi
    if [ ${#short_cwd} -gt 24 ]; then
        short_cwd="…${short_cwd: -23}"
    fi
    dir_str="${GRAY}${short_cwd}${RESET}"
fi

# Git状態取得
git_str=""
if [ -n "$cwd" ]; then
    if git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1; then
        branch=$(git -C "$cwd" branch --show-current 2>/dev/null)
        if [ -z "$branch" ]; then
            branch=$(git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
        fi
        if [ -n "$branch" ]; then
            if [ -n "$(git -C "$cwd" status --porcelain 2>/dev/null)" ]; then
                git_str="${MAGENTA}⎇ ${branch}${YELLOW}*${RESET}"
            else
                git_str="${GREEN}⎇ ${branch}${RESET}"
            fi
        fi
    fi
fi

# プログレスバー生成関数
make_progress_bar() {
    local pct=$1
    local width=${2:-10}
    local filled=$((pct * width / 100))
    local empty=$((width - filled))
    local bar=""
    for ((i=0; i<filled; i++)); do bar+="█"; done
    for ((i=0; i<empty; i++)); do bar+="░"; done
    echo "$bar"
}

# コンテキスト使用率計算 - ベースカラー: 緑
ctx_str=""
usage=$(echo "$input" | jq '.context_window.current_usage')
if [ "$usage" != "null" ]; then
    current=$(echo "$usage" | jq '.input_tokens + .cache_creation_input_tokens + .cache_read_input_tokens')
    size=$(echo "$input" | jq '.context_window.context_window_size')
    ctx_pct=$(( (current * 100 + size / 2) / size ))
    ctx_color=$(get_color $ctx_pct "$GREEN")
    ctx_bar=$(make_progress_bar $ctx_pct 10)
    ctx_str="📊 Ctx [${ctx_color}${ctx_bar}${RESET}] ${ctx_color}${ctx_pct}%${RESET}"
fi

# レート制限（v2.1.80+ rate_limits フィールドから直接取得）
five_hour_str=""
five_hour_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
if [ -n "$five_hour_pct" ]; then
    five_hour_int=$(printf "%.0f" "$five_hour_pct")
    hour_color=$(get_color $five_hour_int "$CYAN")
    hour_bar=$(make_progress_bar $five_hour_int 10)

    time_left=""
    reset_epoch=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
    if [ -n "$reset_epoch" ]; then
        diff=$((reset_epoch - $(date +%s)))
        if [ "$diff" -gt 0 ]; then
            time_left=" ${GRAY}($((diff / 3600))h$(((diff % 3600) / 60))m)${RESET}"
        fi
    fi

    five_hour_str="⏱️  5h [${hour_color}${hour_bar}${RESET}] ${hour_color}${five_hour_int}%${RESET}${time_left}"
fi

seven_day_str=""
seven_day_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
if [ -n "$seven_day_pct" ]; then
    seven_day_int=$(printf "%.0f" "$seven_day_pct")
    week_color=$(get_color $seven_day_int "$MAGENTA")
    week_bar=$(make_progress_bar $seven_day_int 10)
    seven_day_str="📅  7d [${week_color}${week_bar}${RESET}] ${week_color}${seven_day_int}%${RESET}"
fi

# 出力（表示は従来と同一）
line1="${CYAN}${model}${RESET}"
[ -n "$git_str" ] && line1="$line1 ${GRAY}|${RESET} $git_str"
[ -n "$dir_str" ] && line1="$line1 ${GRAY}|${RESET} $dir_str"

echo -e "$line1"
[ -n "$five_hour_str" ] && echo -e "$five_hour_str"
[ -n "$seven_day_str" ] && echo -e "$seven_day_str"
[ -n "$ctx_str" ] && echo -e "$ctx_str"
