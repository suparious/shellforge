#!/usr/bin/env bash
# ShellForge List Module
# Functions for listing available backups

# List available backups with size information
list_backups() {
    display_banner
    printf "${BLUE}=== Available Backups ===${NC}\n\n"

    if [[ ! -d "${BACKUP_DEST}" ]]; then
        printf "${YELLOW}No backups found (BACKUP_DEST doesn't exist)${NC}\n"
        return
    fi

    local found=false
    for machine_dir in "${BACKUP_DEST}"/*; do
        if [[ -d "${machine_dir}" ]]; then
            local machine=$(basename "${machine_dir}")
            printf "${GREEN}${machine}:${NC}\n"

            # List backup timestamps
            for backup in "${machine_dir}"/*; do
                if [[ -d "${backup}" ]] && [[ "$(basename "${backup}")" != "latest" ]]; then
                    local timestamp=$(basename "${backup}")
                    local size=$(du -sh "${backup}" 2>/dev/null | cut -f1)
                    printf "  %s (%s)\n" "${timestamp}" "${size}"
                    found=true
                fi
            done

            # Show latest link if exists
            if [[ -L "${machine_dir}/latest" ]]; then
                local latest_target=$(basename "$(readlink "${machine_dir}/latest")")
                printf "  ${BLUE}latest -> ${latest_target}${NC}\n"
            fi
            echo
        fi
    done

    if [[ "${found}" == "false" ]]; then
        printf "${YELLOW}No backups found${NC}\n"
    fi
}
