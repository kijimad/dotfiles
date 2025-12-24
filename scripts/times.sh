#!/bin/bash
set -eux

#################################
# 現在時刻を読み上げるスクリプト
# cronから呼び出される
#################################

export XDG_RUNTIME_DIR="/run/user/1000"

cd `dirname $0`

current_hour=$(date +"%H")

spd-say "$current_hour"
