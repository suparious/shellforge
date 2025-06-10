#!/usr/bin/env bash
# ShellForge Backup Filters Library
# Functions for filtering what gets backed up

# Check if config subdirectory should be skipped
should_skip_config_subdir() {
    local dir="$1"
    local basename=$(basename "$dir")
    local reason=""
    
    # Check if it's in the force include list
    if [[ -n "${CONFIG_INCLUDE}" ]]; then
        IFS=',' read -ra INCLUDE_ARRAY <<< "${CONFIG_INCLUDE}"
        for include in "${INCLUDE_ARRAY[@]}"; do
            if [[ "$basename" == "$include" ]]; then
                return 1  # Don't skip
            fi
        done
    fi
    
    # Check against known skip directories
    for skip in "${CONFIG_SKIP_DIRS[@]}"; do
        if [[ "$basename" == "$skip" ]]; then
            reason="blacklisted"
            if [[ "${VERBOSE}" == "true" ]]; then
                printf "    ${YELLOW}⚠${NC}  Skipping %s (${reason})\n" "$basename"
            fi
            return 0
        fi
    done
    
    # Check against patterns
    if matches_skip_pattern "$dir"; then
        reason="matches skip pattern"
        if [[ "${VERBOSE}" == "true" ]]; then
            printf "    ${YELLOW}⚠${NC}  Skipping %s (${reason})\n" "$basename"
        fi
        return 0
    fi
    
    # Check size
    if [[ -n "${MAX_DIR_SIZE_MB}" ]] && [[ "${MAX_DIR_SIZE_MB}" -gt 0 ]]; then
        local size_mb=$(get_dir_size_mb "$dir")
        if [[ $size_mb -gt ${MAX_DIR_SIZE_MB} ]]; then
            reason="too large (${size_mb}MB > ${MAX_DIR_SIZE_MB}MB)"
            if [[ "${VERBOSE}" == "true" ]]; then
                printf "    ${YELLOW}⚠${NC}  Skipping %s (${reason})\n" "$basename"
            fi
            return 0
        fi
    fi
    
    return 1
}

# Get list of files to backup
get_backup_files() {
    local -a files=()
    
    # Add dotfiles
    for dotfile in "${DOTFILES[@]}"; do
        if file_exists_readable "${HOME}/${dotfile}"; then
            files+=("${dotfile}")
        fi
    done
    
    echo "${files[@]}"
}

# Get list of directories to backup
get_backup_directories() {
    local -a dirs=()
    
    # Add config directories (except .config which is handled specially)
    for dir in "${CONFIG_DIRS[@]}"; do
        if [[ "$dir" != ".config" ]] && dir_exists_readable "${HOME}/${dir}" && ! should_skip "${HOME}/${dir}"; then
            dirs+=("${dir}")
        fi
    done
    
    echo "${dirs[@]}"
}
