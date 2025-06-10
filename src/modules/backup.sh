#!/usr/bin/env bash
# ShellForge Backup Module
# Functions for saving shell configurations

# Backup .config directory with smart filtering
backup_config_dir() {
    local config_dir="${HOME}/.config"
    local backup_dest="$1"
    
    if [[ ! -d "${config_dir}" ]]; then
        return
    fi
    
    printf "\n${YELLOW}Backing up .config directory...${NC}\n"
    
    if [[ "${SMART_CONFIG}" != "true" ]]; then
        # Traditional backup - copy entire .config
        printf "  ${GREEN}✓${NC} .config (smart filtering disabled)\n"
        safe_copy "${config_dir}" "${backup_dest}/"
        return
    fi
    
    # Smart backup - filter subdirectories
    printf "  ${MAGENTA}🧠${NC} Using smart config filtering\n"
    
    # Create .config directory in backup
    ensure_directory "${backup_dest}/.config"
    
    # Copy files in .config root (not directories)
    find "${config_dir}" -maxdepth 1 -type f -exec cp -p {} "${backup_dest}/.config/" \; 2>/dev/null
    
    # Process subdirectories
    local total_skipped=0
    local total_backed_up=0
    
    for subdir in "${config_dir}"/*; do
        if [[ -d "$subdir" ]]; then
            local basename=$(basename "$subdir")
            
            if should_skip_config_subdir "$subdir"; then
                ((total_skipped++))
            else
                if [[ "${VERBOSE}" == "true" ]]; then
                    local size_mb=$(get_dir_size_mb "$subdir")
                    printf "    ${GREEN}✓${NC} %s (%dMB)\n" "$basename" "$size_mb"
                fi
                safe_copy "$subdir" "${backup_dest}/.config/"
                ((total_backed_up++))
            fi
        fi
    done
    
    printf "  ${GREEN}📊${NC} Backed up %d directories, skipped %d\n" "$total_backed_up" "$total_skipped"
}

# Backup SSH PEM files
backup_ssh_pem_files() {
    local backup_dest="$1"
    
    printf "\n${YELLOW}Backing up SSH PEM files...${NC}\n"
    
    if [[ -d "${HOME}/.ssh" ]]; then
        ensure_directory "${backup_dest}/.ssh"
        local found_pem=false
        
        for pem_file in "${HOME}"/.ssh/*.pem; do
            if [[ -f "${pem_file}" ]]; then
                local basename=$(basename "${pem_file}")
                printf "  ${GREEN}✓${NC} .ssh/%s\n" "${basename}"
                safe_copy "${pem_file}" "${backup_dest}/.ssh/"
                found_pem=true
            fi
        done
        
        if [[ "$found_pem" == "false" ]]; then
            printf "  ${BLUE}ℹ${NC} No PEM files found in .ssh\n"
        fi
    else
        printf "  ${BLUE}ℹ${NC} No .ssh directory found\n"
    fi
}

# Backup SSL directory
backup_ssl_directory() {
    local backup_dest="$1"
    
    printf "\n${YELLOW}Checking for SSL directory...${NC}\n"
    
    if dir_exists_readable "${HOME}/.ssl"; then
        printf "  ${GREEN}✓${NC} .ssl directory found, backing up...\n"
        safe_copy "${HOME}/.ssl" "${backup_dest}/"
    else
        printf "  ${BLUE}ℹ${NC} No .ssl directory found\n"
    fi
}

# Save shell configurations
save_configs() {
    display_banner
    printf "${BLUE}=== Starting Save Operation ===${NC}\n"
    printf "Machine: ${GREEN}${MACHINE_NAME}${NC}\n"
    printf "Destination: ${GREEN}${BACKUP_DEST}${NC}\n"
    printf "Smart Config: ${GREEN}${SMART_CONFIG}${NC}\n\n"

    local backup_dir=$(create_backup_structure)
    local home_backup="${backup_dir}/home"
    local metadata_file="${backup_dir}/metadata/backup_info.txt"

    # Save metadata
    create_metadata_file "${metadata_file}"

    printf "${YELLOW}Backing up dotfiles...${NC}\n"
    # Backup individual dotfiles
    for dotfile in "${DOTFILES[@]}"; do
        if file_exists_readable "${HOME}/${dotfile}"; then
            printf "  ${GREEN}✓${NC} %s\n" "${dotfile}"
            safe_copy "${HOME}/${dotfile}" "${home_backup}/"
        fi
    done

    printf "\n${YELLOW}Backing up configuration directories...${NC}\n"
    # Backup configuration directories
    for dir in "${CONFIG_DIRS[@]}"; do
        if [[ "$dir" == ".config" ]]; then
            # Handle .config specially
            backup_config_dir "${home_backup}"
        elif dir_exists_readable "${HOME}/${dir}" && ! should_skip "${HOME}/${dir}"; then
            printf "  ${GREEN}✓${NC} %s\n" "${dir}"
            # Create parent directories if needed
            ensure_directory "${home_backup}/$(dirname "${dir}")"
            safe_copy "${HOME}/${dir}" "${home_backup}/${dir}"
        fi
    done

    # Backup SSH PEM files
    backup_ssh_pem_files "${home_backup}"
    
    # Backup SSL directory
    backup_ssl_directory "${home_backup}"

    # Create latest symlink
    local latest_link="${BACKUP_DEST}/${MACHINE_NAME}/latest"
    rm -f "${latest_link}"
    ln -s "${backup_dir}" "${latest_link}"

    printf "\n${GREEN}✓ Backup completed successfully!${NC}\n"
    printf "Location: %s\n" "${backup_dir}"
    printf "Latest link: %s\n" "${latest_link}"
    
    # Fun success message
    show_success_message "Your shell configs have been forged!"
}
