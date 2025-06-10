#!/usr/bin/env bash
# Setup script for ShellForge
# Enhanced with beautiful TUI elements

set -euo pipefail

# Script location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SHELLFORGE_SCRIPT="${SCRIPT_DIR}/shellforge"

# Source the UI library
source "${SCRIPT_DIR}/src/lib/ui-common.sh"

# Display banner with subtitle
display_banner "Setup & Installation"

# Show system info
print_section "System Information" "$CYAN" 50
print_kv "Date" "$(date '+%Y-%m-%d %H:%M:%S')"
print_kv "User" "${USER:-unknown}"
print_kv "Shell" "${SHELL:-/bin/bash}"
print_kv "Hostname" "${HOSTNAME:-$(hostname)}"
print_kv "Platform" "$(uname -s)"

# Check for optional enhancements
print_section "Checking Optional Enhancements" "$BLUE" 50

declare -a optional_tools=(
    "figlet:Banner display"
    "lolcat:Colorful output"
    "cowsay:Fun messages"
    "rsync:Efficient copying"
)

for tool_desc in "${optional_tools[@]}"; do
    IFS=':' read -r tool description <<< "$tool_desc"
    if command -v "$tool" &> /dev/null; then
        print_status "success" "$description ($tool)"
    else
        print_status "info" "$description ($tool) - not found"
    fi
done

# Build ShellForge
print_section "Building ShellForge" "$YELLOW" 50

if [[ -f "${SCRIPT_DIR}/build/build.sh" ]]; then
    print_step 1 4 "Running build script"
    
    # Run build in background and show progress
    (
        chmod +x "${SCRIPT_DIR}/build/build.sh"
        "${SCRIPT_DIR}/build/build.sh" > /dev/null 2>&1
    ) &
    
    build_pid=$!
    show_progress "Building ShellForge" $build_pid
    wait $build_pid
    
    if [[ $? -eq 0 ]]; then
        print_status "success" "Build complete"
    else
        show_error "Build failed"
        exit 1
    fi
else
    show_error "Build script not found"
    exit 1
fi

# Check if shellforge script was built
if [[ ! -f "${SHELLFORGE_SCRIPT}" ]]; then
    show_error "ShellForge script was not built successfully"
    exit 1
fi

# Make the script executable
print_step 2 4 "Setting permissions"
chmod +x "${SHELLFORGE_SCRIPT}"
print_status "success" "ShellForge is now executable"

# Create bin directory if it doesn't exist
print_step 3 4 "Preparing installation directory"
if [[ ! -d "${HOME}/bin" ]]; then
    mkdir -p "${HOME}/bin"
    print_status "success" "Created ${HOME}/bin directory"
else
    print_status "info" "${HOME}/bin already exists"
fi

# Copy to user's bin directory
print_step 4 4 "Installing ShellForge"
cp "${SHELLFORGE_SCRIPT}" "${HOME}/bin/"
print_status "success" "Installed to ${HOME}/bin/shellforge"

# Configure shell files
print_section "Configuring Shell Integration" "$MAGENTA" 50

# Function to add shellforge config to a shell file
add_shellforge_config() {
    local shell_file="$1"
    local shell_name="$2"
    
    if [[ -f "${shell_file}" ]]; then
        # Check if shellforge is already configured
        if grep -q "BACKUP_DEST" "${shell_file}" || grep -q "shellforge" "${shell_file}"; then
            print_status "info" "ShellForge already configured in ${shell_name}"
        else
            print_status "working" "Adding ShellForge configuration to ${shell_name}"
            
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
            print_status "success" "Added configuration to ${shell_name}"
        fi
    fi
}

# Configure shells
shells_configured=0
if [[ -f "${HOME}/.zshrc" ]]; then
    add_shellforge_config "${HOME}/.zshrc" ".zshrc"
    ((shells_configured++))
fi

if [[ -f "${HOME}/.bashrc" ]]; then
    add_shellforge_config "${HOME}/.bashrc" ".bashrc"
    ((shells_configured++))
fi

if [[ $shells_configured -eq 0 ]]; then
    print_status "warning" "No shell configuration files found"
    print_status "info" "You'll need to manually add ShellForge to your shell config"
fi

# Installation complete
print_complete "ShellForge Installation Complete!"

# Next steps
print_section "Next Steps" "$GREEN" 50

print_box "${YELLOW}IMPORTANT:${NC} Edit your shell config file and update BACKUP_DEST
to your preferred backup location" "$YELLOW" 58

echo ""
print_status "info" "Reload your shell configuration:"
print_list "$GREEN" \
    "source ~/.zshrc  (for Zsh)" \
    "source ~/.bashrc (for Bash)"

echo ""
print_status "info" "Start using ShellForge:"
print_list "$CYAN" \
    "shellforge save    - Save your current config" \
    "shellforge list    - List backups" \
    "shellforge restore - Restore a backup"

echo ""
print_status "info" "Available aliases:"
printf "  ${GREEN}%-8s${NC} - %s\n" "sfs" "Quick save"
printf "  ${GREEN}%-8s${NC} - %s\n" "sfr" "Quick restore"
printf "  ${GREEN}%-8s${NC} - %s\n" "sfl" "Quick list"
printf "  ${GREEN}%-8s${NC} - %s\n" "sfsn" "Save with a note"

# Fun closing message
echo ""
print_separator "═" "$BLUE" 60
if [[ "${HAS_COWSAY}" == "true" ]] && [[ "${HAS_LOLCAT}" == "true" ]]; then
    echo "Happy forging! 🔥" | cowsay -f small | lolcat -f
elif [[ "${HAS_COWSAY}" == "true" ]]; then
    echo "Happy forging! 🔥" | cowsay -f small
else
    printf "\n${BLUE}%*s${STATUS_ICONS[fire]} Happy forging! ${STATUS_ICONS[fire]}%*s${NC}\n\n" 20 "" 20 ""
fi
