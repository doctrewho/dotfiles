Pre-requisites:

    Default shell is zsh
    Install gcc via package manager
    Install brew
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    Install tmuxifier
        git clone https://github.com/jimeh/tmuxifier.git ~/.tmuxifier

Run the following:

    export HOMEBREW_NO_ENV_HINTS="true"
    brew install nvim fzf fd feh bat git-delta eza tlrc thefuck zoxide zsh-autosuggestions zsh-syntax-highlighting npm neofetch tmux lazygit yamllint ripgrep vivid
    Install polybar and rofi via package manager
    Download a Nerd Font and install it
    curl -sS https://starship.rs/install.sh | sh
    bat cache -b
    git clone https://github.com/junegunn/fzf-git.sh.git

    (Optional)
    Install mosh
    sudo firewall-cmd --add-service=mosh --permanent
    sudo firewall-cmd --reload

    source .zshrc

All dotfiles setup in GNU Stow format
stow -t ~ <directory>

Start tmux and install the plugins (CNTL-A SHIFT-I)

Start nvim and let it install what it needs
