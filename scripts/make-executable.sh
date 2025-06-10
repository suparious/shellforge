#!/bin/bash
# Make all scripts executable

# Make core scripts executable
chmod +x setup.sh update.sh 2>/dev/null

# Make test scripts executable
chmod +x tests/*.sh 2>/dev/null

# Make utility scripts executable  
chmod +x scripts/*.sh 2>/dev/null

# Make build script executable
chmod +x build/build.sh 2>/dev/null

echo "✓ Made all scripts executable"
