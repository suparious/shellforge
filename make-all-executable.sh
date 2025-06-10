#!/bin/bash
# Make all scripts executable

find /home/shaun/repos/shellforge -name "*.sh" -type f | while read -r file; do
    chmod +x "$file"
    echo "Made executable: $file"
done

echo "Done!"
