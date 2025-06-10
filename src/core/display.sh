#!/usr/bin/env bash
# ShellForge Display Functions
# Functions for displaying banners, messages, and UI elements

# Helper function to truncate paths for display
truncate_path() {
    local path="$1"
    local max_len=40
    
    if [[ ${#path} -le $max_len ]]; then
        echo "$path"
    else
        # Show first 15 and last 20 characters with ... in middle
        echo "${path:0:15}...${path: -20}"
    fi
}

# Get disk space info for a directory
get_disk_space() {
    local dir="$1"
    local parent_dir="$dir"
    
    # Find the nearest existing parent directory
    while [[ ! -d "$parent_dir" ]] && [[ "$parent_dir" != "/" ]]; do
        parent_dir=$(dirname "$parent_dir")
    done
    
    if command -v df &> /dev/null; then
        # Temporarily disable pipefail to handle df errors gracefully
        local old_pipefail="off"
        if [[ -o pipefail ]]; then
            old_pipefail="on"
            set +o pipefail
        fi
        
        local available=$(df -h "$parent_dir" 2>/dev/null | tail -1 | awk '{print $4}')
        
        # Restore pipefail setting
        if [[ "$old_pipefail" == "on" ]]; then
            set -o pipefail
        fi
        
        if [[ -n "$available" ]]; then
            echo "$available"
        else
            echo "unknown"
        fi
    else
        echo "unknown"
    fi
}

# Print a fancy status line with box drawing characters
print_status_line() {
    local icon="$1"
    local color="$2"
    local var_name="$3"
    local var_desc="$4"
    local status_text="$5"
    local extra_info="$6"
    
    # Use box drawing characters for a more elaborate look
    # Using %b instead of %s for status_text to interpret color codes
    printf "    ${color}%s${NC} %-30s ${BLUE}│${NC} %-25s ${BLUE}│${NC} %b" \
        "$icon" \
        "$var_name" \
        "$var_desc" \
        "$status_text"
    
    if [[ -n "$extra_info" ]]; then
        printf " %b" "$extra_info"
    fi
    
    printf "\n"
}

# Print environment variable status with colors and details
print_env_status() {
    local var_name var_desc var_value var_default status_icon status_text status_color extra_info
    
    # Header with box drawing
    printf "    ${BLUE}┌────────────────────────────────┬───────────────────────────┬────────────────────────────────┐${NC}\n"
    printf "    ${BLUE}│${NC} %-30s ${BLUE}│${NC} %-25s ${BLUE}│${NC} %-30s ${BLUE}│${NC}\n" "Variable" "Description" "Status"
    printf "    ${BLUE}├────────────────────────────────┼───────────────────────────┼────────────────────────────────┤${NC}\n"
    
    # Define environment variables to check
    # Format: "VAR_NAME|Description|Default"
    local env_vars=(
        "BACKUP_DEST|Backup destination|REQUIRED"
        "SHELLFORGE_SMART_CONFIG|Smart filtering|true"
        "SHELLFORGE_MAX_DIR_SIZE_MB|Max dir size (MB)|50"
        "SHELLFORGE_CONFIG_INCLUDE|Force include|none"
        "SHELLFORGE_VERBOSE|Verbose output|false"
    )
    
    for var_info in "${env_vars[@]}"; do
        IFS='|' read -r var_name var_desc var_default <<< "$var_info"
        var_value="${!var_name:-}"
        extra_info=""
        
        # Determine status
        if [[ -n "$var_value" ]]; then
            if [[ "$var_name" == "BACKUP_DEST" ]]; then
                # Special handling for BACKUP_DEST
                if [[ -d "$var_value" ]]; then
                    status_icon="✓"
                    status_color="${GREEN}"
                    status_text="$(truncate_path "$var_value")"
                    
                    # Check if writable
                    if [[ -w "$var_value" ]]; then
                        local disk_space=$(get_disk_space "$var_value")
                        extra_info="${GREEN}[${disk_space} free]${NC}"
                    else
                        extra_info="${RED}[read-only!]${NC}"
                        status_icon="⚠"
                        status_color="${YELLOW}"
                    fi
                elif [[ -e "$var_value" ]]; then
                    status_icon="⚠"
                    status_color="${YELLOW}"
                    status_text="exists but not a directory"
                    extra_info="${YELLOW}[fix required]${NC}"
                else
                    status_icon="!"
                    status_color="${YELLOW}"
                    status_text="will be created"
                    local disk_space=$(get_disk_space "$var_value")
                    extra_info="${BLUE}[${disk_space} available]${NC}"
                fi
            else
                # Other variables
                status_icon="✓"
                status_color="${GREEN}"
                if [[ "$var_value" == "$var_default" ]]; then
                    status_text="${var_value}"
                    extra_info="${BLUE}[default]${NC}"
                else
                    status_text="${var_value}"
                    extra_info="${MAGENTA}[custom]${NC}"
                fi
            fi
        else
            # Variable not set
            if [[ "$var_default" == "REQUIRED" ]]; then
                status_icon="✗"
                status_color="${RED}"
                status_text="${RED}Not set!${NC}"
                extra_info="${RED}[REQUIRED]${NC}"
            else
                status_icon="○"
                status_color="${BLUE}"
                status_text="not set"
                extra_info="${BLUE}[default: ${var_default}]${NC}"
            fi
        fi
        
        # Print the line
        print_status_line "$status_icon" "$status_color" "$var_name" "$var_desc" "$status_text" "$extra_info"
    done
    
    # Footer
    printf "    ${BLUE}└────────────────────────────────┴───────────────────────────┴────────────────────────────────┘${NC}\n"
    
    # Calculate readiness score
    local readiness_score=0
    local max_score=5
    local readiness_text=""
    
    # Score calculation
    if [[ -n "${BACKUP_DEST:-}" ]]; then
        ((readiness_score++))
        if [[ -d "${BACKUP_DEST}" ]]; then
            ((readiness_score++))
            if [[ -w "${BACKUP_DEST}" ]]; then
                ((readiness_score++))
            fi
        fi
    fi
    
    if [[ "${SHELLFORGE_SMART_CONFIG}" == "true" ]]; then
        ((readiness_score++))
    fi
    
    if [[ -n "${SHELLFORGE_MAX_DIR_SIZE_MB:-}" ]]; then
        ((readiness_score++))
    fi
    
    # Create visual readiness meter
    local meter_width=20
    local filled=$((readiness_score * meter_width / max_score))
    local empty=$((meter_width - filled))
    local meter="${GREEN}"
    
    for ((i=0; i<filled; i++)); do
        meter+="█"
    done
    
    if [[ $empty -gt 0 ]]; then
        meter+="${BLUE}"
        for ((i=0; i<empty; i++)); do
            meter+="░"
        done
    fi
    meter+="${NC}"
    
    # Readiness status text
    case $readiness_score in
        5) readiness_text="${GREEN}★ Fully Configured${NC}" ;;
        4) readiness_text="${GREEN}✓ Ready to Use${NC}" ;;
        3) readiness_text="${YELLOW}⚠ Basic Setup${NC}" ;;
        2) readiness_text="${YELLOW}⚠ Needs Configuration${NC}" ;;
        1) readiness_text="${RED}✗ Missing Requirements${NC}" ;;
        0) readiness_text="${RED}✗ Not Configured${NC}" ;;
    esac
    
    # Status summary with visual indicators
    local backup_dest_status=""
    if [[ -n "${BACKUP_DEST:-}" ]]; then
        if [[ -d "${BACKUP_DEST}" ]] && [[ -w "${BACKUP_DEST}" ]]; then
            backup_dest_status="${GREEN}● Backup destination ready${NC}"
        elif [[ -d "${BACKUP_DEST}" ]]; then
            backup_dest_status="${YELLOW}● Backup destination not writable${NC}"
        else
            backup_dest_status="${BLUE}● Backup destination will be created${NC}"
        fi
    else
        backup_dest_status="${RED}● Backup destination not configured${NC}"
    fi
    
    printf "\n    ${BLUE}┌─ Configuration Status ──────────────────────────────┐${NC}\n"
    printf "    ${BLUE}│${NC} Readiness: [%b] %d/%d        ${BLUE}│${NC}\n" "$meter" "$readiness_score" "$max_score"
    printf "    ${BLUE}│${NC} Status: %b                     ${BLUE}│${NC}\n" "$readiness_text"
    printf "    ${BLUE}│${NC} %b              ${BLUE}│${NC}\n" "$backup_dest_status"
    printf "    ${BLUE}└───────────────────────────────────────────────────────┘${NC}\n"
    
    # Extra info if BACKUP_DEST is not set
    if [[ -z "${BACKUP_DEST:-}" ]]; then
        printf "\n    ${YELLOW}┌─ Quick Setup ─────────────────────────────────────────┐${NC}\n"
        printf "    ${YELLOW}│${NC} Set your backup destination:                          ${YELLOW}│${NC}\n"
        printf "    ${YELLOW}│${NC}   ${GREEN}export BACKUP_DEST=~/Backups/shellforge${NC}            ${YELLOW}│${NC}\n"
        printf "    ${YELLOW}└───────────────────────────────────────────────────────┘${NC}\n"
    fi
}

# Display banner
display_banner() {
    if [[ "${HAS_FIGLET}" == "true" ]] && [[ "${HAS_LOLCAT}" == "true" ]]; then
        figlet -f slant "ShellForge" | lolcat -f
    elif [[ "${HAS_FIGLET}" == "true" ]]; then
        printf "${BLUE}"
        figlet -f slant "ShellForge"
        printf "${NC}"
    else
        printf "${BLUE}╔═══════════════════════════════╗${NC}\n"
        printf "${BLUE}║        ShellForge 🔥          ║${NC}\n"
        printf "${BLUE}╚═══════════════════════════════╝${NC}\n"
    fi
}

# Print usage information
usage() {
    display_banner
    printf "\n${GREEN}v${VERSION}${NC} - Shell configuration backup and restore tool\n"
    
    # Add timestamp and system info
    local current_time=$(date "+%Y-%m-%d %H:%M:%S" 2>/dev/null || echo "unknown")
    local shell_type="bash"  # Default to bash
    if [[ -n "${SHELL:-}" ]]; then
        shell_type=$(basename "$SHELL" 2>/dev/null || echo "$SHELL")
    fi
    printf "${BLUE}Generated: ${NC}%s ${BLUE}|${NC} ${BLUE}Shell: ${NC}%s ${BLUE}|${NC} ${BLUE}User: ${NC}%s\n\n" \
        "$current_time" "$shell_type" "${USER:-unknown}"
    
    # Get script name safely
    local script_name="shellforge"
    if [[ -n "${0:-}" ]]; then
        script_name=$(basename "$0" 2>/dev/null || echo "shellforge")
    fi
    
    printf "${YELLOW}Usage:${NC}\n"
    printf "    %s save [machine_name] [--verbose]     - Save current shell configurations\n" "$script_name"
    printf "    %s restore [machine_name]              - Restore shell configurations\n" "$script_name"
    printf "    %s list                                - List available backups\n" "$script_name"
    printf "    %s help                                - Show this help message\n\n" "$script_name"

    printf "${YELLOW}Options:${NC}\n"
    printf "    machine_name    Override the default machine name (default: %s)\n" "${MACHINE_NAME}"
    printf "    --verbose       Show detailed information about what's being backed up/skipped\n\n"

    printf "${YELLOW}Environment Variables:${NC}\n"
    print_env_status
    printf "\n"

    printf "${YELLOW}Examples:${NC}\n"
    printf "    %s save                    # Save using hostname\n" "$script_name"
    printf "    %s save macbook-work       # Save with custom name\n" "$script_name"
    printf "    %s save --verbose          # Save with detailed output\n" "$script_name"
    printf "    %s restore                 # Restore from hostname backup\n" "$script_name"
    printf "    %s restore macbook-work    # Restore from specific backup\n\n" "$script_name"

    printf "${YELLOW}Smart Config Filtering:${NC}\n"
    printf "When SHELLFORGE_SMART_CONFIG is enabled (default), large binary/cache directories\n"
    printf "in ~/.config are automatically excluded from backups. This includes browser caches,\n"
    printf "electron app data, and other non-configuration files.\n\n"
    
    # Fun tips/quotes
    local tips=(
        "💡 Tip: Run 'sfs' for a quick save!"
        "🔥 Your shell configs are too hot to lose!"
        "📦 Keep your dotfiles safe and sound!"
        "🚀 Blast your configs to any machine!"
        "🛡️ Protect your precious shell customizations!"
        "⚡ Fast backups, faster restores!"
        "🎯 Never lose your perfect setup again!"
        "🌟 Star us on GitHub if you love ShellForge!"
    )
    
    # Select random tip based on current second
    local tip_index=$(($(date +%S) % ${#tips[@]}))
    
    printf "${BLUE}┌───────────────────────────────────────────────────────┐${NC}\n"
    printf "${BLUE}│${NC} %s %*s${BLUE}│${NC}\n" "${tips[$tip_index]}" $((54 - ${#tips[$tip_index]})) " "
    printf "${BLUE}└───────────────────────────────────────────────────────┘${NC}\n"
}

# Show fun success message
show_success_message() {
    local message="$1"
    
    if [[ "${HAS_COWSAY}" == "true" ]] && [[ "${HAS_LOLCAT}" == "true" ]]; then
        echo "$message" | cowsay -f tux | lolcat -f
    elif [[ "${HAS_COWSAY}" == "true" ]]; then
        echo "$message" | cowsay -f tux
    fi
}

# Show restore success message
show_restore_success() {
    local message="$1"
    
    if [[ "${HAS_COWSAY}" == "true" ]] && [[ "${HAS_LOLCAT}" == "true" ]]; then
        echo "$message" | cowsay -f dragon | lolcat -f
    elif [[ "${HAS_COWSAY}" == "true" ]]; then
        echo "$message" | cowsay -f dragon
    fi
}
