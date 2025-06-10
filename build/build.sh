#!/usr/bin/env bash
#
# ShellForge Build Script
# Combines modular source files into a single executable shell script
#

set -euo pipefail

# Build configuration
readonly BUILD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$(dirname "${BUILD_DIR}")"
readonly SRC_DIR="${PROJECT_ROOT}/src"
readonly DIST_DIR="${PROJECT_ROOT}/dist"
readonly OUTPUT_FILE="${PROJECT_ROOT}/shellforge"
readonly VERSION_FILE="${PROJECT_ROOT}/VERSION"
# BUILD_MODE will be set based on the command

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

# Get version
if [[ -f "${VERSION_FILE}" ]]; then
    VERSION=$(cat "${VERSION_FILE}")
else
    VERSION="1.2.0"
fi

# Build timestamp
readonly BUILD_TIME=$(date +"%Y-%m-%d %H:%M:%S")
readonly BUILD_HASH=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")

# Print with color
print_step() {
    printf "${BLUE}==>${NC} %s\n" "$1"
}

print_success() {
    printf "${GREEN}✓${NC} %s\n" "$1"
}

print_error() {
    printf "${RED}✗${NC} %s\n" "$1"
    exit 1
}

print_warning() {
    printf "${YELLOW}⚠${NC} %s\n" "$1"
}

# Validate shell syntax
validate_syntax() {
    local file="$1"
    if bash -n "$file" 2>/dev/null; then
        return 0
    else
        print_error "Syntax error in $file"
        bash -n "$file"
        return 1
    fi
}

# Remove shebang from file content (except for header)
strip_shebang() {
    sed '/^#!/d'
}

# Add source file comment
add_source_comment() {
    local file="$1"
    echo ""
    echo "# --- Source: ${file#$SRC_DIR/} ---"
    echo ""
}

# Process build mode specific features
process_build_mode() {
    case "$BUILD_MODE" in
        debug)
            # Keep all comments and add debug info
            cat
            ;;
        minimal)
            # Remove comments and empty lines (except shebang)
            sed -e '/^[[:space:]]*#[^!]/d' -e '/^[[:space:]]*$/d'
            ;;
        release)
            # Remove only development comments (keep user-facing ones)
            sed -e '/^[[:space:]]*# DEBUG:/d' -e '/^[[:space:]]*# TODO:/d' -e '/^[[:space:]]*# FIXME:/d'
            ;;
        *)
            cat
            ;;
    esac
}

# Build the script
build() {
    print_step "Building ShellForge v${VERSION} (${BUILD_MODE} mode)"
    
    # Create dist directory
    mkdir -p "${DIST_DIR}"
    
    # Start with empty output file
    : > "${OUTPUT_FILE}"
    
    # Define source file order
    local source_files=(
        "header.sh"
        "core/constants.sh"
        "core/variables.sh"
        "core/utils.sh"
        "lib/ui-common.sh"
        "core/display.sh"
        "lib/file-operations.sh"
        "lib/metadata.sh"
        "lib/backup-filters.sh"
        "modules/backup.sh"
        "modules/restore.sh"
        "modules/list.sh"
        "modules/smart-config.sh"
        "main.sh"
    )
    
    # Add header with build info
    cat > "${OUTPUT_FILE}" << EOF
#!/usr/bin/env bash
#
# ShellForge - Shell Configuration Backup & Restore Tool
# Version: ${VERSION}
# Build: ${BUILD_HASH} (${BUILD_TIME})
# Mode: ${BUILD_MODE}
#
# This file is auto-generated. Do not edit directly.
# Edit source files in src/ and run build/build.sh
#

set -euo pipefail

# Build Information
readonly SHELLFORGE_VERSION="${VERSION}"
readonly SHELLFORGE_BUILD="${BUILD_HASH}"
readonly SHELLFORGE_BUILD_TIME="${BUILD_TIME}"
readonly SHELLFORGE_BUILD_MODE="${BUILD_MODE}"
EOF
    
    # Process each source file
    for src_file in "${source_files[@]}"; do
        local full_path="${SRC_DIR}/${src_file}"
        
        if [[ ! -f "$full_path" ]]; then
            print_warning "Source file not found: ${src_file} (skipping)"
            continue
        fi
        
        print_step "Processing ${src_file}"
        
        # Validate syntax
        if ! validate_syntax "$full_path"; then
            exit 1
        fi
        
        # Add source file marker (in debug mode)
        if [[ "$BUILD_MODE" == "debug" ]]; then
            add_source_comment "$src_file" >> "${OUTPUT_FILE}"
        fi
        
        # Process and append file
        strip_shebang < "$full_path" | process_build_mode >> "${OUTPUT_FILE}"
        
        print_success "Added ${src_file}"
    done
    
    # Make executable
    chmod +x "${OUTPUT_FILE}"
    
    # Validate final script
    print_step "Validating final script"
    if validate_syntax "${OUTPUT_FILE}"; then
        print_success "Syntax validation passed"
    else
        print_error "Final script has syntax errors"
        exit 1
    fi
    
    # Create versioned copy in dist
    local dist_file="${DIST_DIR}/shellforge-${VERSION}-${BUILD_MODE}"
    cp "${OUTPUT_FILE}" "${dist_file}"
    
    # Stats
    local line_count=$(wc -l < "${OUTPUT_FILE}")
    local size=$(du -h "${OUTPUT_FILE}" | cut -f1)
    
    echo ""
    print_success "Build complete!"
    echo "  Output: ${OUTPUT_FILE}"
    echo "  Size: ${size} (${line_count} lines)"
    echo "  Mode: ${BUILD_MODE}"
    echo ""
    
    # Show usage in debug mode
    if [[ "$BUILD_MODE" == "debug" ]]; then
        echo "Debug build includes:"
        echo "  - Source file markers"
        echo "  - All comments"
        echo "  - Development notes"
    fi
}

# Clean build artifacts
clean() {
    print_step "Cleaning build artifacts"
    rm -rf "${DIST_DIR}"
    rm -f "${OUTPUT_FILE}"
    print_success "Clean complete"
}

# Show usage
usage() {
    cat << EOF
ShellForge Build Script

Usage:
    ${0##*/} [release|debug|minimal]    Build ShellForge
    ${0##*/} clean                      Clean build artifacts
    ${0##*/} help                       Show this help

Build modes:
    release  - Standard build (default)
    debug    - Include source markers and all comments
    minimal  - Strip comments for smaller size

Examples:
    ${0##*/}                # Build release version
    ${0##*/} debug          # Build with debug info
    ${0##*/} minimal        # Build minimal version
EOF
}

# Main
case "${1:-}" in
    release|debug|minimal)
        BUILD_MODE="$1"
        build
        ;;
    clean)
        clean
        ;;
    help|--help|-h)
        usage
        ;;
    "")
        # No argument provided, default to release build
        BUILD_MODE="release"
        build
        ;;
    *)
        # Unknown argument
        echo "Unknown command: $1"
        usage
        exit 1
        ;;
esac
