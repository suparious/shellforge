# ShellForge 🔥

A powerful shell configuration backup and restore tool that helps you forge your perfect shell environment across multiple machines.

## Features

- **Cross-platform**: Works on macOS and Linux (Debian, Ubuntu, etc.)
- **Smart backups**: Automatically detects and backs up common shell configurations
- **Machine-specific**: Organize backups by machine name (hostname by default)
- **Flexible restore**: Restore your macOS config to a fresh Debian machine
- **Secure**: Only backs up .pem files from .ssh, avoiding private keys
- **Incremental**: Each save creates a timestamped backup with a "latest" symlink
- **Beautiful TUI**: Enhanced list command with color-coded age indicators and rich information (v1.5.0+)
- **Smart Filtering**: Only shows genuine ShellForge backups, filtering out other directories

## Installation

1. Build and install ShellForge:
   ```bash
   make install  # Builds and installs to ~/bin
   ```
   
   Or use the setup script for full configuration:
   ```bash
   chmod +x setup.sh
   ./setup.sh  # Builds, installs, and configures shell files
   ```

2. The setup script will:
   - Install shellforge to `$HOME/bin/`
   - Add configuration to your `.zshrc` and/or `.bashrc`
   - Set up helpful aliases (`sfs`, `sfr`, `sfl`, `sfsn`)
   - Configure an auto-backup reminder

3. Edit your shell config file to set your backup destination:
   ```bash
   # Open your shell config
   vim ~/.zshrc  # or ~/.bashrc
   
   # Find and update this line:
   export BACKUP_DEST="${HOME}/Backups/shellforge"
   ```

4. Reload your shell:
   ```bash
   source ~/.zshrc  # or source ~/.bashrc
   ```

## Usage

### Save your current shell configuration
```bash
# Using current hostname
shellforge save

# Using custom machine name
shellforge save macbook-pro
```

### Restore from a backup
```bash
# Restore from current hostname's latest backup
shellforge restore

# Restore from a specific machine's backup
shellforge restore macbook-pro
```

### List available backups
```bash
shellforge list          # Beautiful TUI display of all backups
shellforge list --verbose  # Show more details including file previews
```

## What Gets Backed Up

### Dotfiles
- Zsh: `.zshrc`, `.zshenv`, `.zprofile`, `.zlogin`, `.zlogout`, `.zsh_history`
- Bash: `.bashrc`, `.bash_profile`, `.bash_history`, `.bash_aliases`, `.bash_logout`
- General: `.profile`, `.aliases`, `.exports`, `.functions`, `.path`, `.extra`
- Editors: `.vimrc`, `.gvimrc`, `.emacs`, `.nanorc`
- Tools: `.tmux.conf`, `.screenrc`, `.gitconfig`, `.gitignore_global`
- Others: `.curlrc`, `.wgetrc`, `.editorconfig`, `.npmrc`, `.yarnrc`, etc.

### Configuration Directories
- `.config/` - General application configs
- `.vim/`, `.emacs.d/` - Editor configurations
- `.oh-my-zsh/`, `.zsh/`, `.zprezto/`, `.zplug/`, `.zinit/` - Zsh frameworks
- `.tmux/` - Tmux plugins and configs
- `.local/share/zsh/` - Zsh local data

### Special Handling
- `.ssh/*.pem` - Only PEM files (for infrastructure access)
- `.ssl/` - Entire directory if it exists

### What's Excluded
- Git repositories (`.git/`)
- Package managers (`.npm/`, `.cargo/`, `.pyenv/`, etc.)
- Cache directories (`.cache/`)
- Downloads directory
- Node modules
- Virtual environments

## Backup Structure

```
$BACKUP_DEST/
├── macbook/
│   ├── 20240115_143022/
│   │   ├── home/          # Your backed up files
│   │   └── metadata/       # Backup information
│   │       └── backup_info.txt
│   └── latest -> 20240115_143022/
└── debian-server/
    ├── 20240115_150000/
    └── latest -> 20240115_150000/
```

## Cross-Machine Restore

You can easily transfer your shell environment between machines:

```bash
# On your MacBook
shellforge save macbook-work

# On your Debian machine
shellforge restore macbook-work
```

## Migrating Existing Backups (v1.5.0+)

If you have backups from versions before 1.5.0, they won't appear in the new enhanced list command. Run the migration script to add the necessary metadata:

```bash
# Make the script executable
chmod +x scripts/migrate-backups.sh

# Run the migration
./scripts/migrate-backups.sh
```

This will scan your existing backups and add marker files so they appear in the enhanced list display.

## Visual Enhancements

ShellForge automatically detects and uses the following tools if installed:
- **figlet**: For stylish ASCII art banners
- **lolcat**: For rainbow colored output
- **cowsay**: For fun success messages

Install them for a more delightful experience:
```bash
# macOS
brew install figlet lolcat cowsay

# Debian/Ubuntu
sudo apt-get install figlet lolcat cowsay
```

## Tips

1. The setup script automatically configures aliases:
   - `sfs` - Quick save
   - `sfr` - Quick restore
   - `sfl` - Quick list
   - `sfsn "message"` - Save with a note

2. Auto-backup reminder: If you haven't backed up in 7+ days, you'll see a reminder when you open a new shell

3. Run `shellforge save` after making significant shell configuration changes

4. The tool uses `rsync` when available for better restore performance

5. Your backups are organized by machine name and timestamp, making it easy to manage multiple systems

## Development

ShellForge now uses a modular build system. The source code is organized into modules that are combined during build time to create a single, portable shell script.

### Building from Source

```bash
# Build release version
make

# Build debug version (with source markers)
make debug

# Build minimal version (stripped comments)
make minimal

# Clean build artifacts
make clean
```

### Project Structure

```
src/
├── core/       # Core functionality (constants, variables, utils)
├── lib/        # Shared libraries
├── modules/    # Feature modules (backup, restore, list)
├── header.sh   # Script header
└── main.sh     # Entry point
```

See [ARCHITECTURE.md](ARCHITECTURE.md) for detailed information about the modular structure.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
