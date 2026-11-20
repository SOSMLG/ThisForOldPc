#!/usr/bin/env bash
# Distro-agnostic i3 setup (X11), daily-use ready, old+modern hardware.
set -euo pipefail

detect_pkg() {
  if command -v apt >/dev/null 2>&1; then echo apt
  elif command -v dnf >/dev/null 2>&1; then echo dnf
  elif command -v pacman >/dev/null 2>&1; then echo pacman
  elif command -v zypper >/dev/null 2>&1; then echo zypper
  else echo unknown; fi
}
PKG=$(detect_pkg)
[ "$PKG" = unknown ] && { echo "Unsupported distro"; exit 1; }

install() {
  case "$PKG" in
    apt)    sudo apt update && sudo apt install -y "$@" ;;
    dnf)    sudo dnf install -y "$@" ;;
    pacman) sudo pacman -Sy --noconfirm "$@" ;;
    zypper) sudo zypper install -y "$@" ;;
  esac
}

install xorg i3-wm i3status i3lock dmenu xterm thunar alacritty firefox feh neovim

# Compositor only if GPU capable
GPU=$(lspci | grep -iE 'vga|3d|display' | head -1)
if echo "$GPU" | grep -qiE 'intel|amd|radeon|nvidia|quadro'; then
  install picom 2>/dev/null || true
fi

# Performance
install zram-generator 2>/dev/null || true
install tlp 2>/dev/null || true

mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}/i3"
cp configs/i3/config "${XDG_CONFIG_HOME:-$HOME/.config}/i3/config"
mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
cp configs/nvim/init.lua "${XDG_CONFIG_HOME:-$HOME/.config}/nvim/init.lua"
mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}/alacritty"
cp configs/alacritty/alacritty.toml "${XDG_CONFIG_HOME:-$HOME/.config}/alacritty/alacritty.toml"
mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}/Thunar"
cp configs/thunar/uca.xml "${XDG_CONFIG_HOME:-$HOME/.config}/Thunar/uca.xml"
mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}/picom"
cp configs/picom/picom.conf "${XDG_CONFIG_HOME:-$HOME/.config}/picom/picom.conf"

echo ">> Done. Log out and select i3 session."
