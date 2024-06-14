# Make df pretty
alias df="df -H"
# Make df pretty
alias du="du -h"
# Make free pretty
alias free="free -h"
# Make vi work
alias vi="nvim"
# Eza (better ls)
alias ls="eza --color=always --long --git --icons=always"
# Zoxide (better cd)
alias cd="z"
# Bat (better cat / less / more)
alias cat="bat"
alias less="bat"
alias more="bat"

# Disable Homebrew Hints
export HOMEBREW_NO_ENV_HINTS="true"

# Setup tmuxifier
eval "$(~/.tmuxifier/bin/tmuxifier init -)"
# Setup Homebrew
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
# Setup Starship
eval "$(starship init zsh)"
# Setup fzf key bindings and fuzzy completion
eval "$(fzf --zsh)"
# Setup thefuck alias
eval $(thefuck --alias)
# Setup Zoxide (better cd)
eval "$(zoxide init zsh)"
# Setup autosuggestions
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
# Setup syntax highlighting
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

fpath+=${ZDOTDIR:-~}/.zsh_functions

# Use fd instead of fzf 
export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

# Use fd (https://github.com/sharkdp/fd) for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
_fzf_compgen_path() {
  fd --hidden --exclude .git . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type=d --hidden --exclude .git . "$1"
}

# Setup FZF
source ~/fzf-git.sh/fzf-git.sh

# Set a Catppuccin Mocha theme for FZF
export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"

# Set a theme for bat
export BAT_THEME="Catppuccin Mocha"

export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always --line-range :500 {}'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

# Advanced customization of fzf options via _fzf_comprun function
# - The first argument to the function is the name of the command.
# - You should make sure to pass the rest of the arguments to fzf.
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo $'{}"         "$@" ;;
    ssh)          fzf --preview 'dig {}'                   "$@" ;;
    *)            fzf --preview "bat -n --color=always --line-range :500 {}" "$@" ;;
  esac
}

# History Configuration
HISTFILE=$HOME/.zsh_history
SAVEHIST=99999
HISTSIZE=99999
setopt share_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_verify

# Make it pretty at the end
clear
neofetch
