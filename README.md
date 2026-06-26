# Keyboard Layout Indicator

A polished Material Design 3 keyboard layout plugin for [DankMaterialShell](https://github.com/anasrar/DankMaterialShell) (DMS).

It shows your active Hyprland keyboard layout directly in the bar, lets you cycle through layouts with a single click, and opens a full layout picker on right-click — all styled to feel like a native DMS widget.

---

## Features

- Displays active keyboard layout in the bar (short code, full name, or flag)
- Left-click to instantly cycle through all configured layouts
- Right-click to open a popout picker with all available layouts
- Center-screen overlay animation on layout change
- Real-time layout detection via Hyprland IPC (`activelayout` events) — no polling lag
- Supports 26+ languages out of the box (US, ES, MX, DE, FR, JP, RU, ZH, and more)
- Fully themed with Material Design 3 — adapts to your DMS color scheme
- No external dependencies beyond Hyprland and Quickshell

---

## Requirements

| Dependency | Version |
|---|---|
| [Hyprland](https://hyprland.org/) | 0.55+ |
| [Quickshell](https://quickshell.outfoxxed.me/) | 0.3+ |
| [DankMaterialShell](https://github.com/anasrar/DankMaterialShell) | 1.4.6+ |

> This plugin uses Hyprland IPC (`hyprctl`) and the official DMS plugin API. It does **not** require `waybar`, `xkb-switch`, or any other external tool.

---

## Installation

### Automatic (recommended)

```bash
git clone https://github.com/keorgtz/KeyboardLayoutIndicator.git
cd KeyboardLayoutIndicator
./install.sh
```

The script copies the plugin files to `~/.config/DankMaterialShell/plugins/keyboardLayoutIndicator/` and checks that all dependencies are present.

### Manual

```bash
PLUGIN_DIR="$HOME/.config/DankMaterialShell/plugins/keyboardLayoutIndicator"
mkdir -p "$PLUGIN_DIR"
cp *.qml qmldir plugin.json "$PLUGIN_DIR/"
```

---

## Setup in DMS

1. Open DankMaterialShell settings
2. Go to **Plugins**
3. Enable **Keyboard Layout** and add it to your bar
4. Restart DMS or reload Quickshell:

```bash
quickshell -r
```

---

## Configuration

Open the plugin settings panel inside DMS to adjust the following options:

| Option | Default | Description |
|---|---|---|
| Show Flag | `true` | Show the country flag emoji next to the layout |
| Show Layout Code | `true` | Show the short code (e.g. `US`, `DE`, `FR`) |
| Show Full Language Name | `false` | Show the full name (e.g. `English (US)`) instead of the short code |
| Refresh Interval | `2000 ms` | How often to re-sync with Hyprland (fallback polling; IPC is used primarily) |

---

## Usage

| Action | Result |
|---|---|
| Left-click the widget | Cycle to the next layout |
| Right-click the widget | Open the layout picker popout |
| Press a Hyprland keybind | Widget updates instantly via IPC |

### Configuring layouts in Hyprland

Add multiple layouts to your `hyprland.conf`:

```ini
input {
    kb_layout = us,es,de
}
```

The plugin automatically detects all configured layouts.

---

## Supported Layouts

| Code | Language | Flag |
|---|---|---|
| `us` | English (US) | 🇺🇸 |
| `es` | Español | 🇪🇸 |
| `mx` | Español (MX) | 🇲🇽 |
| `latam` | Español (Lat.) | 🌎 |
| `de` | Deutsch | 🇩🇪 |
| `fr` | Français | 🇫🇷 |
| `it` | Italiano | 🇮🇹 |
| `pt` | Português | 🇵🇹 |
| `br` | Português (BR) | 🇧🇷 |
| `ru` | Русский | 🇷🇺 |
| `ja` | 日本語 | 🇯🇵 |
| `zh` | 中文 | 🇨🇳 |
| `ko` | 한국어 | 🇰🇷 |
| `ar` | العربية | 🇸🇦 |
| `pl` | Polski | 🇵🇱 |
| `nl` | Nederlands | 🇳🇱 |
| `tr` | Türkçe | 🇹🇷 |
| `sv` | Svenska | 🇸🇪 |
| `no` | Norsk | 🇳🇴 |
| `da` | Dansk | 🇩🇰 |
| `fi` | Suomi | 🇫🇮 |
| `cs` | Čeština | 🇨🇿 |
| `sk` | Slovenčina | 🇸🇰 |
| `hu` | Magyar | 🇭🇺 |
| `ro` | Română | 🇷🇴 |
| `uk` | Українська | 🇺🇦 |
| `he` | עברית | 🇮🇱 |
| `el` | Ελληνικά | 🇬🇷 |

Layouts not in this list still work — the plugin falls back to the raw XKB name from Hyprland.

---

## Project Structure

```
keyboardLayoutIndicator/
├── plugin.json               # DMS plugin manifest
├── qmldir                    # Quickshell module declaration
├── KeyboardLayout.qml        # Bar widget (pill)
├── KeyboardService.qml       # Singleton — all state and IPC logic
├── KeyboardLayoutsModel.qml  # Layout list model
├── KeyboardPopout.qml        # Right-click popout panel
├── KeyboardLayoutSettings.qml # Settings panel inside DMS
└── install.sh                # Installer script
```

---

## License

MIT — see [LICENSE](LICENSE) file.

---

## Author

Made by [Keorsoft](https://github.com/keorgtz)
