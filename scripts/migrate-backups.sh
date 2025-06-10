#!/usr/bin/env bash
#
# migrate-backups.sh - Add ShellForge markers to existing backups
# This script helps migrate existing backups to the new marker system
#

set -euo pipefail

# Colors
readonly GREEN='\033[0;32m'
readonly RED='\033[0;31m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

# Check if BACKUP_DEST is set
if [[ -z "${BACKUP_DEST:-}" ]]; then
    echo -e "${RED}Error: BACKUP_DEST is not set${NC}"
    echo "Please set it to your backup directory:"
    echo "  export BACKUP_DEST=/path/to/your/backups"
    exit 1
fi

echo -e "${BLUE}ShellForge Backup Migration Tool${NC}"
echo "=================================="
echo
echo "This tool will add marker files to your existing ShellForge backups"
echo "so they can be properly identified by the enhanced list command."
echo
echo -e "Backup directory: ${GREEN}${BACKUP_DEST}${NC}"
echo

read -p "Continue? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Migration cancelled."
    exit 0
fi

echo -e "\n${YELLOW}Scanning for backups...${NC}"

# Counter for migrations
migrated=0
skipped=0

# Process each machine directory
for machine_dir in "${BACKUP_DEST}"/*; do
    if [[ -d "$machine_dir" ]]; then
        machine=$(basename "$machine_dir")
        echo -e "\n${BLUE}Processing machine: ${machine}${NC}"
        
        # Process each backup
        for backup_dir in "$machine_dir"/*; do
            if [[ -d "$backup_dir" ]] && [[ "$(basename "$backup_dir")" != "latest" ]]; then
                timestamp_dir=$(basename "$backup_dir")
                
                # Check if marker already exists
                if [[ -f "$backup_dir/.shellforge" ]]; then
                    echo "  ${timestamp_dir} - already has marker (skipping)"
                    ((skipped++))
                    continue
                fi
                
                # Check if it looks like a ShellForge backup
                # Look for home directory (main indicator of a shellforge backup)
                if [[ -d "$backup_dir/home" ]] || [[ -d "$backup_dir/metadata" ]] || [[ -f "$backup_dir/metadata/backup_info.txt" ]]; then
                    # Create marker
                    echo "  ${timestamp_dir} - adding marker"
                    
                    # Try to extract timestamp from directory name
                    if [[ "$timestamp_dir" =~ ^([0-9]{8})_([0-9]{6})$ ]]; then
                        # Convert to timestamp
                        date_part="${BASH_REMATCH[1]}"
                        time_part="${BASH_REMATCH[2]}"
                        
                        # Create a rough timestamp (not exact, but close enough)
                        year="${date_part:0:4}"
                        month="${date_part:4:2}"
                        day="${date_part:6:2}"
                        hour="${time_part:0:2}"
                        min="${time_part:2:2}"
                        sec="${time_part:4:2}"
                        
                        # Use date command to convert to timestamp if possible
                        if command -v date &> /dev/null; then
                            marker_timestamp=$(date -d "${year}-${month}-${day} ${hour}:${min}:${sec}" +%s 2>/dev/null || date +%s)
                        else
                            marker_timestamp=$(date +%s)
                        fi
                    else
                        # Use current timestamp
                        marker_timestamp=$(date +%s)
                    fi
                    
                    # Create marker file
                    cat > "$backup_dir/.shellforge" << EOF
# ShellForge Backup Marker
# Added by migration tool
VERSION=migrated
TIMESTAMP=${marker_timestamp}
DATE=$(date -R)
TOOL=ShellForge
MACHINE=${machine}
USER=${USER}
MIGRATED=true
EOF
                    
                    ((migrated++))
                else
                    echo "  ${timestamp_dir} - doesn't look like a ShellForge backup (skipping)"
                    ((skipped++))
                fi
            fi
        done
    fi
done

echo -e "\n${GREEN}Migration complete!${NC}"
echo "  Migrated: ${migrated} backups"
echo "  Skipped:  ${skipped} directories"
echo
echo "You can now use 'shellforge list' to see your backups with the new UI!"
