# ShellForge Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
