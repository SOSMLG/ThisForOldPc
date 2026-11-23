#!/usr/bin/env bash
# Read-only end-state verifier for ThisForOldPc.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
STATUS=0

report() {
    local level="$1" name="$2" message="$3"
    printf '[%s] %s: %s\n' "$level" "$name" "$message"
    [ "$level" = FAIL ] && STATUS=1
    return 0
}

check_file() {
    local name="$1" path="$2"
    if [ -f "$path" ]; then
        report PASS "$name" "$path exists"
    else
        report FAIL "$name" "$path is missing"
    fi
}

check_file "installer" "$SCRIPT_DIR/install.sh"

for pair in \
    "i3-config|i3/config" \
    "nvim-config|nvim/init.lua" \
    "alacritty-config|alacritty/alacritty.toml" \
    "thunar-actions|Thunar/uca.xml" \
    "picom-config|picom/picom.conf" \
    "gtk-settings|gtk-3.0/settings.ini"; do
    name="${pair%%|*}"
    rel="${pair#*|}"
    if [ -f "$CONFIG_DIR/$rel" ]; then
        report PASS "$name" "deployed to $CONFIG_DIR/$rel"
    else
        report WARN "$name" "not deployed yet"
    fi
done

for cmd in i3 i3status i3lock dmenu alacritty thunar firefox; do
    if command -v "$cmd" >/dev/null 2>&1; then
        report PASS "$cmd" "installed"
    else
        report WARN "$cmd" "not found on PATH"
    fi
done

exit "$STATUS"
