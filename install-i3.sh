#!/usr/bin/env bash
# Lightweight i3 (X11) setup for old and modern hardware.
# Run from anywhere as a normal user.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
APT_UPDATED=0

log() { printf '[thisforoldpc] %s\n' "$*"; }
fail() { printf '[thisforoldpc] FAIL: %s\n' "$*" >&2; exit 1; }

command_exists() { command -v "$1" >/dev/null 2>&1; }

priv() {
    if [ -n "${TFOP_PRIV:-}" ]; then
        command_exists "$TFOP_PRIV" || fail "TFOP_PRIV=$TFOP_PRIV is not installed"
        "$TFOP_PRIV" "$@"
    elif command_exists sudo; then
        sudo "$@"
    elif command_exists doas; then
        doas "$@"
    else
        fail "no privilege helper found (sudo or doas)"
    fi
}

detect_pkg() {
    if command_exists apt; then echo apt
    elif command_exists dnf; then echo dnf
    elif command_exists pacman; then echo pacman
    elif command_exists zypper; then echo zypper
    else echo unknown; fi
}

PKG="$(detect_pkg)"
[ "$PKG" = unknown ] && fail "unsupported distro (need apt, dnf, pacman or zypper)"
[ "$(id -u)" -eq 0 ] && fail "run as a normal user, not root"

apt_update_once() {
    [ "$APT_UPDATED" -eq 1 ] && return 0
    [ "${TFOP_SKIP_APT_UPDATE:-0}" = 1 ] && return 0
    priv apt-get update
    APT_UPDATED=1
}

pkg_installed() {
    case "$PKG" in
        apt) dpkg -s "$1" >/dev/null 2>&1 ;;
        dnf|zypper) rpm -q "$1" >/dev/null 2>&1 ;;
        pacman) pacman -Q "$1" >/dev/null 2>&1 ;;
    esac
}

install() {
    local pkg
    local missing=()
    for pkg in "$@"; do
        pkg_installed "$pkg" || missing+=("$pkg")
    done
    [ "${#missing[@]}" -eq 0 ] && return 0
    case "$PKG" in
        apt) apt_update_once; priv apt-get install -y "${missing[@]}" ;;
        dnf) priv dnf install -y "${missing[@]}" ;;
        pacman) priv pacman -Sy --noconfirm "${missing[@]}" ;;
        zypper) priv zypper install -y "${missing[@]}" ;;
    esac
}

install_file() {
    local src="$SCRIPT_DIR/$1" dst="$CONFIG_DIR/$2"
    [ -f "$src" ] || fail "missing payload: $src"
    mkdir -p "$(dirname "$dst")"
    if [ -e "$dst" ] || [ -L "$dst" ]; then
        local bak="${dst}.bak.$(date +%Y%m%d-%H%M%S)"
        cp -a "$dst" "$bak"
        log "backed up $dst to $bak"
    fi
    cp "$src" "$dst"
    log "installed $dst"
}

install xorg i3-wm i3status i3lock dmenu xterm thunar alacritty firefox feh neovim

# Compositor only when a display adapter is visible.
if command_exists lspci; then
    GPU="$(lspci | grep -iE 'vga|3d|display' | head -1 || true)"
    if printf '%s' "$GPU" | grep -qiE 'intel|amd|radeon|nvidia|quadro'; then
        install picom 2>/dev/null || log "picom not available on this release; skipping"
    fi
else
    log "lspci not installed; skipping automatic compositor detection"
fi

install zram-generator 2>/dev/null || log "zram-generator not available; skipping"
install tlp 2>/dev/null || log "tlp not available; skipping"

install_file configs/i3/config i3/config
install_file configs/nvim/init.lua nvim/init.lua
install_file configs/alacritty/alacritty.toml alacritty/alacritty.toml
install_file configs/thunar/uca.xml Thunar/uca.xml
install_file configs/picom/picom.conf picom/picom.conf
install_file configs/gtk-3.0/settings.ini gtk-3.0/settings.ini

log "done. Log out and select the i3 session."
