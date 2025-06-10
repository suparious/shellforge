#!/usr/bin/env bash
# ShellForge Utility Functions
# Common utility functions used throughout the application

# Check if BACKUP_DEST is set
check_backup_dest() {
    if [[ -z "${BACKUP_DEST}" ]]; then
        printf "${RED}Error: BACKUP_DEST environment variable is not set${NC}\n"
        printf "Please set it to your backup directory path:\n"
        printf "  export BACKUP_DEST=/path/to/backup/directory\n"
        exit 1
    fi

    if [[ ! -d "${BACKUP_DEST}" ]]; then
        printf "${YELLOW}Warning: BACKUP_DEST directory doesn't exist. Creating it...${NC}\n"
        mkdir -p "${BACKUP_DEST}"
    fi
}

# Create backup directory structure
create_backup_structure() {
    local machine_dir="${BACKUP_DEST}/${MACHINE_NAME}"
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local backup_dir="${machine_dir}/${timestamp}"

    mkdir -p "${backup_dir}/home"
    mkdir -p "${backup_dir}/metadata"

    echo "${backup_dir}"
}

# Get directory size in MB
get_dir_size_mb() {
    local dir="$1"
    local size_kb=$(du -sk "$dir" 2>/dev/null | cut -f1)
    echo $((size_kb / 1024))
}

# Check if path should be skipped
should_skip() {
    local path="$1"
    local basename=$(basename "$path")

    # Check if it's in skip list
    for skip in "${SKIP_DIRS[@]}"; do
        if [[ "$basename" == "$skip" ]]; then
            return 0
        fi
    done

    # Check if it's a git repository (has .git directory)
    if [[ -d "$path/.git" ]]; then
        return 0
    fi

    return 1
}
