#!/usr/bin/env bash
# ShellForge List Module
# Enhanced listing with TUI elements and detailed information

# List available backups with enhanced UI
list_backups() {
    display_banner "Backup Explorer"
    
    # Check if BACKUP_DEST exists
    if [[ ! -d "${BACKUP_DEST}" ]]; then
        print_box "${YELLOW}No backups found${NC}\\nBACKUP_DEST doesn't exist: ${BACKUP_DEST}" "$YELLOW" 60
        return
    fi
    
    # Display backup destination prominently
    printf "\n${BLUE}┌─ Backup Location ─────────────────────────────────────────────┐${NC}\n"
    printf "${BLUE}│${NC} ${STATUS_ICONS[package]} ${GREEN}%s${NC}%*s${BLUE}│${NC}\n" \
        "$(truncate_path "$BACKUP_DEST" 55)" \
        $((58 - ${#BACKUP_DEST})) " "
    
    # Show disk space
    local disk_space=$(get_disk_space "$BACKUP_DEST")
    printf "${BLUE}│${NC} ${DIM}   Available space: ${disk_space}${NC}%*s${BLUE}│${NC}\n" \
        $((40 - ${#disk_space})) " "
    printf "${BLUE}└───────────────────────────────────────────────────────────────┘${NC}\n\n"
    
    # Collect statistics
    local total_machines=0
    local total_backups=0
    local total_size=0
    local found_any=false
    
    # Temporary file to store machine data
    local temp_data="/tmp/shellforge_list_$$"
    : > "$temp_data"
    
    # First pass: collect data
    for machine_dir in "${BACKUP_DEST}"/*; do
        # Skip if not a directory
        [[ ! -d "${machine_dir}" ]] && continue
        
        local machine=$(basename "${machine_dir}")
        local backup_count=0
        local machine_size=0
        local latest_timestamp=""
        local has_shellforge=false
        
        # Check each backup in the machine directory
        for backup in "${machine_dir}"/*; do
            # Skip if not a directory or is the latest symlink
            [[ ! -d "${backup}" ]] && continue
            [[ "$(basename "${backup}")" == "latest" ]] && continue
            
            # Check if it's a ShellForge backup
            if is_shellforge_backup "$backup" 2>/dev/null; then
                ((backup_count++))
                has_shellforge=true
                found_any=true
                
                # Get size (with error handling)
                local size_bytes=0
                if command -v du &>/dev/null; then
                    size_bytes=$(du -sb "$backup" 2>/dev/null | cut -f1 || echo 0)
                fi
                machine_size=$((machine_size + size_bytes))
                
                # Track latest backup
                local marker_ts=$(get_marker_timestamp "$backup" 2>/dev/null || echo "")
                if [[ -n "$marker_ts" ]] && [[ "$marker_ts" =~ ^[0-9]+$ ]]; then
                    if [[ -z "$latest_timestamp" ]] || [[ "$marker_ts" -gt "$latest_timestamp" ]]; then
                        latest_timestamp="$marker_ts"
                    fi
                fi
            fi
        done
        
        # Store machine data if it has ShellForge backups
        if [[ "$has_shellforge" == "true" ]]; then
            ((total_machines++))
            total_backups=$((total_backups + backup_count))
            total_size=$((total_size + machine_size))
            
            # Save to temp file
            echo "${machine}|${backup_count}|${machine_size}|${latest_timestamp}" >> "$temp_data"
        fi
    done
    
    # Display results
    if [[ "$found_any" != "true" ]]; then
        print_box "${YELLOW}No ShellForge backups found${NC}\\nRun 'shellforge save' to create your first backup!" "$YELLOW" 60
        rm -f "$temp_data"
        return
    fi
    
    printf "${CYAN}Found ${total_machines} machine(s) with ${total_backups} ShellForge backup(s)${NC}\n\n"
    
    # Display each machine
    while IFS='|' read -r machine count size latest; do
        # Skip empty lines
        [[ -z "$machine" ]] && continue
        
        # Machine header with icon
        local machine_icon="💻"
        if [[ "$machine" == "$MACHINE_NAME" ]]; then
            machine_icon="🏠"  # Home icon for current machine
        fi
        
        printf "${GREEN}┌─ %s %s " "$machine_icon" "$machine"
        local header_len=$((${#machine} + 4))
        local padding=$((61 - header_len))
        [[ $padding -lt 1 ]] && padding=1
        printf '─%.0s' $(seq 1 $padding)
        printf "┐${NC}\n"
        
        # Machine info
        printf "${GREEN}│${NC} Backups: ${BOLD}%d${NC}  " "$count"
        printf "Size: ${BOLD}%s${NC}  " "$(format_bytes "$size" 2>/dev/null || echo "unknown")"
        
        if [[ -n "$latest" ]] && [[ "$latest" =~ ^[0-9]+$ ]]; then
            local age_text=$(format_timestamp "$latest" 2>/dev/null || echo "unknown")
            local age_color="$GREEN"
            
            # Color code based on age
            local now=$(date +%s)
            local age_seconds=$((now - latest))
            if [[ $age_seconds -gt 2592000 ]]; then  # Older than a month
                age_color="$RED"
            elif [[ $age_seconds -gt 604800 ]]; then  # Older than a week
                age_color="$YELLOW"
            fi
            
            printf "Latest: ${age_color}%s${NC}" "$age_text"
        fi
        
        # Right padding and close
        printf "%*s${GREEN}│${NC}\n" 10 " "
        
        # List backups for this machine
        printf "${GREEN}│${NC} ${DIM}Backups:${NC}%*s${GREEN}│${NC}\n" 53 " "
        
        local machine_dir="${BACKUP_DEST}/${machine}"
        for backup in "${machine_dir}"/*; do
            # Skip if not a directory or is latest symlink
            [[ ! -d "${backup}" ]] && continue
            [[ "$(basename "${backup}")" == "latest" ]] && continue
            
            # Only show ShellForge backups
            if is_shellforge_backup "$backup" 2>/dev/null; then
                local timestamp=$(basename "${backup}")
                local backup_size="unknown"
                
                # Get backup size
                if command -v du &>/dev/null; then
                    backup_size=$(du -sh "${backup}" 2>/dev/null | cut -f1 || echo "unknown")
                fi
                
                # Format backup line
                printf "${GREEN}│${NC}   "
                
                # Add icon for latest
                if [[ -L "${machine_dir}/latest" ]]; then
                    local latest_target=$(readlink "${machine_dir}/latest" 2>/dev/null || echo "")
                    if [[ "$latest_target" == "$backup" ]] || [[ "$latest_target" == "$(basename "$backup")" ]]; then
                        printf "${BLUE}★${NC} "
                    else
                        printf "  "
                    fi
                else
                    printf "  "
                fi
                
                printf "${DIM}%s${NC} " "$timestamp"
                printf "(${CYAN}%s${NC})" "$backup_size"
                
                # Add age if available
                local marker_ts=$(get_marker_timestamp "$backup" 2>/dev/null || echo "")
                if [[ -n "$marker_ts" ]] && [[ "$marker_ts" =~ ^[0-9]+$ ]]; then
                    local age_text=$(format_timestamp "$marker_ts" 2>/dev/null || echo "")
                    if [[ -n "$age_text" ]]; then
                        printf " - %s" "$age_text"
                    fi
                fi
                
                printf "\n"
            fi
        done
        
        # Machine footer
        printf "${GREEN}└"
        printf '─%.0s' $(seq 1 61)
        printf "┘${NC}\n\n"
        
    done < "$temp_data"
    
    # Clean up
    rm -f "$temp_data"
    
    # Summary section
    printf "${BLUE}┌─ Summary ─────────────────────────────────────────────────────┐${NC}\n"
    printf "${BLUE}│${NC} Total Machines:  ${BOLD}%-10d${NC}%*s${BLUE}│${NC}\n" "$total_machines" 34 " "
    printf "${BLUE}│${NC} Total Backups:   ${BOLD}%-10d${NC}%*s${BLUE}│${NC}\n" "$total_backups" 34 " "
    printf "${BLUE}│${NC} Total Size:      ${BOLD}%-10s${NC}%*s${BLUE}│${NC}\n" "$(format_bytes "$total_size" 2>/dev/null || echo "unknown")" 34 " "
    printf "${BLUE}└───────────────────────────────────────────────────────────────┘${NC}\n"
    
    # Quick commands
    printf "\n${DIM}Quick Commands:${NC}\n"
    printf "  ${GREEN}shellforge save${NC}              - Create a new backup\n"
    printf "  ${GREEN}shellforge restore <machine>${NC} - Restore from backup\n"
    
    # Show tip if not verbose
    if [[ "${VERBOSE}" != "true" ]]; then
        printf "\n${DIM}Tip: Use ${CYAN}shellforge list --verbose${NC} for more details${NC}\n"
    fi
}
