#!/usr/bin/env bash
# Test script for macOS compatibility

set -euo pipefail

echo "Testing ShellForge UI library on macOS..."
echo "Bash version: ${BASH_VERSION}"

# Source the UI library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../src/lib/ui-common.sh"

echo ""
echo "Testing basic functions:"
print_status "success" "Success message"
print_status "error" "Error message" 
print_status "warning" "Warning message"
print_status "info" "Info message"

echo ""
echo "Testing status icons:"
echo "Success icon: ${STATUS_ICONS[success]}"
echo "Error icon: ${STATUS_ICONS[error]}"
echo "Fire icon: ${STATUS_ICONS[fire]}"
echo "Rocket icon: ${STATUS_ICONS[rocket]}"

echo ""
print_section "Test Complete" "$GREEN" 40

echo "If you see this message, the UI library is working correctly on macOS!"
