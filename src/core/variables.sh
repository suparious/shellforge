#!/usr/bin/env bash
# ShellForge Global Variables
# This file contains all global variables and their initialization

# Version is set by build script, fallback to development version
VERSION="${SHELLFORGE_VERSION:-dev}"

# Color codes - defined once
if [[ -t 1 ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    MAGENTA='\033[0;35m'
    NC='\033[0m'
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    MAGENTA=''
    NC=''
fi

# Check for fun display tools
HAS_FIGLET=$(command -v figlet &> /dev/null && echo true || echo false)
HAS_LOLCAT=$(command -v lolcat &> /dev/null && echo true || echo false)
HAS_COWSAY=$(command -v cowsay &> /dev/null && echo true || echo false)

# Default values from environment or defaults
MACHINE_NAME="${HOSTNAME:-$(hostname)}"
OPERATION=""
BACKUP_DEST="${BACKUP_DEST:-}"
VERBOSE="${SHELLFORGE_VERBOSE:-false}"
SMART_CONFIG="${SHELLFORGE_SMART_CONFIG:-true}"
MAX_DIR_SIZE_MB="${SHELLFORGE_MAX_DIR_SIZE_MB:-50}"
CONFIG_INCLUDE="${SHELLFORGE_CONFIG_INCLUDE:-}"
