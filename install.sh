#!/usr/bin/env bash

set -e

DOTFILES_DIR="$HOME/dotfiles"
BACKUP_DIR="$HOME/dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

echo "================================================="
echo "   Installing JC135797531's Ryoku Dotfiles       "
echo "================================================="

# 1. Ensure GNU Stow is installed
if ! command -v stow &> /dev/null; then
    echo "📦 Installing GNU Stow..."
    sudo pacman -S --needed --noconfirm stow
fi

# 2. Prepare backup directory for conflicting default configs
mkdir -p "$BACKUP_DIR"
echo "📂 Backup folder created at: $BACKUP_DIR"

# Helper function to safely back up existing configs
backup_if_exists() {
    local target="$1"
    if [ -e "$target" ] && [ ! -L "$target" ]; then
        echo "⚠️  Existing config found: $target. Moving to backup..."
        mv "$target" "$BACKUP_DIR/"
    fi
}

# 3. Backup existing root dotfiles
backup_if_exists "$HOME/.bashrc"
backup_if_exists "$HOME/.bash_profile"
backup_if_exists "$HOME/.bash_logout"
backup_if_exists "$HOME/.gitconfig"

# 4. Backup conflicting config folders
if [ -d "$DOTFILES_DIR/.config" ]; then
    mkdir -p "$HOME/.config"
    for folder in $(ls -A "$DOTFILES_DIR/.config"); do
        backup_if_exists "$HOME/.config/$folder"
    done
fi

# 5. Backup conflicting pictures/wallpapers
if [ -d "$DOTFILES_DIR/Pictures" ]; then
    mkdir -p "$HOME/Pictures"
    for folder in $(ls -A "$DOTFILES_DIR/Pictures"); do
        backup_if_exists "$HOME/Pictures/$folder"
    done
fi

# 6. Symlink everything using Stow
echo "🔗 Symlinking configurations..."
cd "$DOTFILES_DIR"
stow .

echo "================================================="
echo "   🎉 Installation Complete! Enjoy your Rice!    "
echo "================================================="
