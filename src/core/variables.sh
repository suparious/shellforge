#!/usr/bin/env bash
# ShellForge Global Variables
# This file contains all global variables and their initialization

# Version is set by build script, fallback to development version
VERSION="${SHELLFORGE_VERSION:-dev}"

# Note: Color definitions and display tool checks are now in ui-common.sh
# which is loaded before this file in the build process

# Default values from environment or defaults
MACHINE_NAME="${HOSTNAME:-$(hostname)}"
OPERATION=""
BACKUP_DEST="${BACKUP_DEST:-}"
VERBOSE="${SHELLFORGE_VERBOSE:-false}"
SMART_CONFIG="${SHELLFORGE_SMART_CONFIG:-true}"
MAX_DIR_SIZE_MB="${SHELLFORGE_MAX_DIR_SIZE_MB:-50}"
CONFIG_INCLUDE="${SHELLFORGE_CONFIG_INCLUDE:-}"
