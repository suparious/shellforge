#!/bin/bash
# Quick test of the build script fix

echo "Testing build script..."

# Test 1: No arguments (should default to release)
echo -e "\n1. Testing default build (no args):"
bash build/build.sh > /dev/null 2>&1 && echo "✓ Success" || echo "✗ Failed"

# Test 2: Release build
echo -e "\n2. Testing release build:"
bash build/build.sh release > /dev/null 2>&1 && echo "✓ Success" || echo "✗ Failed"

# Test 3: Debug build
echo -e "\n3. Testing debug build:"
bash build/build.sh debug > /dev/null 2>&1 && echo "✓ Success" || echo "✗ Failed"

# Test 4: Clean
echo -e "\n4. Testing clean:"
bash build/build.sh clean > /dev/null 2>&1 && echo "✓ Success" || echo "✗ Failed"

# Test 5: Help
echo -e "\n5. Testing help:"
bash build/build.sh help > /dev/null 2>&1 && echo "✓ Success" || echo "✗ Failed"

echo -e "\nAll tests completed!"
