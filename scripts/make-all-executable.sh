#!/bin/bash
# Make all shell scripts executable

cd /home/shaun/repos/shellforge

echo "Making shell scripts executable..."

# Make all .sh files executable
find . -name "*.sh" -type f -exec chmod +x {} \; -print | while read file; do
    echo "✓ $file"
done

# Make the main shellforge script executable if it exists
if [[ -f "shellforge" ]]; then
    chmod +x shellforge
    echo "✓ ./shellforge"
fi

echo ""
echo "Done! All shell scripts are now executable."
