# ShellForge Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.5.0] - 2025-06-09

### Added
- Enhanced `list` command with beautiful TUI elements:
  - Box-drawing characters for visual structure
  - Color-coded backup age indicators
  - Machine-specific icons (home icon for current machine)
  - Detailed backup statistics per machine
  - Global summary section with totals
  - Quick command reference
- ShellForge marker file (.shellforge) to identify valid backups
- Backup statistics file (.stats) with file counts and sizes
- Global metadata tracking in BACKUP_DEST/.shellforge-meta
- Human-readable time formatting ("2 hours ago", "3 days ago")
- Human-readable size formatting (KB, MB, GB)
- Enhanced metadata functions:
  - `create_marker_file()` - Creates backup identification marker
  - `is_shellforge_backup()` - Validates ShellForge backups
  - `create_backup_stats()` - Tracks backup statistics
  - `format_timestamp()` - Converts timestamps to human-readable format
  - `format_bytes()` - Converts bytes to human-readable sizes
  - `update_global_metadata()` - Maintains global backup registry

### Changed
- `list` command now only shows ShellForge backups (not all directories)
- Backup destination is displayed prominently at the top
- Each machine shows backup count, total size, and latest backup age
- Color coding for backup age: green (recent), yellow (old), red (very old)
- Added file count and size display after successful backup
- Improved visual hierarchy with sections and separators

### Improved
- Better filtering to exclude non-ShellForge directories
- More informative display with contextual information
- Cleaner and more professional appearance
- Verbose mode shows preview of backed-up files

## [1.4.2] - 2024-12-19

### Fixed
- Fixed "unbound variable" error on macOS with associative arrays
- Changed STATUS_ICONS initialization to be compatible with strict mode (set -u)
- Updated setup.sh and update.sh to use `/usr/bin/env bash` for better portability
- Added bash version check to ensure bash 4.0+ is available

## [1.4.1] - 2024-12-19

### Fixed
- Fixed "local: can only be used in a function" error in update.sh
- Removed improper use of `local` keyword outside of functions

## [1.4.0] - 2024-12-19

### Added
- Created `src/lib/ui-common.sh` - a shared UI library for consistent TUI elements
- Beautiful new UI elements including:
  - Status icons and colored output
  - Progress indicators and animations
  - Box drawing for sections and content
  - Progress bars and step counters
  - Interactive menus and separators

### Changed
- Completely redesigned `setup.sh` with beautiful TUI elements:
  - Animated build progress
  - System information display
  - Step-by-step progress tracking
  - Visual feedback for all operations
  - Fun closing animations
- Completely redesigned `update.sh` with enhanced visuals:
  - Version comparison display
  - Git repository status
  - Build statistics and timing
  - Changelog preview
  - Command reference guide
- Refactored display code to use shared UI library
- Build process now includes ui-common.sh for consistent styling

### Improved
- Consistent visual design across all ShellForge tools
- Better user feedback during installation and updates
- More engaging and professional appearance
- Centralized UI management for easier maintenance

## [1.3.6] - 2024-12-19

### Fixed
- Fixed SIGPIPE error (exit code 141) in test.sh by temporarily disabling pipefail when using head command
- The help command test now works correctly in the test suite

### Removed
- Cleaned up redundant test-help-*.sh scripts created during debugging
- Moved debug scripts to tests/archive/ directory

## [1.3.5] - 2024-12-19

### Changed
- Updated test.sh to show debug output when help command fails
- Changed test summary to use project-local test-backups directory instead of /tmp
- Help command test now captures and displays exit code for better debugging

## [1.3.4] - 2024-12-19

### Fixed
- Fixed help command test failure caused by pipefail and df command
- Made get_disk_space() function handle df errors gracefully
- Added proper error handling for date, basename, and shell environment variables
- Help command now works reliably in test environments and restricted shells
- All command substitutions in display.sh now have fallback values

## [1.3.3] - 2024-12-19

### Fixed
- Fixed all path references in test scripts after moving to tests/ directory
- Updated test.sh to correctly reference project root for shellforge and build script
- Updated test-smart-config.sh with proper path references
- Fixed test-build-fix.sh to change to project root before running
- Fixed demo-help.sh to use project root paths
- Fixed test-dynamic-help.sh to build from project root and use correct paths
- All test scripts now work correctly from their new location in tests/

## [1.3.2] - 2024-12-19

### Added
- `tests/` directory for all test scripts and demos
- `scripts/` directory for development utility scripts
- README.md for tests directory with testing guidelines
- README.md for scripts directory with utility documentation

### Changed
- Moved all test*.sh files from root to `tests/` directory
- Moved all demo*.sh files from root to `tests/` directory
- Moved fix-permissions.sh to `scripts/` directory
- Moved make-executable.sh to `scripts/` directory
- Updated Makefile to reference new test location
- Enhanced fix-permissions.sh to handle all project directories dynamically
- Simplified make-executable.sh for better maintainability

### Fixed
- Repository root is now clean and organized
- All file references updated to match new structure

## [1.3.1] - Previous Release
- Smart config filtering features
- Modular build system
- Enhanced cross-platform compatibility

## [1.3.0] - Previous Release
- Initial modular architecture implementation
- Separated code into core, lib, and modules
- Implemented build system with multiple build modes
