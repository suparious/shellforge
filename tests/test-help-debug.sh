#!/bin/bash
# Debug test for help command issue

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

echo -e "${BLUE}=== ShellForge Help Command Debug Test ===${NC}\n"

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

# Test 1: Run help command and capture output and exit code
echo -e "${YELLOW}Test 1: Running help command with output...${NC}"
echo "Command: ${SHELLFORGE} help"
echo "----------------------------------------"
set +e  # Temporarily disable exit on error
"${SHELLFORGE}" help
exit_code=$?
set -e

echo "----------------------------------------"
echo "Exit code: $exit_code"

if [[ $exit_code -eq 0 ]]; then
    echo -e "${GREEN}✓ Help command succeeded${NC}"
else
    echo -e "${RED}✗ Help command failed with exit code $exit_code${NC}"
fi

# Test 2: Run help command with stderr captured
echo -e "\n${YELLOW}Test 2: Running help command with stderr captured...${NC}"
echo "----------------------------------------"
set +e
stderr_output=$("${SHELLFORGE}" help 2>&1 1>/dev/null)
exit_code=$?
set -e

if [[ -n "$stderr_output" ]]; then
    echo "Stderr output:"
    echo "$stderr_output"
else
    echo "No stderr output"
fi
echo "Exit code: $exit_code"

# Test 3: Test with BACKUP_DEST set
echo -e "\n${YELLOW}Test 3: Running help with BACKUP_DEST set...${NC}"
export BACKUP_DEST="/tmp/test-backup"
echo "BACKUP_DEST=$BACKUP_DEST"
echo "----------------------------------------"
set +e
"${SHELLFORGE}" help > /dev/null 2>&1
exit_code=$?
set -e

if [[ $exit_code -eq 0 ]]; then
    echo -e "${GREEN}✓ Help command succeeded with BACKUP_DEST set${NC}"
else
    echo -e "${RED}✗ Help command failed with exit code $exit_code${NC}"
fi

# Test 4: Check if it's related to pipefail
echo -e "\n${YELLOW}Test 4: Testing without pipefail...${NC}"
set +o pipefail
set +e
"${SHELLFORGE}" help &> /dev/null
exit_code=$?
set -e
set -o pipefail

if [[ $exit_code -eq 0 ]]; then
    echo -e "${GREEN}✓ Help command succeeded without pipefail${NC}"
else
    echo -e "${RED}✗ Help command still failed with exit code $exit_code${NC}"
fi

# Test 5: Run with bash -x to trace execution
echo -e "\n${YELLOW}Test 5: Running with trace (last 20 lines)...${NC}"
echo "----------------------------------------"
set +e
bash -x "${SHELLFORGE}" help 2>&1 | tail -20
set -e
echo "----------------------------------------"

echo -e "\n${BLUE}Debug test complete${NC}"
