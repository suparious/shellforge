#!/bin/bash
# Test script for ShellForge - verifies functionality without modifying system

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "${SCRIPT_DIR}")"
SHELLFORGE="${PROJECT_ROOT}/shellforge"

echo -e "${BLUE}=== ShellForge Test Suite ===${NC}\n"

# Build if necessary
if [[ ! -f "${SHELLFORGE}" ]]; then
    echo -e "${YELLOW}Building ShellForge...${NC}"
    if [[ -f "${PROJECT_ROOT}/build/build.sh" ]]; then
        "${PROJECT_ROOT}/build/build.sh"
        echo -e "  ${GREEN}✓${NC} Build complete"
    else
        echo -e "  ${RED}✗${NC} Build script not found"
        exit 1
    fi
fi

# Test 1: Check if shellforge is executable
echo -e "${YELLOW}Test 1: Checking shellforge script...${NC}"
if [[ -x "${SHELLFORGE}" ]]; then
    echo -e "  ${GREEN}✓${NC} shellforge is executable"
else
    echo -e "  ${RED}✗${NC} shellforge is not executable"
    echo "  Run: chmod +x ${SHELLFORGE}"
    exit 1
fi

# Test 2: Check BACKUP_DEST
echo -e "\n${YELLOW}Test 2: Checking BACKUP_DEST...${NC}"
if [[ -n "${BACKUP_DEST:-}" ]]; then
    echo -e "  ${GREEN}✓${NC} BACKUP_DEST is set to: ${BACKUP_DEST}"
else
    echo -e "  ${RED}✗${NC} BACKUP_DEST is not set"
    echo "  Set it with: export BACKUP_DEST=/path/to/backup"
fi

# Test 3: Check for required commands
echo -e "\n${YELLOW}Test 3: Checking required commands...${NC}"
for cmd in bash cp mkdir ln readlink du; do
    if command -v "$cmd" &> /dev/null; then
        echo -e "  ${GREEN}✓${NC} $cmd found"
    else
        echo -e "  ${RED}✗${NC} $cmd not found"
    fi
done

# Test 4: Check for optional enhancements
echo -e "\n${YELLOW}Test 4: Checking optional enhancements...${NC}"
for cmd in rsync figlet lolcat cowsay; do
    if command -v "$cmd" &> /dev/null; then
        echo -e "  ${GREEN}✓${NC} $cmd found (optional)"
    else
        echo -e "  ${BLUE}ℹ${NC} $cmd not found (optional)"
    fi
done

# Test 5: Test help command
echo -e "\n${YELLOW}Test 5: Testing help command...${NC}"
if "${SHELLFORGE}" help &> /dev/null; then
    echo -e "  ${GREEN}✓${NC} Help command works"
else
    echo -e "  ${RED}✗${NC} Help command failed"
fi

# Test 6: Test version command
echo -e "\n${YELLOW}Test 6: Testing version command...${NC}"
if version_output=$("${SHELLFORGE}" version 2>&1); then
    echo -e "  ${GREEN}✓${NC} Version command works"
    echo -e "  ${version_output}" | sed 's/^/    /'
else
    echo -e "  ${RED}✗${NC} Version command failed"
fi

# Test 7: Check home directory for common dotfiles
echo -e "\n${YELLOW}Test 7: Scanning for dotfiles to backup...${NC}"
found_count=0
for file in .zshrc .bashrc .vimrc .gitconfig .tmux.conf; do
    if [[ -f "${HOME}/${file}" ]]; then
        echo -e "  ${GREEN}✓${NC} Found ${file}"
        ((found_count++))
    fi
done
echo -e "  Total found: ${found_count} dotfiles"

# Test 8: Check for configuration directories
echo -e "\n${YELLOW}Test 8: Scanning for config directories...${NC}"
dir_count=0
for dir in .config .vim .oh-my-zsh .zsh .tmux; do
    if [[ -d "${HOME}/${dir}" ]]; then
        echo -e "  ${GREEN}✓${NC} Found ${dir}/"
        ((dir_count++))
    fi
done
echo -e "  Total found: ${dir_count} directories"

# Summary
echo -e "\n${BLUE}=== Test Summary ===${NC}"
echo -e "ShellForge appears to be properly configured."
echo -e "\nTo perform a real backup test:"
echo -e "  1. Set BACKUP_DEST: ${GREEN}export BACKUP_DEST=/tmp/shellforge-test${NC}"
echo -e "  2. Run save: ${GREEN}${SHELLFORGE} save test-machine${NC}"
echo -e "  3. List backups: ${GREEN}${SHELLFORGE} list${NC}"
echo -e "\nThis will create a test backup in /tmp without affecting your real backup location."
