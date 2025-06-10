#!/usr/bin/env bash
# Enhanced Sixel detection test for ShellForge
# This script tests various methods of detecting Sixel support

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

echo -e "${CYAN}=== Enhanced Sixel Detection Test ===${NC}"
echo ""

# 1. Display terminal environment
echo -e "${BOLD}1. Terminal Environment:${NC}"
echo -e "   TERM: ${BLUE}${TERM:-unknown}${NC}"
echo -e "   TERM_PROGRAM: ${BLUE}${TERM_PROGRAM:-not set}${NC}"
echo -e "   VTE_VERSION: ${BLUE}${VTE_VERSION:-not set}${NC}"
echo -e "   XTERM_VERSION: ${BLUE}${XTERM_VERSION:-not set}${NC}"
echo -e "   MLTERM: ${BLUE}${MLTERM:-not set}${NC}"
echo -e "   GNOME_TERMINAL_SERVICE: ${BLUE}${GNOME_TERMINAL_SERVICE:-not set}${NC}"
echo -e "   KONSOLE_VERSION: ${BLUE}${KONSOLE_VERSION:-not set}${NC}"
echo ""

# 2. Test infocmp method
echo -e "${BOLD}2. Testing infocmp method:${NC}"
if command -v infocmp &>/dev/null; then
    if infocmp 2>/dev/null | grep -q "sixel"; then
        echo -e "   ${GREEN}✓ infocmp reports Sixel support${NC}"
    else
        echo -e "   ${YELLOW}✗ infocmp does not report Sixel support${NC}"
    fi
    # Show relevant capabilities
    echo -e "   ${BLUE}Graphics capabilities in terminfo:${NC}"
    infocmp 2>/dev/null | grep -E "(sixel|graph|image)" || echo "   (none found)"
else
    echo -e "   ${RED}✗ infocmp command not found${NC}"
fi
echo ""

# 3. Test Device Attributes (DA1) query
echo -e "${BOLD}3. Testing Device Attributes (DA1) query:${NC}"
echo -e "   ${BLUE}Sending ESC[c query...${NC}"

# Function to test DA1
test_da1() {
    # Save current terminal settings
    local old_settings
    old_settings=$(stty -g 2>/dev/null) || return 1
    
    # Clear any pending input
    read -t 0.1 -n 10000 2>/dev/null || true
    
    # Set terminal to raw mode to capture response
    stty raw -echo min 0 time 0 2>/dev/null || {
        stty "$old_settings" 2>/dev/null
        return 1
    }
    
    # Send DA1 query
    printf '\033[c'
    
    # Small delay to let terminal process
    sleep 0.2
    
    # Try to read response
    local response=""
    local char
    local read_count=0
    
    # Read up to 100 characters or until we see 'c'
    while (( read_count < 100 )); do
        if IFS= read -r -n1 char 2>/dev/null; then
            response+="$char"
            ((read_count++))
            if [[ "$char" == "c" ]]; then
                break
            fi
        else
            # No more data available
            break
        fi
    done
    
    # Restore terminal settings
    stty "$old_settings" 2>/dev/null || true
    
    # Clear any remaining input
    read -t 0.1 -n 10000 2>/dev/null || true
    
    # Return the response
    echo "$response"
}

# Try DA1 query if in a terminal
if [[ -t 1 ]] && [[ -t 0 ]]; then
    DA1_RESPONSE=$(test_da1)
    
    if [[ -n "$DA1_RESPONSE" ]]; then
        # Convert control characters for display
        DISPLAY_RESPONSE="${DA1_RESPONSE//[[:cntrl:]]/<CTRL>}"
        DISPLAY_RESPONSE="${DISPLAY_RESPONSE//$'\033'/<ESC>}"
        echo -e "   Response received: ${MAGENTA}${DISPLAY_RESPONSE}${NC}"
        
        # Check for Sixel support (;4 in the response)
        if [[ "$DA1_RESPONSE" == *";4;"* ]] || [[ "$DA1_RESPONSE" == *";4c"* ]]; then
            echo -e "   ${GREEN}✓ Terminal reports Sixel support (contains ;4)${NC}"
            
            # Parse device attributes
            if [[ "$DA1_RESPONSE" =~ \[\\?([0-9\;]+)c ]]; then
                echo -e "   ${BLUE}Device attributes: ${BASH_REMATCH[1]}${NC}"
            fi
        else
            echo -e "   ${YELLOW}✗ Terminal does not report Sixel support${NC}"
        fi
    else
        echo -e "   ${YELLOW}✗ No response received (terminal may not support DA1)${NC}"
    fi
else
    echo -e "   ${RED}✗ Not running in a terminal${NC}"
fi
echo ""

# 4. Test img2sixel availability and output
echo -e "${BOLD}4. Testing img2sixel:${NC}"
if command -v img2sixel &>/dev/null; then
    IMG2SIXEL_PATH=$(command -v img2sixel)
    echo -e "   ${GREEN}✓ img2sixel found at: $IMG2SIXEL_PATH${NC}"
    
    # Create a tiny test image
    TEST_IMG=$(mktemp "${TMPDIR:-/tmp}/sixel_test_XXXXXX.png")
    # Create 1x1 red pixel PNG
    printf '\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDR\x00\x00\x00\x01\x00\x00\x00\x01\x08\x02\x00\x00\x00\x90wS\xde\x00\x00\x00\x0cIDATx\x9cc\xf8\xcf\xc0\x00\x00\x03\x01\x01\x00\x18\xdd\x8d\xb4\x00\x00\x00\x00IEND\xaeB`\x82' > "$TEST_IMG"
    
    echo -e "   ${BLUE}Testing img2sixel output...${NC}"
    
    # Try to run img2sixel and check output
    if OUTPUT=$("$IMG2SIXEL_PATH" -w 1 -h 1 "$TEST_IMG" 2>&1); then
        EXIT_CODE=$?
        echo -e "   Exit code: ${GREEN}$EXIT_CODE${NC}"
        
        # Check if output looks like Sixel data
        if [[ "$OUTPUT" == $'\033P'* ]] || [[ "$OUTPUT" == $'\x1bP'* ]] || [[ "$OUTPUT" == $'\ePq'* ]]; then
            echo -e "   ${GREEN}✓ img2sixel produced Sixel output${NC}"
            echo -e "   Output starts with: ${MAGENTA}${OUTPUT:0:10}...${NC}"
            
            # Actually try to display it
            echo -e "   ${BLUE}Attempting to display test image:${NC}"
            "$IMG2SIXEL_PATH" -w 8 -h 8 "$TEST_IMG" 2>/dev/null || true
            echo -e "   ${BLUE}(You should see a tiny red square above if Sixel works)${NC}"
        else
            echo -e "   ${YELLOW}✗ img2sixel did not produce Sixel output${NC}"
            echo -e "   Output: ${MAGENTA}${OUTPUT:0:50}...${NC}"
        fi
    else
        EXIT_CODE=$?
        echo -e "   ${RED}✗ img2sixel failed with exit code: $EXIT_CODE${NC}"
    fi
    
    rm -f "$TEST_IMG"
else
    echo -e "   ${RED}✗ img2sixel not found${NC}"
fi
echo ""

# 5. Test raw Sixel sequence
echo -e "${BOLD}5. Testing raw Sixel sequence:${NC}"
echo -e "   ${BLUE}Sending minimal Sixel sequence...${NC}"

# Send a minimal Sixel sequence (single pixel)
printf '\033Pq#0;2;0;0;0#0!1~-\033\\' 2>&1 >/dev/null

echo -e "   ${BLUE}(If your terminal supports Sixel, no error should appear)${NC}"
echo ""

# 6. Summary and recommendations
echo -e "${BOLD}6. Detection Summary:${NC}"

# Determine likely Sixel support based on all tests
LIKELY_SIXEL=false
REASON=""

# First check environment clues
if [[ -n "${GNOME_TERMINAL_SERVICE:-}" ]]; then
    echo -e "   ${YELLOW}Warning: GNOME_TERMINAL_SERVICE detected${NC}"
    echo -e "   ${YELLOW}This suggests you're using GNOME Terminal, which doesn't support Sixel${NC}"
    echo -e "   ${YELLOW}Your TERM=xterm with XTERM_VERSION suggests xterm is installed${NC}"
    echo -e "   ${BLUE}To use xterm with Sixel support:${NC}"
    echo -e "   ${BLUE}  xterm -ti vt340 -e bash${NC}"
fi

# Check known good terminals
case "${TERM_PROGRAM:-}${TERM:-}" in
    *mlterm*|*WezTerm*|*mintty*|*iTerm.app*|*foot*)
        LIKELY_SIXEL=true
        REASON="known Sixel-capable terminal"
        ;;
esac

# Check for VTE (known bad)
if [[ -n "${VTE_VERSION:-}" ]]; then
    LIKELY_SIXEL=false
    REASON="VTE-based terminal (no Sixel support)"
fi

# Special case for xterm
if [[ "${TERM:-}" == xterm* ]] && [[ -n "${XTERM_VERSION:-}" ]]; then
    echo -e "   ${YELLOW}XTerm detected (${XTERM_VERSION})${NC}"
    echo -e "   ${YELLOW}Note: xterm requires -ti vt340 option for Sixel${NC}"
    echo -e "   ${BLUE}To enable Sixel: xterm -ti vt340${NC}"
fi

if [[ "$LIKELY_SIXEL" == "true" ]]; then
    echo -e "   ${GREEN}✓ This terminal likely supports Sixel ($REASON)${NC}"
else
    if [[ -n "$REASON" ]]; then
        echo -e "   ${YELLOW}✗ This terminal likely does NOT support Sixel ($REASON)${NC}"
    else
        echo -e "   ${YELLOW}? Sixel support uncertain for this terminal${NC}"
    fi
fi

echo ""
echo -e "${CYAN}=== Test Complete ===${NC}"
echo ""

# 7. Test ShellForge detection
echo -e "${BOLD}7. Testing ShellForge's detection:${NC}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "${SCRIPT_DIR}")"

if [[ -f "${PROJECT_ROOT}/shellforge" ]]; then
    echo -e "   ${BLUE}Running ShellForge image capability detection...${NC}"
    SHELLFORGE_SOURCED=true
    VERBOSE=true
    source "${PROJECT_ROOT}/shellforge"
    
    # Initialize and show capabilities
    init_image_renderer
    echo ""
    show_image_capabilities
else
    echo -e "   ${YELLOW}ShellForge not built. Run: make${NC}"
fi
