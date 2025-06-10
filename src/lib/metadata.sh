#!/usr/bin/env bash
# ShellForge Metadata Library
# Functions for handling backup metadata

# Create a .shellforge marker file to identify ShellForge backups
create_marker_file() {
    local backup_dir="$1"
    local marker_file="${backup_dir}/.shellforge"
    
    # Create marker with enhanced metadata
    cat > "${marker_file}" << EOF
# ShellForge Backup Marker
# This file identifies this directory as a ShellForge backup
VERSION=${VERSION}
TIMESTAMP=$(date +%s)
DATE=$(date -R)
TOOL=ShellForge
MACHINE=${MACHINE_NAME}
USER=${USER}
EOF
    
    # Make it hidden on systems that respect dot files
    if [[ "$OSTYPE" == "darwin"* ]] && command -v chflags &> /dev/null; then
        chflags hidden "${marker_file}" 2>/dev/null || true
    fi
}

# Check if a directory is a ShellForge backup
is_shellforge_backup() {
    local dir="$1"
    # Check if the marker file exists and is readable
    if [[ -f "${dir}/.shellforge" ]] && [[ -r "${dir}/.shellforge" ]]; then
        return 0
    else
        return 1
    fi
}

# Get timestamp from marker file
get_marker_timestamp() {
    local dir="$1"
    local marker="${dir}/.shellforge"
    
    if [[ -f "$marker" ]]; then
        grep '^TIMESTAMP=' "$marker" | cut -d= -f2
    fi
}

# Update global ShellForge metadata
update_global_metadata() {
    local machine="$1"
    local backup_dir="$2"
    local global_meta="${BACKUP_DEST}/.shellforge-meta"
    
    # Create temp file for atomic update
    local temp_file="${global_meta}.tmp"
    
    # Read existing metadata or create new
    if [[ -f "$global_meta" ]]; then
        grep -v "^${machine}=" "$global_meta" > "$temp_file" 2>/dev/null || true
    fi
    
    # Add/update machine entry
    echo "${machine}=$(basename "$backup_dir")" >> "$temp_file"
    
    # Atomic rename
    mv "$temp_file" "$global_meta"
}

# Create metadata file with system information
create_metadata_file() {
    local metadata_file="$1"
    
    cat > "${metadata_file}" << EOF
Backup Information
==================
Date: $(date)
Machine: ${MACHINE_NAME}
Hostname: $(hostname)
User: ${USER}
OS: $(uname -s)
OS Version: $(uname -r)
Shell: ${SHELL}
Home Directory: ${HOME}
ShellForge Version: ${VERSION}
Smart Config Enabled: ${SMART_CONFIG}
Max Dir Size: ${MAX_DIR_SIZE_MB}MB
Build: ${SHELLFORGE_BUILD:-unknown}
Build Time: ${SHELLFORGE_BUILD_TIME:-unknown}
EOF
}

# Read metadata from file
read_metadata() {
    local metadata_file="$1"
    if [[ -f "${metadata_file}" ]]; then
        cat "${metadata_file}"
    fi
}

# Extract specific field from metadata
get_metadata_field() {
    local metadata_file="$1"
    local field="$2"
    
    if [[ -f "${metadata_file}" ]]; then
        grep "^${field}:" "${metadata_file}" | cut -d' ' -f2-
    fi
}

# Create enhanced backup statistics file
create_backup_stats() {
    local backup_dir="$1"
    local stats_file="${backup_dir}/.stats"
    
    # Count files and calculate size
    local file_count=0
    local total_size=0
    
    # Count files (excluding our metadata files)
    if command -v find &> /dev/null; then
        file_count=$(find "${backup_dir}" -type f ! -name '.shellforge' ! -name '.stats' ! -name 'BACKUP_INFO.txt' 2>/dev/null | wc -l | tr -d ' ')
    fi
    
    # Get total size
    if command -v du &> /dev/null; then
        total_size=$(du -sb "${backup_dir}" 2>/dev/null | cut -f1)
    fi
    
    # Create stats file
    cat > "${stats_file}" << EOF
FILE_COUNT=${file_count}
TOTAL_SIZE=${total_size}
CREATED=$(date +%s)
EOF
}

# Get backup statistics
get_backup_stats() {
    local backup_dir="$1"
    local stats_file="${backup_dir}/.stats"
    
    if [[ -f "$stats_file" ]]; then
        # Return as associative array format
        echo "FILE_COUNT=$(grep '^FILE_COUNT=' "$stats_file" | cut -d= -f2)"
        echo "TOTAL_SIZE=$(grep '^TOTAL_SIZE=' "$stats_file" | cut -d= -f2)"
    else
        # Fallback to calculating on the fly
        local file_count=0
        if command -v find &> /dev/null; then
            file_count=$(find "${backup_dir}" -type f 2>/dev/null | wc -l | tr -d ' ')
        fi
        echo "FILE_COUNT=${file_count}"
        echo "TOTAL_SIZE=unknown"
    fi
}

# Format timestamp to human readable
format_timestamp() {
    local timestamp="$1"
    
    # Validate timestamp
    if [[ -z "$timestamp" ]] || ! [[ "$timestamp" =~ ^[0-9]+$ ]]; then
        echo "unknown"
        return
    fi
    
    local now=$(date +%s 2>/dev/null || echo 0)
    if [[ "$now" == "0" ]]; then
        echo "unknown"
        return
    fi
    
    local diff=$((now - timestamp))
    
    # Handle negative or zero differences
    if [[ $diff -lt 0 ]]; then
        echo "future"
        return
    elif [[ $diff -lt 60 ]]; then
        echo "just now"
    elif [[ $diff -lt 3600 ]]; then
        local mins=$((diff / 60))
        if [[ $mins -eq 1 ]]; then
            echo "1 minute ago"
        else
            echo "${mins} minutes ago"
        fi
    elif [[ $diff -lt 86400 ]]; then
        local hours=$((diff / 3600))
        if [[ $hours -eq 1 ]]; then
            echo "1 hour ago"
        else
            echo "${hours} hours ago"
        fi
    elif [[ $diff -lt 604800 ]]; then
        local days=$((diff / 86400))
        if [[ $days -eq 1 ]]; then
            echo "1 day ago"
        else
            echo "${days} days ago"
        fi
    else
        # Try to format as date
        local formatted_date
        formatted_date=$(date -d "@${timestamp}" "+%Y-%m-%d" 2>/dev/null) ||
        formatted_date=$(date -r "${timestamp}" "+%Y-%m-%d" 2>/dev/null) ||
        formatted_date="long ago"
        echo "$formatted_date"
    fi
}

# Format bytes to human readable
format_bytes() {
    local bytes="$1"
    
    if [[ -z "$bytes" ]] || [[ "$bytes" == "unknown" ]] || [[ "$bytes" == "0" ]]; then
        echo "unknown"
        return
    fi
    
    # Ensure bytes is a number
    if ! [[ "$bytes" =~ ^[0-9]+$ ]]; then
        echo "unknown"
        return
    fi
    
    if [[ $bytes -lt 1024 ]]; then
        echo "${bytes}B"
    elif [[ $bytes -lt 1048576 ]]; then
        echo "$((bytes / 1024))KB"
    elif [[ $bytes -lt 1073741824 ]]; then
        echo "$((bytes / 1048576))MB"
    else
        echo "$((bytes / 1073741824))GB"
    fi
}
