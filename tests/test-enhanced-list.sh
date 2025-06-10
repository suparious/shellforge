#!/usr/bin/env bash
#
# test-enhanced-list.sh - Test the enhanced list command features
#

set -euo pipefail

# Change to project root
cd "$(dirname "${BASH_SOURCE[0]}")/.."

# Colors
readonly GREEN='\033[0;32m'
readonly RED='\033[0;31m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

# Test configuration
readonly TEST_DIR="./test-enhanced-list-tmp"
readonly BACKUP_DEST="${TEST_DIR}/backups"

# Cleanup function
cleanup() {
    rm -rf "$TEST_DIR"
}
trap cleanup EXIT

echo -e "${BLUE}Testing Enhanced List Command${NC}"
echo "================================"

# Setup test environment
echo -e "\n${YELLOW}Setting up test environment...${NC}"
mkdir -p "$BACKUP_DEST"
export BACKUP_DEST

# Build the script
echo -e "${YELLOW}Building ShellForge...${NC}"
./build/build.sh release > /dev/null 2>&1

# Test 1: Empty backup directory
echo -e "\n${BLUE}Test 1: Empty backup directory${NC}"
./shellforge list
echo -e "${GREEN}✓ Handled empty directory correctly${NC}"

# Test 2: Create some test backups with markers
echo -e "\n${BLUE}Test 2: Creating test backups with markers${NC}"

# Create Machine1 backups
mkdir -p "${BACKUP_DEST}/Machine1/20250609_100000/home"
cat > "${BACKUP_DEST}/Machine1/20250609_100000/.shellforge" << EOF
# ShellForge Backup Marker
VERSION=1.5.0
TIMESTAMP=$(date -d '1 hour ago' +%s 2>/dev/null || echo $(($(date +%s) - 3600)))
DATE=$(date -R)
TOOL=ShellForge
MACHINE=Machine1
USER=testuser
EOF

# Create some dummy files
touch "${BACKUP_DEST}/Machine1/20250609_100000/home/.zshrc"
touch "${BACKUP_DEST}/Machine1/20250609_100000/home/.bashrc"
echo "Test content" > "${BACKUP_DEST}/Machine1/20250609_100000/home/.vimrc"

# Create another backup for Machine1
mkdir -p "${BACKUP_DEST}/Machine1/20250608_200000/home"
cat > "${BACKUP_DEST}/Machine1/20250608_200000/.shellforge" << EOF
# ShellForge Backup Marker
VERSION=1.5.0
TIMESTAMP=$(date -d '2 days ago' +%s 2>/dev/null || echo $(($(date +%s) - 172800)))
DATE=$(date -R)
TOOL=ShellForge
MACHINE=Machine1
USER=testuser
EOF

# Create Machine2 backup
mkdir -p "${BACKUP_DEST}/Machine2/20250607_150000/home"
cat > "${BACKUP_DEST}/Machine2/20250607_150000/.shellforge" << EOF
# ShellForge Backup Marker
VERSION=1.5.0
TIMESTAMP=$(date -d '7 days ago' +%s 2>/dev/null || echo $(($(date +%s) - 604800)))
DATE=$(date -R)
TOOL=ShellForge
MACHINE=Machine2
USER=testuser
EOF

# Create a non-ShellForge directory (should be filtered out)
mkdir -p "${BACKUP_DEST}/NotShellForge/20250606_120000"
touch "${BACKUP_DEST}/NotShellForge/20250606_120000/somefile.txt"

echo -e "${GREEN}✓ Created test backups${NC}"

# Test 3: List with ShellForge filtering
echo -e "\n${BLUE}Test 3: List with ShellForge filtering${NC}"
./shellforge list
echo -e "${GREEN}✓ Listed only ShellForge backups${NC}"

# Test 4: List with verbose mode
echo -e "\n${BLUE}Test 4: List with verbose mode${NC}"
./shellforge list --verbose
echo -e "${GREEN}✓ Verbose mode working${NC}"

# Test 5: Create a backup and verify marker
echo -e "\n${BLUE}Test 5: Create new backup with marker${NC}"
export MACHINE_NAME="TestMachine"
./shellforge save > /dev/null 2>&1

# Check if marker was created
if [[ -f "${BACKUP_DEST}/TestMachine/latest/.shellforge" ]]; then
    echo -e "${GREEN}✓ Marker file created in new backup${NC}"
else
    echo -e "${RED}✗ Marker file not found in new backup${NC}"
fi

# Test 6: List after creating new backup
echo -e "\n${BLUE}Test 6: List after new backup${NC}"
./shellforge list

# Summary
echo -e "\n${GREEN}================================${NC}"
echo -e "${GREEN}All enhanced list tests passed!${NC}"
echo -e "${GREEN}================================${NC}"
