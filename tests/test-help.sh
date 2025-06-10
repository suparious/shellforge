#!/bin/bash
# Comprehensive help command test

echo "=== ShellForge Help Command Test ==="

# Get to project root
cd "$(dirname "${BASH_SOURCE[0]}")/.."

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Ensure shellforge is built
if [[ ! -f shellforge ]]; then
    echo "Building shellforge..."
    ./build/build.sh > /dev/null 2>&1
fi

echo -e "\n${BLUE}Running comprehensive help command tests...${NC}"

# Test 1: Basic help command
echo -e "\n${YELLOW}Test 1: Basic help command${NC}"
./shellforge help &> /dev/null
exit_code=$?
if [[ $exit_code -eq 0 ]]; then
    echo -e "${GREEN}✓ Success${NC}"
else
    echo -e "${RED}✗ Failed with exit code: $exit_code${NC}"
fi

# Test 2: Help command with output visible
echo -e "\n${YELLOW}Test 2: Help output (first 20 lines)${NC}"
./shellforge help 2>&1 | head -20

# Test 3: Check specific environment variables that might cause issues
echo -e "\n${YELLOW}Test 3: Environment check${NC}"
echo "SHELL=${SHELL:-not set}"
echo "USER=${USER:-not set}"
echo "HOME=${HOME:-not set}"
echo "BACKUP_DEST=${BACKUP_DEST:-not set}"

# Test 4: Run in clean environment
echo -e "\n${YELLOW}Test 4: Clean environment test${NC}"
env -i HOME="$HOME" bash -c './shellforge help &> /dev/null' && echo -e "${GREEN}✓ Success${NC}" || echo -e "${RED}✗ Failed${NC}"

# Test 5: Check for any error output
echo -e "\n${YELLOW}Test 5: Checking for errors${NC}"
error_output=$(./shellforge help 2>&1 1>/dev/null)
if [[ -z "$error_output" ]]; then
    echo -e "${GREEN}✓ No errors on stderr${NC}"
else
    echo -e "${RED}✗ Errors found:${NC}"
    echo "$error_output"
fi

echo -e "\n${BLUE}Test complete.${NC}"
