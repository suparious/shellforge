#!/bin/bash
# Test help command in isolated environment

echo "=== Testing help command in clean environment ==="

# Get to project root
cd "$(dirname "${BASH_SOURCE[0]}")/.."

# Build if needed
if [[ ! -f shellforge ]]; then
    echo "Building shellforge..."
    ./build/build.sh release > /dev/null 2>&1
fi

echo -e "\n1. Testing with current environment:"
./shellforge help &> /dev/null && echo "✓ Success" || echo "✗ Failed (exit code: $?)"

echo -e "\n2. Testing with clean environment:"
env -i bash -c './shellforge help &> /dev/null' && echo "✓ Success" || echo "✗ Failed (exit code: $?)"

echo -e "\n3. Testing with minimal environment:"
env -i HOME="$HOME" USER="$USER" bash -c './shellforge help &> /dev/null' && echo "✓ Success" || echo "✗ Failed (exit code: $?)"

echo -e "\n4. Testing without strict mode:"
bash -c './shellforge help &> /dev/null' && echo "✓ Success" || echo "✗ Failed (exit code: $?)"

echo -e "\n5. Testing with explicit exit handling:"
bash -c '
    ./shellforge help &> /dev/null
    exit $?
' && echo "✓ Success" || echo "✗ Failed (exit code: $?)"

echo -e "\n6. Let's see what the actual error is:"
echo "Running: ./shellforge help 2>&1 | tail -20"
echo "----------------------------------------"
./shellforge help 2>&1 | tail -20
echo "----------------------------------------"

echo -e "\n7. Check if it's the main function not returning properly:"
bash -x ./shellforge help 2>&1 | grep -E "(exit|main)" | tail -10

echo -e "\nDone."
