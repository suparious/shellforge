#!/bin/bash
# Quick setup for the modular build system

set -euo pipefail

echo "Setting up ShellForge modular build system..."

# Make build script executable
chmod +x build/build.sh

# Create initial build
echo "Running initial build..."
./build/build.sh

echo "✓ Setup complete!"
echo ""
echo "You can now use:"
echo "  make         - Build release version"
echo "  make debug   - Build with debug info"
echo "  make minimal - Build minimal version"
echo "  make install - Install to ~/bin"
echo ""
echo "Or use the build script directly:"
echo "  ./build/build.sh [release|debug|minimal]"
