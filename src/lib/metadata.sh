#!/usr/bin/env bash
# ShellForge Metadata Library
# Functions for handling backup metadata

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
