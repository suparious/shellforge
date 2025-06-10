#!/bin/bash
# Test script to verify color codes are properly interpreted

echo "Testing printf %s vs %b with color codes..."
echo ""

# Define colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# Test string with color codes
test_string="not set ${BLUE}[default: 50]${NC}"

echo "Using printf with %s (broken):"
printf "Status: %s\n" "$test_string"

echo ""
echo "Using printf with %b (fixed):"
printf "Status: %b\n" "$test_string"

echo ""
echo "This demonstrates the fix for the color code display issue."
