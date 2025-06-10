#!/bin/bash
# Make all shell scripts executable

echo "Setting executable permissions on shell scripts..."

chmod +x build/build.sh 2>/dev/null && echo "✓ build/build.sh"
chmod +x setup.sh 2>/dev/null && echo "✓ setup.sh"
chmod +x test.sh 2>/dev/null && echo "✓ test.sh"
chmod +x test-smart-config.sh 2>/dev/null && echo "✓ test-smart-config.sh"
chmod +x update.sh 2>/dev/null && echo "✓ update.sh"
chmod +x cleanup-migration.sh 2>/dev/null && echo "✓ cleanup-migration.sh"
chmod +x setup-modular.sh 2>/dev/null && echo "✓ setup-modular.sh"

echo "Done!"
