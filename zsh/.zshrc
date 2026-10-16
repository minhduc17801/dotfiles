# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# PATH (unique entries)
typeset -U path PATH fpath
export GOPATH="${GOPATH:-$HOME/go}"
path=("$HOME/bin" "$HOME/.local/bin" "$GOPATH/bin" $path)

# Options
setopt auto_cd interactive_comments

## History
[ -z "$HISTFILE" ] && HISTFILE="$HOME/.zsh/.zsh_history"
HISTSIZE=50000
SAVEHIST=10000
setopt extended_history       # record timestamp of command in HISTFILE
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_all_dups   # drop older duplicate of a command
setopt hist_ignore_space      # ignore commands that start with space
setopt hist_reduce_blanks     # strip superfluous blanks
setopt hist_verify            # show command with history expansion to user before running it
setopt share_history          # share command history data

# Keymap (before plugins so they bind into emacs)
bindkey -e

# Completion (compinit is run by ez-compinit at the first prompt)
zstyle ':plugin:ez-compinit' 'use-cache' 'yes'
zstyle ':plugin:ez-compinit' 'compstyle' 'none'
zstyle ':completion:*' menu no
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'

# Plugins (antidote, list in ~/.zsh_plugins.txt)
[[ -d ~/.antidote ]] || git clone --quiet --depth=1 https://github.com/mattmc3/antidote ~/.antidote
source ~/.antidote/antidote.zsh
antidote load

# Keys
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
[[ -n $terminfo[kcuu1] ]] && bindkey "$terminfo[kcuu1]" history-substring-search-up
[[ -n $terminfo[kcud1] ]] && bindkey "$terminfo[kcud1]" history-substring-search-down

# Tools
if (( $+commands[fzf] )); then
  if (( $+commands[fd] )); then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git'
  fi
  (( $+commands[bat] )) && export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:200 {}'"
  source <(fzf --zsh)
fi
(( $+commands[zoxide] )) && eval "$(zoxide init zsh)"
(( $+commands[fnm] )) && eval "$(fnm env --use-on-cd --shell zsh)"

#Alias
alias gco="git checkout"
alias gp="git push"
alias gl="git pull"
alias gcp="git cherry-pick"
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
if (( $+commands[eza] )); then
  alias ls="eza --group-directories-first --icons=auto"
  alias ll="eza -lh --git --group-directories-first --icons=auto"
  alias la="eza -lha --git --group-directories-first --icons=auto"
  alias tree="eza --tree --icons=auto"
else
  alias ls="ls --color=auto"
  alias ll="ls -lh"
  alias la="ls -lha"
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Machine-specific config (not in dotfiles)
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
