# ShellForge Modular Architecture

## Overview

ShellForge now uses a modular build system that maintains the key benefit of producing a single, self-contained shell script while making development much more manageable.

## Directory Structure

```
shellforge/
├── src/                    # Source modules
│   ├── core/              # Core functionality
│   │   ├── constants.sh   # Global constants and arrays
│   │   ├── variables.sh   # Global variables
│   │   ├── utils.sh       # Utility functions
│   │   └── display.sh     # UI and display functions
│   ├── lib/               # Shared libraries
│   │   ├── file-operations.sh    # File/directory operations
│   │   ├── metadata.sh          # Metadata handling
│   │   └── backup-filters.sh    # Backup filtering logic
│   ├── modules/           # Feature modules
│   │   ├── backup.sh      # Save functionality
│   │   ├── restore.sh     # Restore functionality
│   │   ├── list.sh        # List backups
│   │   └── smart-config.sh # Smart config enhancements
│   ├── header.sh          # Script header (shebang, metadata)
│   └── main.sh           # Main entry point
├── build/                 # Build system
│   └── build.sh          # Build script
├── dist/                  # Built artifacts (created by build)
├── tests/                 # Test files
├── Makefile              # Convenient build targets
├── VERSION               # Version number
└── shellforge            # Final built script
```

## Build System Features

### Build Modes

1. **Release** (default): Standard build with production optimizations
2. **Debug**: Includes source file markers and all comments for debugging
3. **Minimal**: Strips all comments for smallest file size

### Build Process

The build script (`build/build.sh`) performs the following:

1. Validates syntax of all source files
2. Concatenates files in dependency order
3. Strips duplicate shebangs
4. Adds build metadata (version, timestamp, git hash)
5. Applies mode-specific transformations
6. Creates executable output
7. Validates final script syntax

### Using Make

```bash
# Build release version
make

# Build debug version
make debug

# Build minimal version
make minimal

# Install to ~/bin
make install

# Clean build artifacts
make clean

# Run tests
make test

# Create a tagged release
make release

# Bump version interactively
make bump-version

# Watch for changes and auto-rebuild (requires inotify-tools)
make watch
```

### Direct Build Script Usage

```bash
# Build release version
./build/build.sh release

# Build debug version
./build/build.sh debug

# Build minimal version
./build/build.sh minimal

# Clean artifacts
./build/build.sh clean
```

## Development Workflow

### Adding New Features

1. Create new module in `src/modules/`
2. Add any shared functions to `src/lib/`
3. Update build script if needed (usually not required)
4. Run `make` to build
5. Test the built script

### Modifying Existing Features

1. Edit the relevant module file
2. Run `make debug` for testing with source markers
3. Run `make` for final build
4. Test thoroughly

### Best Practices

1. **Module Independence**: Each module should be as independent as possible
2. **Clear Dependencies**: If a module needs functions from lib/, that's fine
3. **Constants First**: All constants go in `core/constants.sh`
4. **Variables Second**: All global variables go in `core/variables.sh`
5. **No Circular Dependencies**: Modules shouldn't depend on each other
6. **Document Functions**: Add comments explaining what functions do

## Module Guidelines

### Core Modules (`src/core/`)
- `constants.sh`: Readonly arrays and constants
- `variables.sh`: Global variables and their initialization
- `utils.sh`: Basic utility functions used everywhere
- `display.sh`: All UI-related functions

### Library Modules (`src/lib/`)
- Shared functions used by multiple feature modules
- Should be pure functions without side effects when possible
- Named by their primary purpose

### Feature Modules (`src/modules/`)
- Implement major features (save, restore, list)
- Can use functions from core/ and lib/
- Should not depend on other feature modules

## Advanced Features

### Future Enhancements

The modular structure enables future enhancements like:

1. **Feature Flags**: Include/exclude modules at build time
2. **Platform-Specific Builds**: Create macOS-only or Linux-only versions
3. **Module Metadata**: Declare dependencies and requirements
4. **Tree Shaking**: Remove unused functions automatically
5. **Compression**: Create self-extracting versions for very large scripts
6. **Multiple Targets**: Build bash-only or zsh-only versions

### Adding Build Profiles

To add a new build profile, edit `build/build.sh` and add a case in the `process_build_mode()` function.

## Benefits

1. **Easier Maintenance**: Find and fix issues quickly
2. **Better Organization**: Related code is grouped together
3. **Cleaner Git History**: Changes are isolated to specific modules
4. **Easier Testing**: Test individual modules
5. **Simpler Contributions**: New contributors can focus on one module
6. **Flexible Builds**: Different builds for different needs
7. **Development Features**: Debug builds help troubleshooting

## Migration from Monolithic Script

The functionality remains identical - the modular system just reorganizes the code for better development experience. The final built script is still a single, self-contained shell script that works anywhere bash/zsh is available.
