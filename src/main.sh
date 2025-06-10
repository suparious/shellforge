#!/usr/bin/env bash
# ShellForge Main Entry Point
# Handles command line parsing and dispatches to appropriate modules

# Main script logic
main() {
    # Parse command line arguments
    local cmd="${1:-}"
    shift || true
    
    # Check for flags
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --verbose|-v)
                VERBOSE="true"
                shift
                ;;
            --no-graphics)
                NO_GRAPHICS="true"
                shift
                ;;
            *)
                if [[ -z "${MACHINE_NAME_OVERRIDE:-}" ]]; then
                    MACHINE_NAME_OVERRIDE="$1"
                    MACHINE_NAME="$1"
                fi
                shift
                ;;
        esac
    done
    
    case "${cmd}" in
        save)
            OPERATION="save"
            check_backup_dest
            save_configs
            ;;
        restore)
            OPERATION="restore"
            check_backup_dest
            restore_configs
            ;;
        list)
            check_backup_dest
            list_backups
            ;;
        help|--help|-h)
            usage
            exit 0
            ;;
        version|--version|-V)
            echo "ShellForge ${VERSION}"
            if [[ -n "${SHELLFORGE_BUILD:-}" ]]; then
                echo "Build: ${SHELLFORGE_BUILD} (${SHELLFORGE_BUILD_TIME})"
            fi
            exit 0
            ;;
        *)
            usage
            exit 1
            ;;
    esac
}

# Run main function only if not sourced
if [[ "${SHELLFORGE_SOURCED:-false}" != "true" ]]; then
    main "$@"
fi
