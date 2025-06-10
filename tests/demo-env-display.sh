#!/usr/bin/env bash
# Standalone demo of the elaborate environment variable display

# Source the display functions (simplified for demo)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# Mock version
VERSION="1.2.0"

# Demo different states
echo -e "${BLUE}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     ShellForge Dynamic Environment Variable Display       ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""

# Simulate different scenarios
scenarios=(
    "nothing_set|No environment variables configured"
    "backup_dest_only|Only BACKUP_DEST set (directory doesn't exist)"
    "backup_dest_exists|BACKUP_DEST exists and is writable"
    "fully_configured|All variables configured"
)

for scenario in "${scenarios[@]}"; do
    IFS='|' read -r scenario_id scenario_desc <<< "$scenario"
    
    echo -e "\n${YELLOW}━━━ Scenario: ${scenario_desc} ━━━${NC}\n"
    
    case $scenario_id in
        "nothing_set")
            unset BACKUP_DEST
            unset SHELLFORGE_SMART_CONFIG
            unset SHELLFORGE_MAX_DIR_SIZE_MB
            ;;
        "backup_dest_only")
            export BACKUP_DEST="$HOME/Backups/shellforge"
            unset SHELLFORGE_SMART_CONFIG
            unset SHELLFORGE_MAX_DIR_SIZE_MB
            ;;
        "backup_dest_exists")
            export BACKUP_DEST="/tmp"
            export SHELLFORGE_SMART_CONFIG="true"
            unset SHELLFORGE_MAX_DIR_SIZE_MB
            ;;
        "fully_configured")
            export BACKUP_DEST="/tmp"
            export SHELLFORGE_SMART_CONFIG="false"
            export SHELLFORGE_MAX_DIR_SIZE_MB="100"
            export SHELLFORGE_CONFIG_INCLUDE="Code,discord"
            export SHELLFORGE_VERBOSE="true"
            ;;
    esac
    
    # Show what the display would look like
    echo "    ${BLUE}┌────────────────────────────────┬───────────────────────────┬────────────────────────────────┐${NC}"
    echo "    ${BLUE}│${NC} Variable                       ${BLUE}│${NC} Description               ${BLUE}│${NC} Status                         ${BLUE}│${NC}"
    echo "    ${BLUE}├────────────────────────────────┼───────────────────────────┼────────────────────────────────┤${NC}"
    
    # BACKUP_DEST
    if [[ -n "${BACKUP_DEST:-}" ]]; then
        if [[ -d "$BACKUP_DEST" ]]; then
            echo -e "    ${GREEN}✓${NC} BACKUP_DEST                   ${BLUE}│${NC} Backup destination        ${BLUE}│${NC} ${BACKUP_DEST} ${GREEN}[2.5G free]${NC}"
        else
            echo -e "    ${YELLOW}!${NC} BACKUP_DEST                   ${BLUE}│${NC} Backup destination        ${BLUE}│${NC} will be created ${BLUE}[10G available]${NC}"
        fi
    else
        echo -e "    ${RED}✗${NC} BACKUP_DEST                   ${BLUE}│${NC} Backup destination        ${BLUE}│${NC} ${RED}Not set!${NC} ${RED}[REQUIRED]${NC}"
    fi
    
    # Add more variables...
    echo "    ${BLUE}└────────────────────────────────┴───────────────────────────┴────────────────────────────────┘${NC}"
    
    # Show readiness meter
    local score=0
    [[ -n "${BACKUP_DEST:-}" ]] && ((score++))
    [[ -d "${BACKUP_DEST:-}" ]] && ((score++))
    
    echo ""
    echo "    ${BLUE}┌─ Configuration Status ──────────────────────────────┐${NC}"
    echo -n "    ${BLUE}│${NC} Readiness: ["
    
    # Draw meter
    for ((i=1; i<=score; i++)); do echo -n "${GREEN}█${NC}"; done
    for ((i=score; i<5; i++)); do echo -n "${BLUE}░${NC}"; done
    
    echo "] $score/5        ${BLUE}│${NC}"
    echo "    ${BLUE}└───────────────────────────────────────────────────────┘${NC}"
done
