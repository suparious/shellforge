#!/usr/bin/env bash
# Launch xterm with Sixel support enabled
# This is a helper script for ShellForge users

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}ShellForge XTerm Launcher${NC}"
echo -e "${BLUE}========================${NC}"
echo ""

# Check if xterm is installed
if ! command -v xterm &>/dev/null; then
    echo -e "${YELLOW}Error: xterm is not installed${NC}"
    echo "Install it with:"
    echo "  Ubuntu/Debian: sudo apt-get install xterm"
    echo "  Fedora: sudo dnf install xterm"
    echo "  Arch: sudo pacman -S xterm"
    exit 1
fi

# Default shell to use
SHELL_CMD="${SHELL:-/bin/bash}"

# Check for ShellForge in current directory or parent
if [[ -f "./shellforge" ]]; then
    SHELLFORGE_PATH="$(pwd)/shellforge"
elif [[ -f "../shellforge" ]]; then
    SHELLFORGE_PATH="$(dirname "$(pwd)")/shellforge"
else
    SHELLFORGE_PATH=""
fi

echo -e "${GREEN}Launching xterm with Sixel support...${NC}"
echo ""
echo "Options used:"
echo "  -ti vt340    : Enable Sixel graphics support"
echo "  -fg white    : White foreground"
echo "  -bg black    : Black background"
echo "  -fa 'Monospace' : Use monospace font"
echo "  -fs 12       : Font size 12"
echo ""

# Prepare command to run in xterm
if [[ -n "$SHELLFORGE_PATH" ]]; then
    # Create a temporary script that will run in xterm
    TEMP_SCRIPT=$(mktemp "${TMPDIR:-/tmp}/xterm_sixel_XXXXXX.sh")
    cat > "$TEMP_SCRIPT" << EOF
#!/bin/bash
echo -e "\033[0;32mWelcome to xterm with Sixel support!\033[0m"
echo ""
echo "Testing Sixel capability..."
"$SHELLFORGE_PATH" help | head -n 20
echo ""
echo -e "\033[0;34mYou can now use ShellForge with image support!\033[0m"
echo ""
exec $SHELL_CMD
EOF
    chmod +x "$TEMP_SCRIPT"
    
    # Launch xterm with the script
    xterm -ti vt340 -fg white -bg black -fa 'Monospace' -fs 12 -geometry 100x40 -e "$TEMP_SCRIPT"
    
    # Clean up
    rm -f "$TEMP_SCRIPT"
else
    # Just launch xterm with a shell
    echo -e "${YELLOW}Note: ShellForge not found in current or parent directory${NC}"
    echo "Launching plain xterm with Sixel support..."
    xterm -ti vt340 -fg white -bg black -fa 'Monospace' -fs 12 -geometry 100x40 -e "$SHELL_CMD"
fi
