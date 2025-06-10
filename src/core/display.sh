#!/usr/bin/env bash
# ShellForge Display Functions
# Functions for displaying banners, messages, and UI elements

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
    printf "\n${GREEN}v${VERSION}${NC} - Shell configuration backup and restore tool\n\n"
    
    printf "${YELLOW}Usage:${NC}\n"
    printf "    %s save [machine_name] [--verbose]     - Save current shell configurations\n" "$(basename "$0")"
    printf "    %s restore [machine_name]              - Restore shell configurations\n" "$(basename "$0")"
    printf "    %s list                                - List available backups\n" "$(basename "$0")"
    printf "    %s help                                - Show this help message\n\n" "$(basename "$0")"

    printf "${YELLOW}Options:${NC}\n"
    printf "    machine_name    Override the default machine name (default: %s)\n" "${MACHINE_NAME}"
    printf "    --verbose       Show detailed information about what's being backed up/skipped\n\n"

    printf "${YELLOW}Environment Variables:${NC}\n"
    printf "    BACKUP_DEST                  Backup destination directory (required)\n"
    printf "    SHELLFORGE_SMART_CONFIG      Enable smart .config filtering (default: true)\n"
    printf "    SHELLFORGE_MAX_DIR_SIZE_MB   Max size for .config subdirectories (default: 50MB)\n"
    printf "    SHELLFORGE_CONFIG_INCLUDE    Comma-separated list of .config dirs to force include\n"
    printf "    SHELLFORGE_VERBOSE           Enable verbose output (default: false)\n\n"

    printf "${YELLOW}Examples:${NC}\n"
    printf "    %s save                    # Save using hostname\n" "$(basename "$0")"
    printf "    %s save macbook-work       # Save with custom name\n" "$(basename "$0")"
    printf "    %s save --verbose          # Save with detailed output\n" "$(basename "$0")"
    printf "    %s restore                 # Restore from hostname backup\n" "$(basename "$0")"
    printf "    %s restore macbook-work    # Restore from specific backup\n\n" "$(basename "$0")"

    printf "${YELLOW}Smart Config Filtering:${NC}\n"
    printf "When SHELLFORGE_SMART_CONFIG is enabled (default), large binary/cache directories\n"
    printf "in ~/.config are automatically excluded from backups. This includes browser caches,\n"
    printf "electron app data, and other non-configuration files.\n\n"
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
