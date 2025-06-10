#!/usr/bin/env bash
# ShellForge Restore Module
# Functions for restoring shell configurations

# Restore shell configurations
restore_configs() {
    display_banner
    printf "${BLUE}=== Starting Restore Operation ===${NC}\n"
    printf "Machine: ${GREEN}${MACHINE_NAME}${NC}\n"
    printf "Source: ${GREEN}${BACKUP_DEST}${NC}\n\n"

    local latest_backup="${BACKUP_DEST}/${MACHINE_NAME}/latest"

    if [[ ! -L "${latest_backup}" ]] || [[ ! -d "${latest_backup}" ]]; then
        printf "${RED}Error: No backup found for machine '${MACHINE_NAME}'${NC}\n"
        printf "Available backups:\n"
        list_backups
        exit 1
    fi

    local backup_dir=$(readlink -f "${latest_backup}")
    local home_backup="${backup_dir}/home"
    local metadata_file="${backup_dir}/metadata/backup_info.txt"

    # Show backup information
    if [[ -f "${metadata_file}" ]]; then
        printf "${YELLOW}Backup Information:${NC}\n"
        read_metadata "${metadata_file}"
        echo ""
    fi

    # Confirm restore
    printf "${YELLOW}This will restore configurations from:${NC}\n"
    printf "  %s\n" "${backup_dir}"
    printf "\n${RED}Warning: This will overwrite existing configurations!${NC}\n"
    read -p "Continue? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        printf "${YELLOW}Restore cancelled${NC}\n"
        exit 0
    fi

    printf "\n${YELLOW}Restoring configurations...${NC}\n"

    # Restore all files and directories from home backup
    if [[ -d "${home_backup}" ]]; then
        # Use rsync for better control over the restore
        if command -v rsync &> /dev/null; then
            rsync -av --no-o --no-g "${home_backup}/" "${HOME}/"
        else
            # Fallback to cp if rsync not available
            cp -rp "${home_backup}/." "${HOME}/" 2>/dev/null || true
        fi
    fi

    printf "\n${GREEN}✓ Restore completed successfully!${NC}\n"
    printf "${YELLOW}Note: You may need to restart your shell or source your configuration files${NC}\n"
    
    # Fun success message
    show_restore_success "Shell configs restored from the forge!"
}
