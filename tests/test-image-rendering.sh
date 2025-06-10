#!/usr/bin/env bash
# Test script for ShellForge image rendering capabilities
# This tests the new image-renderer.sh module

set -euo pipefail

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "${SCRIPT_DIR}")"

# Build ShellForge first
echo "Building ShellForge..."
"${PROJECT_ROOT}/build/build.sh" debug

# Source the built shellforge to access its functions
# We need to prevent it from running main() so we'll set a flag
SHELLFORGE_SOURCED=true
source "${PROJECT_ROOT}/shellforge"

# Now we have access to all the functions

echo ""
echo "=== ShellForge Image Rendering Test ==="
echo ""

# Test 1: Check capabilities
echo "1. Checking image rendering capabilities..."
init_image_renderer
show_image_capabilities

echo ""
echo "2. Testing image rendering..."

# Create a test image if it doesn't exist
TEST_IMAGE="${SCRIPT_DIR}/test-image.png"
if [[ ! -f "$TEST_IMAGE" ]]; then
    echo "Creating test image..."
    # Create a simple test image using ImageMagick if available
    if command -v convert &>/dev/null; then
        convert -size 200x100 xc:blue \
                -gravity center -pointsize 20 -fill white \
                -annotate +0+0 "ShellForge\nTest Image" \
                "$TEST_IMAGE"
        echo "Created test image: $TEST_IMAGE"
    else
        echo "ImageMagick not found, skipping image creation"
        TEST_IMAGE=""
    fi
fi

# Test rendering if we have an image
if [[ -n "$TEST_IMAGE" ]] && [[ -f "$TEST_IMAGE" ]]; then
    echo ""
    echo "3. Rendering test image..."
    if can_render_images; then
        render_image "$TEST_IMAGE" 40 10 "[ShellForge Test Image]"
    else
        echo "Image rendering not available"
    fi
fi

# Test SVG handling
echo ""
echo "4. Testing SVG support..."
TEST_SVG="${SCRIPT_DIR}/test-image.svg"
if [[ ! -f "$TEST_SVG" ]]; then
    echo "Creating test SVG..."
    cat > "$TEST_SVG" << 'EOF'
<svg width="200" height="100" xmlns="http://www.w3.org/2000/svg">
  <rect width="200" height="100" fill="#4a90e2"/>
  <text x="50%" y="50%" text-anchor="middle" dy=".3em" 
        font-family="Arial" font-size="20" fill="white">
    ShellForge SVG
  </text>
</svg>
EOF
fi

if [[ -f "$TEST_SVG" ]]; then
    echo "Rendering SVG image..."
    if can_render_images; then
        render_image "$TEST_SVG" 40 10 "[ShellForge SVG Image]"
    else
        echo "Image rendering not available"
    fi
fi

# Test with --no-graphics flag
echo ""
echo "5. Testing with --no-graphics flag..."
NO_GRAPHICS=true
if can_render_images; then
    echo "ERROR: can_render_images() should return false when NO_GRAPHICS=true"
else
    echo "✓ Graphics properly disabled with NO_GRAPHICS=true"
fi

# Try to render with NO_GRAPHICS set
echo "Attempting to render with NO_GRAPHICS=true:"
render_image "$TEST_IMAGE" 40 10 "[Fallback Text]"

# Reset NO_GRAPHICS
NO_GRAPHICS=false

echo ""
echo "=== Test Complete ==="
