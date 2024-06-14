Pre-requisites:

    Default shell is zsh
    Install gcc
    Install brew
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    Install tmuxifier
        git clone https://github.com/jimeh/tmuxifier.git ~/.tmuxifier

    (Optional)
    Install mosh

Run the following:

    export HOMEBREW_NO_ENV_HINTS="true"
    brew install nvim fzf fd bat git-delta eza tlrc thefuck zoxide zsh-autosuggestions zsh-syntax-highlighting npm neofetch tmux lazygit yamllint
    brew tap homebrew/cask-fonts
    brew install font-agave-nerd-font
    curl -sS https://starship.rs/install.sh | sh
    bat cache -b
    git clone https://github.com/junegunn/fzf-git.sh.git

    (Optional)
    sudo firewall-cmd --add-service=mosh --permanent
    sudo firewall-cmd --reload

    source .zshrc

All dotfiles setup in GNU Stow format

Start tmux and install the plugins (CNTL-A SHIFT-I)

Start nvim and let it install what it needs
