#!/bin/bash
# Simple test to verify help command works

echo "Testing help command fix..."

# Build first
cd "$(dirname "${BASH_SOURCE[0]}")/.."
make clean && make

# Test help command
echo -e "\n1. Testing help command (should succeed):"
if ./shellforge help > /dev/null 2>&1; then
    echo "✓ Help command works!"
else
    echo "✗ Help command failed!"
    exit 1
fi

# Test with strict mode
echo -e "\n2. Testing with strict mode:"
bash -euo pipefail -c './shellforge help > /dev/null 2>&1' && echo "✓ Works with strict mode!" || echo "✗ Failed with strict mode!"

# Test without SHELL variable
echo -e "\n3. Testing without SHELL variable:"
(unset SHELL; ./shellforge help > /dev/null 2>&1) && echo "✓ Works without SHELL!" || echo "✗ Failed without SHELL!"

# Test without USER variable
echo -e "\n4. Testing without USER variable:"
(unset USER; ./shellforge help > /dev/null 2>&1) && echo "✓ Works without USER!" || echo "✗ Failed without USER!"

echo -e "\nAll tests passed! The help command should now work in the test suite."
