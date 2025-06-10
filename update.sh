#!/bin/bash
# Quick update/reinstall script for ShellForge

set -euo pipefail

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SHELLFORGE="${SCRIPT_DIR}/shellforge"

echo -e "${BLUE}=== ShellForge Update Script ===${NC}\n"

# Build the latest version
echo -e "${YELLOW}Building latest version...${NC}"
if [[ -f "${SCRIPT_DIR}/build/build.sh" ]]; then
    "${SCRIPT_DIR}/build/build.sh"
    echo -e "${GREEN}✓${NC} Build complete"
else
    echo -e "${RED}✗${NC} Build script not found"
    exit 1
fi

# Install to user's bin directory
echo -e "${YELLOW}Installing to ~/bin...${NC}"
mkdir -p "${HOME}/bin"
cp "${SHELLFORGE}" "${HOME}/bin/shellforge"
chmod +x "${HOME}/bin/shellforge"

echo -e "${GREEN}✓${NC} ShellForge has been updated!"
echo ""
echo "Version information:"
"${HOME}/bin/shellforge" version || echo "  (version command not available)"
echo ""
echo "Try running: shellforge help"
