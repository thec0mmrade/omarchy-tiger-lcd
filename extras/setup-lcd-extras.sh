#!/usr/bin/env bash
# setup-lcd-extras.sh — Install optional LCD extras for the Tiger LCD theme
# Safe to run multiple times (idempotent)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GHOSTTY_DIR="$HOME/.config/ghostty"
GTK4_DIR="$HOME/.config/gtk-4.0"

echo "=== Tiger LCD Extras Setup ==="
echo

# --- Departure Mono Nerd Font ---
FONT_DIR="$HOME/.local/share/fonts"
FONT_NAME="DepartureMono Nerd Font"

if [ -f "$FONT_DIR/DepartureMonoNerdFont-Regular.otf" ]; then
  echo "[ok] $FONT_NAME already installed (skipped)"
else
  mkdir -p "$FONT_DIR"
  cp "$SCRIPT_DIR"/DepartureMonoNerdFont*.otf "$FONT_DIR/"
  echo "[ok] Copied Departure Mono Nerd Font files to $FONT_DIR/"
  fc-cache -f
  echo "[ok] Font cache rebuilt"
fi

if command -v omarchy-font-set &>/dev/null; then
  omarchy-font-set "$FONT_NAME"
  echo "[ok] Set system font to $FONT_NAME via omarchy-font-set"
else
  echo "[!!] omarchy-font-set not found — set your terminal font to '$FONT_NAME' manually"
fi

echo

# --- Ghostty LCD shadow shader ---
if [ -d "$GHOSTTY_DIR" ]; then
  cp "$SCRIPT_DIR/lcd-shadow.glsl" "$GHOSTTY_DIR/lcd-shadow.glsl"
  echo "[ok] Copied lcd-shadow.glsl to $GHOSTTY_DIR/"

  GHOSTTY_CONF="$GHOSTTY_DIR/config"
  if [ -f "$GHOSTTY_CONF" ]; then
    # Remove any existing custom-shader lines (and their comments) before adding ours
    sed -i '/^#.*shader/d; /^custom-shader/d; /^custom-shader-animation/d' "$GHOSTTY_CONF"
    # Remove trailing blank lines left behind
    sed -i -e :a -e '/^\n*$/{$d;N;ba' -e '}' "$GHOSTTY_CONF"
    printf '\n# LCD drop shadow shader\ncustom-shader = ~/.config/ghostty/lcd-shadow.glsl\ncustom-shader-animation = false\n' >> "$GHOSTTY_CONF"
    echo "[ok] Replaced custom-shader lines in $GHOSTTY_CONF"
  else
    echo "[!!] No ghostty config found at $GHOSTTY_CONF — add these lines manually:"
    echo '    custom-shader = ~/.config/ghostty/lcd-shadow.glsl'
    echo '    custom-shader-animation = false'
  fi
else
  echo "[skip] Ghostty config directory not found at $GHOSTTY_DIR"
fi

echo

# --- GTK4 / libadwaita overrides ---
mkdir -p "$GTK4_DIR"
if [ -f "$GTK4_DIR/gtk.css" ]; then
  if grep -q "TigerLCD" "$GTK4_DIR/gtk.css"; then
    echo "[ok] gtk.css already contains TigerLCD overrides (skipped)"
  else
    BACKUP="$GTK4_DIR/gtk.css.bak.$(date +%s)"
    cp "$GTK4_DIR/gtk.css" "$BACKUP"
    echo "[ok] Backed up existing gtk.css to $BACKUP"
    cp "$SCRIPT_DIR/gtk4-lcd.css" "$GTK4_DIR/gtk.css"
    echo "[ok] Installed TigerLCD gtk.css to $GTK4_DIR/"
  fi
else
  cp "$SCRIPT_DIR/gtk4-lcd.css" "$GTK4_DIR/gtk.css"
  echo "[ok] Installed TigerLCD gtk.css to $GTK4_DIR/"
fi

echo
echo "=== Done ==="
echo
echo "NOTE: These extras live OUTSIDE the omarchy theme system."
echo "When you switch to a different theme, remove them manually:"
echo
echo "  rm ~/.local/share/fonts/DepartureMonoNerdFont*.otf && fc-cache -f"
echo "  omarchy-font-set <your-preferred-font>"
echo "  rm ~/.config/ghostty/lcd-shadow.glsl"
echo "  rm ~/.config/gtk-4.0/gtk.css"
echo
echo "And remove these lines from ~/.config/ghostty/config:"
echo "  custom-shader = ~/.config/ghostty/lcd-shadow.glsl"
echo "  custom-shader-animation = false"
