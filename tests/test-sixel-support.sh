#!/usr/bin/env bash
# Display an image using Sixel (if available), or ASCII fallback

set -euo pipefail

IMAGE_PATH="${1:-./image.png}"

# Optional tools
IMG2SIXEL="$(command -v img2sixel || true)"
CHAFACMD="$(command -v chafa || true)"
JP2ACMD="$(command -v jp2a || true)"

# Check Sixel support
detect_sixel_support() {
    if [[ -z "$IMG2SIXEL" ]]; then
        return 1
    fi

    local tmpimg
    #tmpimg="$(mktemp --suffix=.png)"
    tmpimg="${HOME}/Backups/shellforge/test_image.jpg"
    #printf '\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDR\x00\x00\x00\x01\x00\x00\x00\x01\x08\x02\x00\x00\x00\x90wS\xde\x00\x00\x00\nIDATx\x9cc`\x00\x00\x00\x02\x00\x01\xe2!\xbc\x33\x00\x00\x00\x00IEND\xaeB`\x82' > "$tmpimg"

    if "$IMG2SIXEL" "$tmpimg" ; then #>/dev/null 2>&1; then
        #rm -f "$tmpimg"
        return 0
    else
        #rm -f "$tmpimg"
        return 1
    fi
}

# Check if we can render SVG
check_svg_support() {
    if command -v rsvg-convert &>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Display using Sixel
render_sixel() {
    echo "[INFO] Rendering image using Sixel..."
    "$IMG2SIXEL" "$IMAGE_PATH"
}

# Display using ASCII fallback
render_ascii() {
    if [[ -n "$CHAFACMD" ]]; then
        echo "[INFO] Rendering image using chafa (ASCII fallback)..."
        "$CHAFACMD" "$IMAGE_PATH"
    elif [[ -n "$JP2ACMD" ]]; then
        echo "[INFO] Rendering image using jp2a (ASCII fallback)..."
        "$JP2ACMD" --width=80 "$IMAGE_PATH"
    else
        echo "[ERROR] No image rendering tools found. Install img2sixel, chafa, or jp2a."
        return 1
    fi
}

# Dispatch logic
main() {
    if [[ ! -f "$IMAGE_PATH" ]]; then
        echo "[ERROR] Image file not found: $IMAGE_PATH"
        exit 1
    fi

    # Convert SVG to PNG
    if [[ "$IMAGE_PATH" == *.svg ]]; then
        if command -v rsvg-convert &>/dev/null; then
            TMPFILE="$(mktemp /tmp/imageXXXXXX.png)"
            rsvg-convert -o "$TMPFILE" "$IMAGE_PATH"
            IMAGE_PATH="$TMPFILE"
        else
            echo "[ERROR] Cannot render SVG: install 'librsvg2-bin'"
            exit 1
        fi
    fi

    if detect_sixel_support; then
        render_sixel
    else
        render_ascii
    fi
}

main
