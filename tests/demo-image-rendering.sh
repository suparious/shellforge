#!/usr/bin/env bash
# Demo script to showcase ShellForge image rendering capabilities

set -euo pipefail

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "${SCRIPT_DIR}")"

# Color definitions for the demo
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Build ShellForge
echo -e "${BLUE}Building ShellForge...${NC}"
"${PROJECT_ROOT}/build/build.sh" debug >/dev/null 2>&1

echo -e "${GREEN}✓ Build complete${NC}"
echo ""

# Create demo images
echo -e "${CYAN}=== ShellForge Image Rendering Demo ===${NC}"
echo ""

# Create a demo PNG image
DEMO_PNG="${SCRIPT_DIR}/demo-shellforge-logo.png"
if command -v convert &>/dev/null; then
    echo -e "${YELLOW}Creating demo PNG image...${NC}"
    convert -size 400x200 \
            gradient:blue-darkblue \
            -gravity center \
            -font Arial -pointsize 48 -fill white \
            -annotate +0-20 "ShellForge" \
            -font Arial -pointsize 24 -fill yellow \
            -annotate +0+30 "🔥 Configuration Backup Tool" \
            "$DEMO_PNG" 2>/dev/null
    echo -e "${GREEN}✓ Created demo PNG${NC}"
else
    echo -e "${YELLOW}⚠ ImageMagick not found, skipping PNG creation${NC}"
fi

# Create a demo SVG image
DEMO_SVG="${SCRIPT_DIR}/demo-shellforge-logo.svg"
echo -e "${YELLOW}Creating demo SVG image...${NC}"
cat > "$DEMO_SVG" << 'EOF'
<svg width="400" height="200" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="bgGradient" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" style="stop-color:#4a90e2;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#1e3a5f;stop-opacity:1" />
    </linearGradient>
  </defs>
  <rect width="400" height="200" fill="url(#bgGradient)"/>
  <text x="50%" y="40%" text-anchor="middle" 
        font-family="Arial, sans-serif" font-size="48" font-weight="bold" fill="white">
    ShellForge
  </text>
  <text x="50%" y="60%" text-anchor="middle" 
        font-family="Arial, sans-serif" font-size="24" fill="#ffcc00">
    🔥 Configuration Backup Tool
  </text>
</svg>
EOF
echo -e "${GREEN}✓ Created demo SVG${NC}"

echo ""
echo -e "${CYAN}=== Testing Different Rendering Scenarios ===${NC}"
echo ""

# Test 1: Normal rendering
echo -e "${BOLD}1. Normal image rendering:${NC}"
"${PROJECT_ROOT}/shellforge" help | head -n 20

echo ""
echo -e "${BOLD}2. With --no-graphics flag:${NC}"
"${PROJECT_ROOT}/shellforge" help --no-graphics | head -n 20

echo ""
echo -e "${BOLD}3. Testing PNG rendering directly:${NC}"
if [[ -f "$DEMO_PNG" ]]; then
    # Source shellforge functions
    SHELLFORGE_SOURCED=true
    source "${PROJECT_ROOT}/shellforge"
    
    if can_render_images; then
        echo -e "${GREEN}Rendering PNG image:${NC}"
        render_image "$DEMO_PNG" 60 12 "[ShellForge Logo]"
    else
        echo -e "${YELLOW}Image rendering not available${NC}"
    fi
fi

echo ""
echo -e "${BOLD}4. Testing SVG rendering:${NC}"
if [[ -f "$DEMO_SVG" ]]; then
    if can_render_images; then
        echo -e "${GREEN}Rendering SVG image:${NC}"
        render_image "$DEMO_SVG" 60 12 "[ShellForge SVG Logo]"
    else
        echo -e "${YELLOW}Image rendering not available${NC}"
    fi
fi

echo ""
echo -e "${BOLD}5. Testing capability detection:${NC}"
show_image_capabilities

echo ""
echo -e "${CYAN}=== Demo Complete ===${NC}"
echo ""

# Cleanup option
read -p "Remove demo images? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -f "$DEMO_PNG" "$DEMO_SVG"
    echo -e "${GREEN}✓ Demo images removed${NC}"
fi
