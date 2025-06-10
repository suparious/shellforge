#!/usr/bin/env bash
# ShellForge File Operations Library
# Functions for file and directory operations

# Check if directory matches any skip pattern
matches_skip_pattern() {
    local dir="$1"
    local basename=$(basename "$dir")
    
    for pattern in "${CONFIG_SKIP_PATTERNS[@]}"; do
        if [[ "$basename" == $pattern ]]; then
            return 0
        fi
    done
    
    return 1
}

# Copy files with proper error handling
safe_copy() {
    local source="$1"
    local dest="$2"
    
    if cp -rp "$source" "$dest" 2>/dev/null; then
        return 0
    else
        # Try without preserving permissions if it fails
        cp -r "$source" "$dest" 2>/dev/null || true
    fi
}

# Create directory with parents if needed
ensure_directory() {
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir"
    fi
}

# Check if file exists and is readable
file_exists_readable() {
    local file="$1"
    [[ -f "$file" ]] && [[ -r "$file" ]]
}

# Check if directory exists and is readable
dir_exists_readable() {
    local dir="$1"
    [[ -d "$dir" ]] && [[ -r "$dir" ]]
}
