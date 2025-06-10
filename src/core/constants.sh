#!/usr/bin/env bash
# ShellForge Core Constants
# This file contains all constant values used throughout ShellForge

# Script metadata
readonly SCRIPT_NAME="ShellForge"

# Common dotfiles to backup
readonly -a DOTFILES=(
    .zshrc
    .zsh_history
    .zshenv
    .zprofile
    .zlogin
    .zlogout
    .bashrc
    .bash_profile
    .bash_history
    .bash_aliases
    .bash_logout
    .profile
    .aliases
    .exports
    .functions
    .path
    .extra
    .inputrc
    .screenrc
    .tmux.conf
    .vimrc
    .gvimrc
    .emacs
    .nanorc
    .gitconfig
    .gitignore_global
    .curlrc
    .wgetrc
    .editorconfig
    .hushlogin
    .npmrc
    .yarnrc
    .gemrc
    .pythonrc
    .pylintrc
)

# Common configuration directories
readonly -a CONFIG_DIRS=(
    .config
    .vim
    .emacs.d
    .oh-my-zsh
    .zsh
    .bash_completion.d
    .local/share/zsh
    .zprezto
    .zplug
    .zinit
    .tmux
    .nano
)

# Directories to always skip
readonly -a SKIP_DIRS=(
    .git
    .svn
    .hg
    .bzr
    node_modules
    .npm
    .cache
    .Trash
    Downloads
    .docker
    .vagrant
    .virtualenvs
    .pyenv
    .rbenv
    .nvm
    .cargo
    .rustup
)

# Known large/binary directories in .config to skip
readonly -a CONFIG_SKIP_DIRS=(
    # Browsers
    "BraveSoftware"
    "google-chrome"
    "chromium"
    "microsoft-edge"
    "vivaldi"
    "opera"
    # Code editors/IDEs
    "Code"
    "Code - OSS"
    "VSCodium"
    "Cursor"
    "sublime-text"
    "JetBrains"
    # Communication apps
    "discord"
    "slack"
    "teams"
    "zoom"
    "skypeforlinux"
    "whatsdesk"
    "walc"
    # Other apps with large caches
    "Electron"
    "spotify"
    "Postman"
    "insomnia"
    "Franz"
    "Station"
    # Development tools
    "Docker Desktop"
    "VirtualBox"
    # Game launchers
    "heroic"
    "lutris"
    "steam"
    # Cloud storage
    "Dropbox"
    "MEGA"
    "OneDrive"
    # Misc
    "Plex Media Server"
    "qBittorrent"
    "transmission"
)

# Patterns that indicate cache/runtime data directories
readonly -a CONFIG_SKIP_PATTERNS=(
    "*[Cc]ache*"
    "*[Cc]aches*"
    "*[Cc]rash*"
    "*[Ll]ogs*"
    "*[Tt]mp*"
    "*[Tt]emp*"
    "IndexedDB"
    "Local Storage"
    "Service Worker"
    "GPUCache"
    "Crashpad"
    "blob_storage"
    "Session Storage"
    "WebRTC"
    "Cookies"
    "*History*"
    "DawnCache"
    "Partitions"
    "databases"
)
