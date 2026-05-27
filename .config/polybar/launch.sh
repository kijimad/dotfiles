#!/bin/sh
set -x

# Terminate already running bar instances and tail scripts
killall -q polybar
killall -q -f pomodoro-bar.sh

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Launch Polybar, using default config location ~/.config/polybar/config

# Multi Monitor setup -> https://github.com/polybar/polybar/issues/763#issuecomment-331604987
if type "xrandr"; then
  for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    MONITOR=$m polybar --reload top &
  done
else
  polybar --reload top &
fi

echo "Polybar launched..."
