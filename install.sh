#!/bin/bash
# ============================================================
# Switch Installer - XFCE Theme Toggle Tool
# Version: 1.1.0
# Author: Prabin Thapa <praabinn@protonmail.com> https://github.com/nixpt
# License: MIT
# ============================================================

set -e
VERSION="1.1.0"

echo "========================================"
echo " Installing Switch v$VERSION "
echo "========================================"

# -----------------------------
# Directories
# -----------------------------
INSTALL_DIR="$HOME/.local/share/switch"
CONFIG_DIR="$HOME/.config/switch"
CACHE_DIR="$HOME/.cache"
BIN_DIR="$HOME/.local/bin"
APPLICATIONS_DIR="$HOME/.local/share/applications"

mkdir -p "$INSTALL_DIR" "$CONFIG_DIR" "$CACHE_DIR" "$BIN_DIR" "$APPLICATIONS_DIR"

# -----------------------------
# LICENSE file
# -----------------------------
cat > "$INSTALL_DIR/LICENSE" << 'EOF'
MIT License

Copyright (c) 2025 Prabin Thapa

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

[...standard MIT text continues...]
EOF

# -----------------------------
# Main switch script
# -----------------------------
cat > "$INSTALL_DIR/switch.sh" << 'EOF'
#!/bin/bash
# Switch - XFCE Theme Toggle Tool
# Version: 1.1.0
# Author: Prabin Thapa <praabinn@protonmail.com> https://github.com/nixpt
# License: MIT

INSTALL_DIR="$HOME/.local/share/switch"
CONFIG_DIR="$HOME/.config/switch"

UPDATE_CONFIG=0
FORCE_CHOOSE=0
SWITCH_PANEL=1

for arg in "$@"; do
    case $arg in
        -u|--updateconfig) UPDATE_CONFIG=1 ;;
        -c|--choose) FORCE_CHOOSE=1 ;;
        --panel) SWITCH_PANEL=1 ;;
        -h|--help)
            echo "Usage: $0 [--panel] [--choose] [--updateconfig] [--version] [--about]"
            exit 0 ;;
        --version)
            echo "Switch 1.1.0"
            exit 0 ;;
        --about)
            echo "Switch - XFCE Theme Toggle Tool by Prabin Thapa"
            echo "License: MIT"
            exit 0 ;;
    esac
done

THEME_DIRS=(/usr/share/themes "$HOME/.themes")

generate_gtk_mapping() {
    mkdir -p "$CONFIG_DIR"
    echo "# Switch GTK theme mapping (auto-generated)" > "$CONFIG_DIR/switch-map"
    declare -A DARK_VARIANTS
    for DIR in "${THEME_DIRS[@]}"; do
        [ -d "$DIR" ] || continue
        for THEME_PATH in "$DIR"/*; do
            THEME_NAME=$(basename "$THEME_PATH")
            [[ "$THEME_NAME" =~ ^\. ]] && continue
            if [[ "$THEME_NAME" =~ [Dd]ark ]]; then
                DARK_THEME="$THEME_NAME"
                LIGHT_THEME="${DARK_THEME//[Dd]ark/}"
                [[ -z "$LIGHT_THEME" ]] && LIGHT_THEME="$DARK_THEME"
                if [[ -n "${DARK_VARIANTS[$LIGHT_THEME]}" ]]; then
                    DARK_VARIANTS["$LIGHT_THEME"]+=",${DARK_THEME}"
                else
                    DARK_VARIANTS["$LIGHT_THEME"]="$DARK_THEME"
                fi
            fi
        done
    done
    for LIGHT in "${!DARK_VARIANTS[@]}"; do
        echo "$LIGHT=${DARK_VARIANTS[$LIGHT]}" >> "$CONFIG_DIR/switch-map"
        IFS=',' read -ra DARKS <<< "${DARK_VARIANTS[$LIGHT]}"
        for DARK in "${DARKS[@]}"; do
            echo "$DARK=$LIGHT" >> "$CONFIG_DIR/switch-map"
        done
    done
}

[[ ! -f "$CONFIG_DIR/switch-map" || $UPDATE_CONFIG -eq 1 ]] && generate_gtk_mapping

declare -A THEME_MAP
while IFS='=' read -r KEY VALUE; do
    [[ "$KEY" =~ ^#.*$ ]] && continue
    [[ -z "$KEY" ]] && continue
    THEME_MAP["$KEY"]="$VALUE"
done < "$CONFIG_DIR/switch-map"

declare -A PREF_MAP
[ -f "$CONFIG_DIR/switch-preferred" ] && while IFS='=' read -r LIGHT DARK; do
    [[ "$LIGHT" =~ ^#.*$ ]] && continue
    [[ -z "$LIGHT" ]] && continue
    PREF_MAP["$LIGHT"]="$DARK"
done < "$CONFIG_DIR/switch-preferred"

set_panel_style() {
    local MODE="$1"
    PANELS=$(xfconf-query -c xfce4-panel -l | grep '/panels/panel-[0-9]\+$')
    for PANEL in $PANELS; do
        if [[ "$MODE" == "dark" ]]; then
            xfconf-query -c xfce4-panel -p "$PANEL/background-alpha" -s 1
            xfconf-query -c xfce4-panel -p "$PANEL/background-rgba" -s "0,0,0,0.8"
        else
            xfconf-query -c xfce4-panel -p "$PANEL/background-alpha" -s 1
            xfconf-query -c xfce4-panel -p "$PANEL/background-rgba" -s "1,1,1,0.8"
        fi
    done
    xfce4-panel -r
}

CURRENT_GTK=$(xfconf-query -c xsettings -p /Net/ThemeName)
CURRENT_GTK=${CURRENT_GTK//\'/}
NEW_THEME="${THEME_MAP[$CURRENT_GTK]}"

if [[ "$NEW_THEME" == *,* ]]; then
    IFS=',' read -ra OPTIONS <<< "$NEW_THEME"
    if [[ $FORCE_CHOOSE -eq 0 && -n "${PREF_MAP[$CURRENT_GTK]}" ]]; then
        NEW_THEME="${PREF_MAP[$CURRENT_GTK]}"
    else
        select OPT in "${OPTIONS[@]}"; do
            [[ -n "$OPT" ]] && { NEW_THEME="$OPT"; break; }
        done
        echo "$CURRENT_GTK=$NEW_THEME" >> "$CONFIG_DIR/switch-preferred"
    fi
fi

[[ -n "$NEW_THEME" ]] && xfconf-query -c xsettings -p /Net/ThemeName -s "$NEW_THEME"
if [ -d "/usr/share/themes/$NEW_THEME/xfwm4" ] || [ -d "$HOME/.themes/$NEW_THEME/xfwm4" ]; then
    xfconf-query -c xfwm4 -p /general/theme -s "$NEW_THEME"
fi

[[ $SWITCH_PANEL -eq 1 ]] && ([[ "$NEW_THEME" =~ [Dd]ark ]] && set_panel_style "dark" || set_panel_style "light")
EOF

chmod +x "$INSTALL_DIR/switch.sh"

# -----------------------------
# Wrapper script
# -----------------------------
cat > "$INSTALL_DIR/switch-wrapper.sh" << 'EOF'
#!/bin/bash
# Switch Wrapper - XFCE Theme Toggle Tool
# Version: 1.1.0
# Author: Prabin Thapa <praabinn@protonmail.com> https://github.com/nixpt
# License: MIT

INSTALL_DIR="$HOME/.local/share/switch"
MAIN_SCRIPT="$INSTALL_DIR/switch.sh"
ICON="$INSTALL_DIR/switch-icon.png"

# Run main toggle
"$MAIN_SCRIPT" "$@"

# Update icon instantly
CURRENT_THEME=$(xfconf-query -c xsettings -p /Net/ThemeName)
if [[ "$CURRENT_THEME" =~ [Dd]ark ]]; then
    cp -f "$INSTALL_DIR/switch-dark.png" "$ICON"
else
    cp -f "$INSTALL_DIR/switch-light.png" "$ICON"
fi

xfce4-panel -r >/dev/null 2>&1
EOF

chmod +x "$INSTALL_DIR/switch-wrapper.sh"

# -----------------------------
# Generate dynamic icons with magick
# -----------------------------
ICON_LIGHT="$INSTALL_DIR/switch-light.png"
ICON_DARK="$INSTALL_DIR/switch-dark.png"

if command -v magick >/dev/null 2>&1; then
    magick -size 128x128 xc:none \
        -fill yellow -stroke orange -strokewidth 2 \
        -draw "circle 64,64 64,20" \
        -draw "line 64,0 64,16" \
        -draw "line 64,128 64,112" \
        -draw "line 0,64 16,64" \
        -draw "line 128,64 112,64" \
        -draw "line 20,20 36,36" \
        -draw "line 108,108 124,124" \
        -draw "line 108,20 124,36" \
        -draw "line 20,108 36,124" \
        "$ICON_LIGHT"

    magick -size 128x128 xc:none \
        -fill gray -stroke black -strokewidth 2 \
        -draw "circle 64,64 64,20" \
        -fill none -stroke black -strokewidth 2 \
        -draw "circle 74,64 74,20" \
        "$ICON_DARK"
else
    touch "$ICON_LIGHT" "$ICON_DARK"
fi

# -----------------------------
# Config files
# -----------------------------
touch "$CONFIG_DIR/switch-map"
touch "$CONFIG_DIR/switch-preferred"

# -----------------------------
# Desktop entry
# -----------------------------
DESKTOP_FILE="$APPLICATIONS_DIR/switch.desktop"
cat > "$DESKTOP_FILE" << EOF
[Desktop Entry]
Name=Switch
Comment=Toggle GTK/XFWM themes and panel appearance
Comment[en_US]=Author: Prabin Thapa https://github.com/nixpt
Exec=$INSTALL_DIR/switch-wrapper.sh
Icon=$INSTALL_DIR/switch-icon.png
Terminal=false
Type=Application
Categories=Utility;Settings;Theme;
StartupNotify=true
Version=1.1
EOF

# -----------------------------
# Symlink for CLI
# -----------------------------
ln -sf "$INSTALL_DIR/switch-wrapper.sh" "$BIN_DIR/switch"

# -----------------------------
# Finish
# -----------------------------
echo "----------------------------------------"
echo "Switch installation complete!"
echo "Scripts: $INSTALL_DIR"
echo "Config: $CONFIG_DIR"
echo "Desktop Entry: $DESKTOP_FILE"
echo "License: $INSTALL_DIR/LICENSE"
echo ""
echo "Use the panel launcher or run:"
echo "$INSTALL_DIR/switch-wrapper.sh"
echo "Or via CLI: switch"
echo "----------------------------------------"
