#!/usr/bin/env bash
# ShellForge UI Common Library
# Shared UI elements for consistent look and feel across all scripts
# This file can be sourced by setup.sh, update.sh, and other standalone scripts

# Color definitions
setup_colors() {
    if [[ -t 1 ]]; then
        # Terminal supports colors
        RED='\033[0;31m'
        GREEN='\033[0;32m'
        YELLOW='\033[1;33m'
        BLUE='\033[0;34m'
        MAGENTA='\033[0;35m'
        CYAN='\033[0;36m'
        WHITE='\033[1;37m'
        BOLD='\033[1m'
        DIM='\033[2m'
        NC='\033[0m' # No Color
    else
        # No color support
        RED=''
        GREEN=''
        YELLOW=''
        BLUE=''
        MAGENTA=''
        CYAN=''
        WHITE=''
        BOLD=''
        DIM=''
        NC=''
    fi
}

# Check for display enhancement tools
check_display_tools() {
    HAS_FIGLET=$(command -v figlet &> /dev/null && echo true || echo false)
    HAS_LOLCAT=$(command -v lolcat &> /dev/null && echo true || echo false)
    HAS_COWSAY=$(command -v cowsay &> /dev/null && echo true || echo false)
}

# Initialize colors and check tools
setup_colors
check_display_tools

# Status icons
declare -A STATUS_ICONS=(
    [success]="✓"
    [error]="✗"
    [warning]="⚠"
    [info]="ℹ"
    [pending]="○"
    [working]="◐"
    [arrow]="→"
    [star]="★"
    [fire]="🔥"
    [package]="📦"
    [rocket]="🚀"
    [shield]="🛡️"
    [lightning]="⚡"
    [target]="🎯"
    [sparkles]="✨"
)

# Display the ShellForge banner
display_banner() {
    local subtitle="${1:-}"
    
    if [[ "${HAS_FIGLET}" == "true" ]] && [[ "${HAS_LOLCAT}" == "true" ]]; then
        figlet -f slant "ShellForge" | lolcat -f
        if [[ -n "$subtitle" ]]; then
            printf "${YELLOW}%s${NC}\n" "$subtitle" | lolcat -f
        fi
    elif [[ "${HAS_FIGLET}" == "true" ]]; then
        printf "${BLUE}"
        figlet -f slant "ShellForge"
        printf "${NC}"
        if [[ -n "$subtitle" ]]; then
            printf "${YELLOW}%s${NC}\n" "$subtitle"
        fi
    else
        printf "${BLUE}╔═══════════════════════════════╗${NC}\n"
        printf "${BLUE}║        ShellForge 🔥          ║${NC}\n"
        if [[ -n "$subtitle" ]]; then
            # Center the subtitle
            local padding=$(( (31 - ${#subtitle}) / 2 ))
            printf "${BLUE}║${YELLOW}%*s%s%*s${BLUE}║${NC}\n" $padding "" "$subtitle" $((31 - ${#subtitle} - padding)) ""
        fi
        printf "${BLUE}╚═══════════════════════════════╝${NC}\n"
    fi
    echo ""
}

# Print a status message with icon
print_status() {
    local type="$1"  # success, error, warning, info
    local message="$2"
    local icon="${STATUS_ICONS[$type]:-•}"
    
    case "$type" in
        success)
            printf "${GREEN}${icon}${NC} %s\n" "$message"
            ;;
        error)
            printf "${RED}${icon}${NC} %s\n" "$message"
            ;;
        warning)
            printf "${YELLOW}${icon}${NC} %s\n" "$message"
            ;;
        info)
            printf "${BLUE}${icon}${NC} %s\n" "$message"
            ;;
        *)
            printf "${icon} %s\n" "$message"
            ;;
    esac
}

# Print a section header with box drawing
print_section() {
    local title="$1"
    local color="${2:-$BLUE}"
    local width="${3:-60}"
    
    # Calculate padding for centered title
    local title_len=${#title}
    local padding=$(( (width - title_len - 2) / 2 ))
    
    printf "\n${color}┌"
    printf '─%.0s' $(seq 1 $width)
    printf "┐${NC}\n"
    
    printf "${color}│${NC} %*s${BOLD}%s${NC}%*s ${color}│${NC}\n" \
        $padding "" "$title" $((width - title_len - padding - 1)) ""
    
    printf "${color}└"
    printf '─%.0s' $(seq 1 $width)
    printf "┘${NC}\n\n"
}

# Print a simple box around content
print_box() {
    local content="$1"
    local color="${2:-$BLUE}"
    local width="${3:-60}"
    
    printf "${color}┌"
    printf '─%.0s' $(seq 1 $width)
    printf "┐${NC}\n"
    
    # Handle multi-line content
    while IFS= read -r line; do
        printf "${color}│${NC} %-*s ${color}│${NC}\n" $((width - 1)) "$line"
    done <<< "$content"
    
    printf "${color}└"
    printf '─%.0s' $(seq 1 $width)
    printf "┘${NC}\n"
}

# Animated progress indicator
show_progress() {
    local message="$1"
    local pid="$2"
    local delay=0.1
    local spinstr='◐◓◑◒'
    
    printf "${YELLOW}%s${NC} " "$message"
    
    while kill -0 "$pid" 2>/dev/null; do
        local temp=${spinstr#?}
        printf "${YELLOW}%c${NC}" "$spinstr"
        spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b"
    done
    
    # Clear the spinner
    printf " \b"
}

# Print a progress bar
print_progress_bar() {
    local current="$1"
    local total="$2"
    local width="${3:-30}"
    local label="${4:-Progress}"
    
    local percentage=$((current * 100 / total))
    local filled=$((current * width / total))
    local empty=$((width - filled))
    
    printf "\r${BLUE}%s [${NC}" "$label"
    printf "${GREEN}%${filled}s" | tr ' ' '█'
    printf "${DIM}%${empty}s${NC}" | tr ' ' '░'
    printf "${BLUE}] %3d%%${NC}" "$percentage"
    
    if [[ $current -eq $total ]]; then
        printf "\n"
    fi
}

# Show a step in a process
print_step() {
    local step_num="$1"
    local total_steps="$2"
    local message="$3"
    
    printf "${CYAN}[%d/%d]${NC} ${STATUS_ICONS[arrow]} %s\n" "$step_num" "$total_steps" "$message"
}

# Print key-value pairs in a nice format
print_kv() {
    local key="$1"
    local value="$2"
    local key_color="${3:-$BLUE}"
    local value_color="${4:-$GREEN}"
    
    printf "${key_color}%-20s${NC} ${DIM}:${NC} ${value_color}%s${NC}\n" "$key" "$value"
}

# Show a success message with optional animation
show_success() {
    local message="$1"
    local animate="${2:-true}"
    
    if [[ "$animate" == "true" ]] && [[ "${HAS_COWSAY}" == "true" ]]; then
        if [[ "${HAS_LOLCAT}" == "true" ]]; then
            echo "$message" | cowsay -f small | lolcat -f
        else
            echo "$message" | cowsay -f small
        fi
    else
        print_status "success" "$message"
    fi
}

# Show an error message
show_error() {
    local message="$1"
    print_status "error" "$message"
}

# Print a list of items with bullets
print_list() {
    local color="${1:-$BLUE}"
    shift
    local items=("$@")
    
    for item in "${items[@]}"; do
        printf "  ${color}•${NC} %s\n" "$item"
    done
}

# Create a simple menu
print_menu() {
    local title="$1"
    shift
    local options=("$@")
    
    print_section "$title" "$CYAN" 40
    
    local i=1
    for option in "${options[@]}"; do
        printf "  ${CYAN}%2d)${NC} %s\n" $i "$option"
        ((i++))
    done
    echo ""
}

# Print installation complete message
print_complete() {
    local title="${1:-Installation Complete!}"
    
    printf "\n${GREEN}╔════════════════════════════════════════════════╗${NC}\n"
    printf "${GREEN}║ ${STATUS_ICONS[success]} %-44s ║${NC}\n" "$title"
    printf "${GREEN}╚════════════════════════════════════════════════╝${NC}\n\n"
}

# Countdown timer
show_countdown() {
    local seconds="$1"
    local message="${2:-Continuing in}"
    
    for ((i=seconds; i>0; i--)); do
        printf "\r${YELLOW}%s %d...${NC}" "$message" "$i"
        sleep 1
    done
    printf "\r%*s\r" $((${#message} + 6)) ""  # Clear the line
}

# Check if a command exists and print status
check_command() {
    local cmd="$1"
    local required="${2:-false}"
    
    if command -v "$cmd" &> /dev/null; then
        print_status "success" "$cmd found"
        return 0
    else
        if [[ "$required" == "true" ]]; then
            print_status "error" "$cmd not found (required)"
            return 1
        else
            print_status "info" "$cmd not found (optional)"
            return 0
        fi
    fi
}

# Truncate long paths for display
truncate_path() {
    local path="$1"
    local max_len="${2:-40}"
    
    if [[ ${#path} -le $max_len ]]; then
        echo "$path"
    else
        # Show first 15 and last 20 characters with ... in middle
        echo "${path:0:15}...${path: -20}"
    fi
}

# Print a separator line
print_separator() {
    local char="${1:--}"
    local color="${2:-$DIM}"
    local width="${3:-60}"
    
    printf "${color}"
    printf '%*s' "$width" | tr ' ' "$char"
    printf "${NC}\n"
}

# Note: When sourced directly by setup.sh or update.sh, functions are available in the same shell.
# When included in the ShellForge build, they become part of the main script.
