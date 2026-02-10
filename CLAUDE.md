# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

This is **Tiger LCD**, a retro LCD-inspired light theme for [Omarchy](https://omarchy.com) (a Hyprland-based Linux desktop). It mimics the aesthetic of Tiger Electronics handheld games — cool silver backgrounds, desaturated colors, and optional LCD text shadows.

## Theme Installation

```bash
omarchy-theme-install https://github.com/thec0mmrade/omarchy-tiger-lcd
omarchy-theme-set tiger-lcd
```

Optional extras (Departure Mono Nerd Font, Ghostty LCD shader, and GTK4 overrides) are installed separately via `./extras/setup-lcd-extras.sh`.

## Architecture

The theme is a flat collection of config files consumed by `omarchy-theme-set`. Each file targets a specific application:

- **`colors.toml`** — Canonical color palette (TOML). Terminal colors (color0–color15) plus accent, cursor, foreground, background, selection colors. This is the **single source of truth** for the palette; all other files should use these same hex values.
- **`hyprland.conf`** — Hyprland window manager overrides: border colors, rounding (0 for LCD look), shadow, blur disabled.
- **`light.mode`** — Marker file. Presence tells omarchy to set `prefer-light` and use the Adwaita GTK theme.
- **`waybar.css`** / **`walker.css`** / **`swayosd.css`** — CSS overrides for Waybar, Walker (launcher), and SwayOSD respectively. All use `text-shadow` and `icon-shadow` for the LCD effect.
- **`btop.theme`** — btop++ color theme using `theme[key]="hex"` syntax.
- **`neovim.lua`** — LazyVim plugin spec that installs and sets the `zenbones` colorscheme.
- **`vscode.json`** — VS Code theme reference (`{"name": "tiger-lcd", "extension": "..."`}).
- **`chromium.theme`** — Chromium toolbar RGB values (comma-separated).
- **`icons.theme`** — GTK icon theme name.
- **`backgrounds/`** — Wallpaper images. Numbered filenames (e.g., `1-game-and-watch.jpg`) set ordering; the first is the default.

### Extras (outside omarchy theme system)

Files in `extras/` are **not** managed by `omarchy-theme-set` and must be installed/removed manually:

- **`extras/DepartureMonoNerdFont*.otf`** — Nerd Font-patched Departure Mono font files (Regular, Mono, Propo). Installed to `~/.local/share/fonts/` and set as system font via `omarchy-font-set`.
- **`extras/lcd-shadow.glsl`** — GLSL fragment shader for Ghostty that renders a diagonal LCD drop shadow on text.
- **`extras/gtk4-lcd.css`** — libadwaita/GTK4 color overrides for apps like Nautilus.
- **`extras/setup-lcd-extras.sh`** — Idempotent install script for the above extras.

## Key Color Values

| Role       | Hex       |
|------------|-----------|
| Background | `#BCBDC1` |
| Foreground | `#2A2B26` |
| Accent     | `#626870` |
| Selection BG | `#474A4F` |

When editing theme files, ensure hex values stay consistent with `colors.toml`. The LCD text shadow used across CSS files is `1px 1px 0px rgba(42, 43, 38, 0.3)` (derived from the foreground color).
