#!/bin/bash
# Simple direct test of help command

# Don't use strict mode for this test
set +e

# Get to project root
cd "$(dirname "${BASH_SOURCE[0]}")/.."

echo "=== Direct Help Command Test ==="

# First, let's make sure shellforge exists and is executable
if [[ ! -f shellforge ]]; then
    echo "Building shellforge..."
    ./build/build.sh > /dev/null 2>&1
fi

if [[ ! -x shellforge ]]; then
    echo "Making shellforge executable..."
    chmod +x shellforge
fi

# Now test the help command directly
echo -e "\nRunning: ./shellforge help"
echo "----------------------------------------"
./shellforge help
HELP_EXIT_CODE=$?
echo "----------------------------------------"
echo "Exit code: $HELP_EXIT_CODE"

# Now test exactly like the test.sh does it
echo -e "\nTesting like test.sh does:"
if ./shellforge help &> /dev/null; then
    echo "✓ Help command works (exit code 0)"
else
    EXIT_CODE=$?
    echo "✗ Help command failed (exit code $EXIT_CODE)"
    
    # Let's see what's happening
    echo -e "\nRunning again to see stderr:"
    ./shellforge help 2>&1 | head -20
fi

echo -e "\nDone."
