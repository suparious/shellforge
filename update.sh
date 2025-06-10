#!/bin/bash
# Quick update/reinstall script for ShellForge
# Enhanced with beautiful TUI elements

set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SHELLFORGE="${SCRIPT_DIR}/shellforge"

# Source the UI library
source "${SCRIPT_DIR}/src/lib/ui-common.sh"

# Display banner
display_banner "Update & Reinstall"

# Show current version if available
print_section "Version Information" "$CYAN" 50

if [[ -f "${SCRIPT_DIR}/VERSION" ]]; then
    current_version=$(cat "${SCRIPT_DIR}/VERSION")
    print_kv "Current Version" "$current_version" "$BLUE" "$YELLOW"
fi

if command -v shellforge &> /dev/null; then
    installed_version=$(shellforge version 2>/dev/null | grep -E "^ShellForge" | awk '{print $2}' || echo "unknown")
    print_kv "Installed Version" "$installed_version" "$BLUE" "$MAGENTA"
else
    print_status "info" "ShellForge not found in PATH"
fi

# Check git status if in a git repo
if [[ -d "${SCRIPT_DIR}/.git" ]]; then
    print_section "Repository Status" "$MAGENTA" 50
    
    # Check for uncommitted changes
    if git -C "${SCRIPT_DIR}" diff-index --quiet HEAD -- 2>/dev/null; then
        print_status "success" "No uncommitted changes"
    else
        print_status "warning" "Uncommitted changes detected"
    fi
    
    # Show current branch
    current_branch=$(git -C "${SCRIPT_DIR}" branch --show-current 2>/dev/null || echo "unknown")
    print_kv "Current Branch" "$current_branch"
    
    # Check if we're behind remote
    if git -C "${SCRIPT_DIR}" fetch --dry-run 2>&1 | grep -q "remote"; then
        print_status "info" "Updates available from remote"
    fi
fi

# Build process
print_section "Building ShellForge" "$YELLOW" 50

if [[ -f "${SCRIPT_DIR}/build/build.sh" ]]; then
    # Clean first
    print_step 1 3 "Cleaning previous build"
    rm -f "${SHELLFORGE}" 2>/dev/null || true
    print_status "success" "Clean complete"
    
    # Build
    print_step 2 3 "Building latest version"
    
    # Show build progress
    build_start=$(date +%s)
    (
        "${SCRIPT_DIR}/build/build.sh" > /dev/null 2>&1
    ) &
    
    build_pid=$!
    show_progress "Compiling modules" $build_pid
    wait $build_pid
    build_result=$?
    build_end=$(date +%s)
    build_time=$((build_end - build_start))
    
    if [[ $build_result -eq 0 ]]; then
        print_status "success" "Build complete (${build_time}s)"
        
        # Show build stats
        if [[ -f "${SHELLFORGE}" ]]; then
            size=$(du -h "${SHELLFORGE}" | cut -f1)
            lines=$(wc -l < "${SHELLFORGE}")
            print_kv "Output Size" "$size"
            print_kv "Total Lines" "$lines"
        fi
    else
        show_error "Build failed"
        exit 1
    fi
else
    show_error "Build script not found"
    exit 1
fi

# Installation
print_step 3 3 "Installing to ~/bin"

# Create ~/bin if needed
mkdir -p "${HOME}/bin"

# Backup existing version if present
if [[ -f "${HOME}/bin/shellforge" ]]; then
    backup_name="${HOME}/bin/shellforge.backup.$(date +%Y%m%d_%H%M%S)"
    cp "${HOME}/bin/shellforge" "$backup_name"
    print_status "info" "Backed up existing version"
fi

# Install new version
cp "${SHELLFORGE}" "${HOME}/bin/shellforge"
chmod +x "${HOME}/bin/shellforge"
print_status "success" "Installation complete"

# Verify installation
print_section "Verification" "$GREEN" 50

if command -v shellforge &> /dev/null; then
    # Get new version info
    new_version_info=$(shellforge version 2>/dev/null || echo "Version command failed")
    
    # Display in a nice box
    print_box "$new_version_info" "$GREEN" 58
    
    # Test help command
    print_status "working" "Testing help command..."
    if shellforge help &> /dev/null; then
        print_status "success" "Help command works"
    else
        print_status "warning" "Help command returned non-zero exit code"
    fi
else
    print_status "warning" "ShellForge not found in PATH"
    print_status "info" "You may need to add ~/bin to your PATH"
fi

# Show what's new (if we can detect changes)
if [[ -n "${current_version:-}" ]] && [[ -n "${installed_version:-}" ]] && [[ "$current_version" != "$installed_version" ]]; then
    print_section "What's New" "$BLUE" 50
    
    if [[ -f "${SCRIPT_DIR}/CHANGELOG.md" ]]; then
        # Extract recent changes
        recent_changes=$(awk '/^## \[/{if(p)exit;p=1;next} p' "${SCRIPT_DIR}/CHANGELOG.md" | head -20)
        if [[ -n "$recent_changes" ]]; then
            echo "$recent_changes" | while IFS= read -r line; do
                if [[ "$line" =~ ^### ]]; then
                    printf "${YELLOW}%s${NC}\n" "$line"
                elif [[ "$line" =~ ^- ]]; then
                    printf "  ${GREEN}•${NC} %s\n" "${line:2}"
                else
                    echo "$line"
                fi
            done
        fi
    else
        print_status "info" "No changelog found"
    fi
fi

# Quick tips
print_section "Quick Commands" "$CYAN" 50

# Create a nice command reference
declare -a commands=(
    "shellforge save:Save current configuration"
    "shellforge restore:Restore from backup"
    "shellforge list:List all backups"
    "shellforge help:Show detailed help"
)

for cmd_desc in "${commands[@]}"; do
    IFS=':' read -r cmd desc <<< "$cmd_desc"
    printf "  ${CYAN}%-20s${NC} ${DIM}│${NC} %s\n" "$cmd" "$desc"
done

# Update complete
print_complete "Update Complete!"

# Fun animation if tools are available
if [[ "${HAS_FIGLET}" == "true" ]] && [[ "${HAS_LOLCAT}" == "true" ]]; then
    echo "Ready to forge!" | figlet -f small | lolcat -f
elif [[ "${HAS_COWSAY}" == "true" ]]; then
    echo "Your configs are safe with ShellForge! 🔥" | cowsay -f small
else
    print_separator "═" "$GREEN" 60
    printf "\n%*s${GREEN}${STATUS_ICONS[fire]} Your configs are safe with ShellForge! ${STATUS_ICONS[fire]}${NC}\n\n" 10 ""
fi
