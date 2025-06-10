#!/bin/bash
# Quick test of the new dynamic help output

# Get to the project root
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.."; pwd)"
SHELLFORGE="${PROJECT_ROOT}/shellforge"

echo "Building ShellForge with the new dynamic help..."
(cd "${PROJECT_ROOT}" && make > /dev/null 2>&1)

echo ""
echo "=== Testing Dynamic Environment Variables Display ==="
echo ""

# Test with no BACKUP_DEST
echo -e "\033[1;31mTest 1: BACKUP_DEST not set\033[0m"
unset BACKUP_DEST
"${SHELLFORGE}" help 2>/dev/null | sed -n '/Environment Variables:/,/Examples:/p' | head -n -2

echo ""
echo -e "\033[1;33mTest 2: BACKUP_DEST set but directory doesn't exist\033[0m"
export BACKUP_DEST="$HOME/MyBackups/shellforge"
"${SHELLFORGE}" help 2>/dev/null | sed -n '/Environment Variables:/,/Examples:/p' | head -n -2

echo ""
echo -e "\033[1;32mTest 3: BACKUP_DEST exists and is writable\033[0m"
export BACKUP_DEST="/tmp/shellforge-test"
mkdir -p "$BACKUP_DEST"
"${SHELLFORGE}" help 2>/dev/null | sed -n '/Environment Variables:/,/Examples:/p' | head -n -2

# Cleanup
rm -rf /tmp/shellforge-test
