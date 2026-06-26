#!/usr/bin/env bash
set -euo pipefail

PLUGIN_ID="keyboardLayoutIndicator"
PLUGIN_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/DankMaterialShell/plugins/$PLUGIN_ID"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

info()    { echo -e "${CYAN}>${RESET} $*"; }
success() { echo -e "${GREEN}✓${RESET} $*"; }
warn()    { echo -e "${YELLOW}!${RESET} $*"; }
error()   { echo -e "${RED}✗${RESET} $*" >&2; exit 1; }

echo -e "${BOLD}Keyboard Layout Indicator — DankMaterialShell Plugin${RESET}"
echo

# ── Dependency checks ─────────────────────────────────────────────────────────
info "Checking dependencies..."

if ! command -v hyprctl &>/dev/null; then
    error "hyprctl not found. This plugin requires Hyprland."
fi
success "Hyprland (hyprctl) found"

if ! command -v quickshell &>/dev/null; then
    warn "quickshell not found in PATH. Make sure Quickshell is installed before restarting DMS."
else
    success "Quickshell found"
fi

DMS_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/DankMaterialShell"
if [ ! -d "$DMS_CONFIG" ]; then
    error "DankMaterialShell config directory not found at $DMS_CONFIG. Install DMS first."
fi
success "DankMaterialShell config found"

# ── Install ───────────────────────────────────────────────────────────────────
echo
info "Installing plugin to: $PLUGIN_DIR"

if [ -d "$PLUGIN_DIR" ]; then
    warn "Existing installation found — overwriting"
fi

mkdir -p "$PLUGIN_DIR"

FILES=(
    plugin.json
    qmldir
    KeyboardLayout.qml
    KeyboardLayoutSettings.qml
    KeyboardLayoutsModel.qml
    KeyboardPopout.qml
    KeyboardService.qml
    KeyboardOverlay.qml
)

for f in "${FILES[@]}"; do
    src="$SCRIPT_DIR/$f"
    if [ -f "$src" ]; then
        cp "$src" "$PLUGIN_DIR/$f"
        success "Copied $f"
    else
        warn "File not found, skipping: $f"
    fi
done

# ── Done ──────────────────────────────────────────────────────────────────────
echo
echo -e "${GREEN}${BOLD}Installation complete!${RESET}"
echo
echo -e "  Plugin installed to: ${CYAN}$PLUGIN_DIR${RESET}"
echo
echo "  Next steps:"
echo "  1. Open DankMaterialShell settings"
echo "  2. Navigate to Plugins"
echo "  3. Enable \"Keyboard Layout\" and add it to your bar"
echo "  4. Restart DMS or reload Quickshell if it is already running"
echo
echo -e "  To restart Quickshell:  ${CYAN}quickshell -r${RESET}"
