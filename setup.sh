#!/bin/bash
# Setup script for ShellForge

set -euo pipefail

# Colors
if [[ -t 1 ]]; then
    # Terminal supports colors
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    NC='\033[0m'
else
    # No color support
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    NC=''
fi

# Script location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SHELLFORGE_SCRIPT="${SCRIPT_DIR}/shellforge"

# Check for display tools
HAS_FIGLET=$(command -v figlet &> /dev/null && echo true || echo false)
HAS_LOLCAT=$(command -v lolcat &> /dev/null && echo true || echo false)

# Display banner
if [[ "${HAS_FIGLET}" == "true" ]] && [[ "${HAS_LOLCAT}" == "true" ]]; then
    figlet -f slant "ShellForge" | lolcat -f
    printf "${YELLOW}Setup${NC}\n" | lolcat -f
elif [[ "${HAS_FIGLET}" == "true" ]]; then
    printf "${BLUE}"
    figlet -f slant "ShellForge"
    printf "${YELLOW}Setup${NC}\n"
else
    printf "${BLUE}╔═══════════════════════════════╗${NC}\n"
    printf "${BLUE}║        ShellForge 🔥          ║${NC}\n"
    printf "${BLUE}║           Setup               ║${NC}\n"
    printf "${BLUE}╚═══════════════════════════════╝${NC}\n"
fi

echo ""

# Build ShellForge
printf "${YELLOW}Building ShellForge...${NC}\n"
if [[ -f "${SCRIPT_DIR}/build/build.sh" ]]; then
    chmod +x "${SCRIPT_DIR}/build/build.sh"
    "${SCRIPT_DIR}/build/build.sh"
    printf "${GREEN}✓ Build complete${NC}\n"
else
    printf "${RED}Error: build script not found${NC}\n"
    exit 1
fi

# Check if shellforge script was built
if [[ ! -f "${SHELLFORGE_SCRIPT}" ]]; then
    printf "${RED}Error: shellforge script was not built successfully${NC}\n"
    exit 1
fi

# Make the script executable
printf "${YELLOW}Making shellforge executable...${NC}\n"
chmod +x "${SHELLFORGE_SCRIPT}"

# Create bin directory if it doesn't exist
if [[ ! -d "${HOME}/bin" ]]; then
    printf "${YELLOW}Creating ${HOME}/bin directory...${NC}\n"
    mkdir -p "${HOME}/bin"
fi

# Copy to user's bin directory
printf "${YELLOW}Installing shellforge to ${HOME}/bin...${NC}\n"
cp "${SHELLFORGE_SCRIPT}" "${HOME}/bin/"

# Function to add shellforge config to a shell file
add_shellforge_config() {
    local shell_file="$1"
    local shell_name="$2"
    
    if [[ -f "${shell_file}" ]]; then
        # Check if shellforge is already configured
        if grep -q "BACKUP_DEST" "${shell_file}" || grep -q "shellforge" "${shell_file}"; then
            printf "  ${BLUE}ℹ${NC} ShellForge already configured in ${shell_name}\n"
        else
            printf "  ${GREEN}✓${NC} Adding ShellForge configuration to ${shell_name}\n"
            
            # Add configuration
            cat >> "${shell_file}" << 'EOF'

# ShellForge Configuration
# Set your backup destination (update this path!)
export BACKUP_DEST="${HOME}/Backups/shellforge"

# ShellForge aliases
alias sfs='shellforge save'
alias sfr='shellforge restore'
alias sfl='shellforge list'

# Quick save with note function
shellforge_save_with_note() {
    local note="${1:-Manual save}"
    echo "# Save note: $note - $(date)" >> "${HOME}/.shellforge_notes"
    shellforge save
}
alias sfsn='shellforge_save_with_note'

# Auto-backup reminder (checks if it's been more than 7 days)
if command -v shellforge &> /dev/null && [[ -n "${BACKUP_DEST}" ]]; then
    if [[ -L "${BACKUP_DEST}/${HOSTNAME}/latest" ]]; then
        last_backup=$(stat -f "%m" "${BACKUP_DEST}/${HOSTNAME}/latest" 2>/dev/null || stat -c "%Y" "${BACKUP_DEST}/${HOSTNAME}/latest" 2>/dev/null || echo 0)
        current_time=$(date +%s)
        days_since=$(( (current_time - last_backup) / 86400 ))
        
        if [[ $days_since -gt 7 ]]; then
            echo "⚠️  It's been $days_since days since your last ShellForge backup. Consider running: shellforge save"
        fi
    fi
fi
EOF
        fi
    fi
}

# Configure shell files
printf "\n${YELLOW}Configuring shell files...${NC}\n"

# Configure .zshrc
add_shellforge_config "${HOME}/.zshrc" ".zshrc"

# Configure .bashrc
add_shellforge_config "${HOME}/.bashrc" ".bashrc"

# Success message
printf "\n${GREEN}╔════════════════════════════════════════════════╗${NC}\n"
printf "${GREEN}║ ✓ ShellForge installation complete!        ║${NC}\n"
printf "${GREEN}╚════════════════════════════════════════════════╝${NC}\n"

printf "\n${YELLOW}Next steps:${NC}\n"
printf "1. ${BLUE}IMPORTANT:${NC} Edit your shell config file and update BACKUP_DEST\n"
printf "   to your preferred backup location\n"
printf "\n"
printf "2. Reload your shell configuration:\n"
printf "   ${GREEN}source ~/.zshrc${NC}  (for Zsh)\n"
printf "   ${GREEN}source ~/.bashrc${NC} (for Bash)\n"
printf "\n"
printf "3. Start using ShellForge:\n"
printf "   ${GREEN}shellforge save${NC}    - Save your current config\n"
printf "   ${GREEN}shellforge list${NC}    - List backups\n"
printf "   ${GREEN}shellforge restore${NC} - Restore a backup\n"
printf "\n"
printf "${YELLOW}Aliases available:${NC}\n"
printf "   ${GREEN}sfs${NC}  - Quick save\n"
printf "   ${GREEN}sfr${NC}  - Quick restore\n"
printf "   ${GREEN}sfl${NC}  - Quick list\n"
printf "   ${GREEN}sfsn${NC} - Save with a note\n"

echo ""
