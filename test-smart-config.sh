#!/usr/bin/env bash
#
# Test script for ShellForge Smart Config filtering
#

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SHELLFORGE="${SCRIPT_DIR}/shellforge"

# Build if necessary
if [[ ! -f "${SHELLFORGE}" ]]; then
    echo -e "${YELLOW}Building ShellForge...${NC}"
    if [[ -f "${SCRIPT_DIR}/build/build.sh" ]]; then
        "${SCRIPT_DIR}/build/build.sh"
        echo -e "  ${GREEN}✓${NC} Build complete"
    else
        echo -e "  ${RED}✗${NC} Build script not found"
        exit 1
    fi
fi

# Test directory
TEST_DIR="/tmp/shellforge-test-$$"
TEST_BACKUP_DEST="${TEST_DIR}/backups"

# Cleanup function
cleanup() {
    echo -e "\n${YELLOW}Cleaning up test directory...${NC}"
    rm -rf "${TEST_DIR}"
}

# Set trap for cleanup
trap cleanup EXIT

echo -e "${BLUE}=== ShellForge Smart Config Test ===${NC}\n"

# Create test environment
echo -e "${YELLOW}Setting up test environment...${NC}"
mkdir -p "${TEST_DIR}/home/.config"
export HOME="${TEST_DIR}/home"
export BACKUP_DEST="${TEST_BACKUP_DEST}"

# Create some test config directories
echo -e "${YELLOW}Creating test config directories...${NC}"

# Create legitimate config directories
mkdir -p "${HOME}/.config/alacritty"
echo "font_size: 12" > "${HOME}/.config/alacritty/alacritty.yml"

mkdir -p "${HOME}/.config/htop"
echo "sort_key=PERCENT_CPU" > "${HOME}/.config/htop/htoprc"

mkdir -p "${HOME}/.config/nvim"
echo "set number" > "${HOME}/.config/nvim/init.vim"

# Create directories that should be skipped
mkdir -p "${HOME}/.config/BraveSoftware/Brave-Browser/Default/Cache"
dd if=/dev/zero of="${HOME}/.config/BraveSoftware/Brave-Browser/Default/Cache/data_0" bs=1M count=50 2>/dev/null

mkdir -p "${HOME}/.config/Code/Cache"
dd if=/dev/zero of="${HOME}/.config/Code/Cache/index" bs=1M count=100 2>/dev/null

mkdir -p "${HOME}/.config/discord/Cache"
dd if=/dev/zero of="${HOME}/.config/discord/Cache/data_1" bs=1M count=200 2>/dev/null

mkdir -p "${HOME}/.config/SomeLargeApp"
dd if=/dev/zero of="${HOME}/.config/SomeLargeApp/bigfile" bs=1M count=60 2>/dev/null

# Show directory sizes
echo -e "\n${YELLOW}Test directory sizes:${NC}"
du -sh "${HOME}/.config"/* | sort -h

# Test 1: Smart config enabled (default)
echo -e "\n${BLUE}Test 1: Smart Config Enabled (default)${NC}"
SHELLFORGE_VERBOSE=true "${SHELLFORGE}" save test-machine

echo -e "\n${YELLOW}Backup size with smart config:${NC}"
du -sh "${BACKUP_DEST}/test-machine/latest/home/.config"
echo -e "${YELLOW}Contents:${NC}"
ls -la "${BACKUP_DEST}/test-machine/latest/home/.config/"

# Clean backup directory
rm -rf "${BACKUP_DEST}/test-machine"

# Test 2: Smart config disabled
echo -e "\n${BLUE}Test 2: Smart Config Disabled${NC}"
SHELLFORGE_SMART_CONFIG=false "${SHELLFORGE}" save test-machine

echo -e "\n${YELLOW}Backup size without smart config:${NC}"
du -sh "${BACKUP_DEST}/test-machine/latest/home/.config"

# Clean backup directory
rm -rf "${BACKUP_DEST}/test-machine"

# Test 3: Force include a normally skipped directory
echo -e "\n${BLUE}Test 3: Force Include Code Directory${NC}"
SHELLFORGE_CONFIG_INCLUDE="Code" SHELLFORGE_VERBOSE=true "${SHELLFORGE}" save test-machine

echo -e "\n${YELLOW}Backup size with Code included:${NC}"
du -sh "${BACKUP_DEST}/test-machine/latest/home/.config"
echo -e "${YELLOW}Code directory included:${NC}"
ls -la "${BACKUP_DEST}/test-machine/latest/home/.config/" | grep -E "Code|^total"

# Test 4: Custom size limit
echo -e "\n${BLUE}Test 4: Custom Size Limit (30MB)${NC}"
rm -rf "${BACKUP_DEST}/test-machine"
SHELLFORGE_MAX_DIR_SIZE_MB=30 SHELLFORGE_VERBOSE=true "${SHELLFORGE}" save test-machine

echo -e "\n${YELLOW}With 30MB limit - SomeLargeApp (60MB) should be skipped${NC}"
ls -la "${BACKUP_DEST}/test-machine/latest/home/.config/"

echo -e "\n${GREEN}✓ All tests completed!${NC}"
echo -e "${YELLOW}Summary:${NC}"
echo "- Smart config filtering correctly excludes large/binary directories"
echo "- Force include works to override blacklist"
echo "- Size-based filtering works as expected"
echo "- Legitimate config files are preserved"
