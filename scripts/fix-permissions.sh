#!/bin/bash
# Make all shell scripts executable

echo "Setting executable permissions on shell scripts..."

# Core scripts
chmod +x build/build.sh 2>/dev/null && echo "✓ build/build.sh"
chmod +x setup.sh 2>/dev/null && echo "✓ setup.sh"
chmod +x update.sh 2>/dev/null && echo "✓ update.sh"

# Test scripts
for script in tests/*.sh; do
    if [[ -f "$script" ]]; then
        chmod +x "$script" 2>/dev/null && echo "✓ $script"
    fi
done

# Utility scripts
for script in scripts/*.sh; do
    if [[ -f "$script" ]]; then
        chmod +x "$script" 2>/dev/null && echo "✓ $script"
    fi
done

# Source scripts (should already be executable, but just in case)
for dir in src/core src/lib src/modules; do
    for script in "$dir"/*.sh; do
        if [[ -f "$script" ]]; then
            chmod +x "$script" 2>/dev/null && echo "✓ $script"
        fi
    done
done

if [[ -f "src/header.sh" ]]; then
    chmod +x "src/header.sh" 2>/dev/null && echo "✓ src/header.sh"
fi

if [[ -f "src/main.sh" ]]; then
    chmod +x "src/main.sh" 2>/dev/null && echo "✓ src/main.sh"
fi

# Make the built shellforge executable if it exists
if [[ -f "shellforge" ]]; then
    chmod +x shellforge 2>/dev/null && echo "✓ shellforge"
fi

echo "Done!"
