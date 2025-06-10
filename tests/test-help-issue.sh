#!/bin/bash
# Fixed test script for help command

set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "${SCRIPT_DIR}")"
SHELLFORGE="${PROJECT_ROOT}/shellforge"

echo "=== Testing help command issue ==="

# Build if needed
if [[ ! -f "${SHELLFORGE}" ]]; then
    echo "Building..."
    "${PROJECT_ROOT}/build/build.sh" > /dev/null 2>&1
fi

# The key issue: we need to handle the exit code properly
echo -e "\nTest: Help command with proper error handling"

# Method 1: Using || true to prevent script exit
echo -n "Method 1 (with || true): "
if "${SHELLFORGE}" help &> /dev/null || true; then
    echo "Success"
else
    echo "Failed"
fi

# Method 2: Capturing exit code explicitly
echo -n "Method 2 (explicit capture): "
set +e
"${SHELLFORGE}" help &> /dev/null
help_exit_code=$?
set -e

if [[ $help_exit_code -eq 0 ]]; then
    echo "Success (exit code: $help_exit_code)"
else
    echo "Failed (exit code: $help_exit_code)"
fi

# Method 3: The issue might be with the 'exit 0' in main.sh not being reached
echo -e "\nDebugging: Let's see the last line executed"
bash -x "${SHELLFORGE}" help 2>&1 | tail -5

# Method 4: Check if it's the usage function itself
echo -e "\nChecking if usage function completes:"
set +e
bash -c "
    source '${PROJECT_ROOT}/src/core/variables.sh'
    source '${PROJECT_ROOT}/src/core/display.sh'
    usage
"
usage_exit_code=$?
set -e
echo "Usage function exit code: $usage_exit_code"
