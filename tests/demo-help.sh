#!/bin/bash
# Demo script to show the elaborate help output

# Get to the project root where shellforge is located
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.."; pwd)"
SHELLFORGE="${PROJECT_ROOT}/shellforge"

echo "=== ShellForge Dynamic Help Demo ==="
echo ""
echo "Let's see the help output with different environment configurations..."
echo ""

# Test 1: No environment variables set
echo -e "\033[1;33m1. No environment variables set:\033[0m"
echo "----------------------------------------"
unset BACKUP_DEST
unset SHELLFORGE_SMART_CONFIG
unset SHELLFORGE_MAX_DIR_SIZE_MB
"${SHELLFORGE}" help | head -n 45

echo ""
echo -e "\033[1;33m2. With BACKUP_DEST set to a non-existent directory:\033[0m"
echo "----------------------------------------"
export BACKUP_DEST="/tmp/test-backup"
"${SHELLFORGE}" help | grep -A 20 "Environment Variables:" | head -n 20

echo ""
echo -e "\033[1;33m3. With BACKUP_DEST set to an existing directory:\033[0m"
echo "----------------------------------------"
mkdir -p /tmp/shellforge-demo
export BACKUP_DEST="/tmp/shellforge-demo"
export SHELLFORGE_SMART_CONFIG="false"
export SHELLFORGE_MAX_DIR_SIZE_MB="100"
"${SHELLFORGE}" help | grep -A 20 "Environment Variables:" | head -n 20

echo ""
echo -e "\033[1;33m4. Fully configured:\033[0m"
echo "----------------------------------------"
export SHELLFORGE_SMART_CONFIG="true"
export SHELLFORGE_CONFIG_INCLUDE="Code,discord"
export SHELLFORGE_VERBOSE="true"
"${SHELLFORGE}" help | grep -A 25 "Environment Variables:" | head -n 25

# Clean up
rm -rf /tmp/shellforge-demo
