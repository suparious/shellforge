#!/usr/bin/env bash
#
# test-list-fixes.sh - Test the fixed list command
#

set -euo pipefail

# Colors
readonly GREEN='\033[0;32m'
readonly RED='\033[0;31m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

echo -e "${BLUE}Testing List Command Fixes${NC}"
echo "=========================="

# First, ensure scripts are executable
chmod +x scripts/*.sh 2>/dev/null || true

# Build the latest version
echo -e "\n${YELLOW}Building ShellForge...${NC}"
./build/build.sh release

echo -e "\n${GREEN}Build complete!${NC}"
echo -e "\nNow you can test the following:"
echo -e "\n1. ${BLUE}Run the migration script:${NC}"
echo -e "   ./scripts/migrate-backups.sh"
echo -e "\n2. ${BLUE}Test the list command:${NC}"
echo -e "   ./shellforge list"
echo -e "\n3. ${BLUE}Test verbose mode:${NC}"
echo -e "   ./shellforge list --verbose"
echo -e "\n4. ${BLUE}Create a new backup:${NC}"
echo -e "   ./shellforge save"
echo -e "\n5. ${BLUE}List again to see the new backup:${NC}"
echo -e "   ./shellforge list"

echo -e "\n${YELLOW}Key fixes applied:${NC}"
echo -e "- Fixed escape sequence handling in print_box"
echo -e "- Made list function more robust with error handling"
echo -e "- Improved format_bytes and format_timestamp functions"
echo -e "- Better handling of directories with spaces"
echo -e "- Migration script now properly detects ShellForge backups"
