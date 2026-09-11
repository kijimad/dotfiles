# bashに依存しない
# GUIアプリで使うものやbin/sh で使うものを置く
# 例: 環境変数, PATH

# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi

# Joy-Con 入力安定化(SDL/antimicrox 用)
# SDL が HIDAPI で Joy-Con の hidraw を直叩きすると、kernel の hid-nintendo や
# Chrome とサブコマンドを撃ち合い R が無反応になる。HIDAPI を切ると SDL は
# kernel の evdev を読むようになり競合から抜ける。
# export SDL_JOYSTICK_HIDAPI_SWITCH=0
export SDL_JOYSTICK_HIDAPI_JOY_CONS=0

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

if [ -d "$HOME/.cargo" ] ; then
    PATH="$HOME/.cargo/bin:$PATH"
fi

# go公式のディレクトリ
if [ -d "/usr/local/go/bin" ] ; then
    export PATH=$PATH:/usr/local/go/bin
fi

if [ -d "$HOME/go/bin" ] ; then
    export GOPATH=$HOME/go
    export GOBIN=$GOPATH/bin
    export PATH=$PATH:$GOBIN
fi

# for OpenGL
if [ -d "/usr/lib/x86_64-linux-gnu/pkgconfig" ] ; then
    export PKG_CONFIG_PATH=/usr/lib/x86_64-linux-gnu/pkgconfig
fi

# PRIME Render Offload (外部GPUがある時だけ)
# 画面出力は AMD iGPU のまま(=suspend/resume が安定)、GL/Vulkan の描画を RTX 3050 へ。
# NVIDIA を画面駆動 GPU にすると resume で固まるため、表示は AMD に残しつつ描画だけ dGPU。
# /proc/driver/nvidia/gpus/ は NVIDIA GPU がバインドされている時だけ非空になるので、
# eGPU 未接続/カード無しの環境ではこのブロックは発火せず、GL が nvidia ベンダを探して
# 壊れることもない(ポータブル)。反映は次回ログインから。
if [ -d /proc/driver/nvidia/gpus ] && [ -n "$(ls -A /proc/driver/nvidia/gpus 2>/dev/null)" ]; then
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
fi
