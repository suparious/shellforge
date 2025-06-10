#!/bin/bash
# Minimal test to isolate help command issue

set -euo pipefail

# Get to project root
cd "$(dirname "${BASH_SOURCE[0]}")/.."

# Build if needed
if [[ ! -f shellforge ]]; then
    echo "Building shellforge..."
    make clean && make > /dev/null 2>&1
fi

echo "=== Testing help command in different ways ==="

# Test 1: Direct execution
echo -e "\n1. Direct execution:"
./shellforge help > /dev/null 2>&1
echo "Exit code: $?"

# Test 2: With capturing output (like the test does)
echo -e "\n2. With output capture:"
if ./shellforge help &> /dev/null; then
    echo "Success (exit code 0)"
else
    echo "Failed (exit code $?)"
fi

# Test 3: Let's see what's actually happening
echo -e "\n3. With visible output:"
./shellforge help 2>&1 | head -20

# Test 4: Check if it's the exit status
echo -e "\n4. Checking exit status explicitly:"
set +e
./shellforge help > /dev/null 2>&1
exit_code=$?
set -e
echo "Exit code: $exit_code"

# Test 5: Run with bash -x to see what's happening
echo -e "\n5. Last few lines with trace:"
bash -x ./shellforge help 2>&1 | tail -10
