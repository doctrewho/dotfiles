#!/bin/bash

# --- 1. System Primitive Installation (Multi-Distro) ---
echo "🚀 Starting full system setup..."
OS_TYPE=$(uname -s)

if [ "$OS_TYPE" == "Linux" ]; then
    . /etc/os-release
    echo "🐧 Linux detected: $PRETTY_NAME"

    case "$ID" in
        arch)
            sudo pacman -Syu --noconfirm
            sudo pacman -S --noconfirm gcc polybar rofi zsh stow mosh unzip curl
            ;;
        opensuse*|suse)
            sudo zypper --non-interactive install gcc polybar rofi zsh stow mosh unzip curl
            ;;
        fedora)
            sudo dnf install -y gcc polybar rofi zsh stow mosh unzip curl
            ;;
        ubuntu|debian|pop)
            sudo apt-get update
            sudo apt-get install -y gcc polybar rofi zsh stow mosh unzip curl
            ;;
    esac

    # Firewall setup for Mosh
    if command -v firewall-cmd &> /dev/null; then
        sudo firewall-cmd --add-service=mosh --permanent && sudo firewall-cmd --reload
    fi
fi

# --- 2. Homebrew & CLI Tools ---
if ! command -v brew &> /dev/null; then
    echo "🍺 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com)"
    eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || eval "$(/usr/local/bin/brew shellenv)"
fi

export HOMEBREW_NO_ENV_HINTS="true"
echo "📦 Installing Brew packages..."
brew install nvim fzf fd feh bat git-delta eza tlrc thefuck zoxide \
     zsh-autosuggestions zsh-syntax-highlighting npm neofetch tmux \
     lazygit yamllint ripgrep vivid tpm

# --- 3. Agave Nerd Font & Starship ---
echo "🔤 Installing Agave Nerd Font..."
FONT_DIR="$HOME/.local/share/fonts"
[[ "$OS_TYPE" == "Darwin" ]] && FONT_DIR="$HOME/Library/Fonts"
mkdir -p "$FONT_DIR"

# Correct Official Agave URL
AGAVE_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Agave.zip"

curl -L "$AGAVE_URL" -o /tmp/Agave.zip
unzip -o /tmp/Agave.zip -d "$FONT_DIR"
fc-cache -fv &> /dev/null || true

echo "⭐ Installing Starship..."
curl -sS https://starship.rs | sh -s -- -y

# --- 4. Clone Plugins & Helper Repos ---
echo "📂 Cloning helper repositories..."
[ -d "$HOME/.tmuxifier" ] || git clone https://github.com ~/.tmuxifier
[ -d "$HOME/fzf-git.sh" ] || git clone https://github.com ~/fzf-git.sh
[ -d "$HOME/.tmux/plugins/tpm" ] || git clone https://github.com ~/.tmux/plugins/tpm

# --- 5. GNU Stow (Dotfiles) ---
echo "🔗 Linking dotfiles..."
# Assumes dotfiles are in a folder named 'dotfiles' in current directory
if [ -d "./dotfiles" ]; then
    stow -v -t ~ dotfiles
else
    echo "⚠️  'dotfiles' directory not found. Please verify the folder name."
fi

bat cache -b

# --- 6. Automated Plugin Installations (Headless) ---
echo "🛠️  Pre-installing Neovim plugins..."
nvim --headless "+Lazy! sync" +qa

echo "🔌 Pre-installing Tmux plugins..."
# Start a temporary tmux server, run TPM install, and kill it
tmux start-server
tmux new-session -d
~/.tmux/plugins/tpm/bin/install_plugins
tmux kill-server

# --- 7. Set Default Shell and Launch ---
if [[ "$SHELL" != *"zsh"* ]]; then
    sudo chsh -s "$(which zsh)" "$(whoami)"
fi

echo "✨ Setup complete. Switching to ZSH prompt..."
exec zsh -l

