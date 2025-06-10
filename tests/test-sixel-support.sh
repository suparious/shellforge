#!/usr/bin/env bash
# Test Sixel support in ShellForge
# This is now a wrapper for the full image rendering test

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Running ShellForge image rendering test..."
echo "This includes Sixel support testing."
echo ""

# Run the full image rendering test
exec "${SCRIPT_DIR}/test-image-rendering.sh" "$@"
