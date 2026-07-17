# ===============================
#   Shell options
# ===============================
setopt NO_BG_NICE           # don't nice background tasks
setopt NO_HUP               # don't send HUP to background jobs
setopt NO_BEEP              # beep off
setopt INTERACTIVE_COMMENTS # allow comments in interactive shell
setopt HIST_IGNORE_ALL_DUPS # remove older duplicate entries from history
setopt HIST_REDUCE_BLANKS   # remove superfluous blanks from history items
setopt HIST_SAVE_NO_DUPS    # don't save duplicates
setopt INC_APPEND_HISTORY   # append to history immediately

# ===============================
#   History settings
# ===============================
HISTFILE="${HOME}/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000

# ===============================
#   Silence compinit insecure warning (no interactive prompt)
# ===============================
export ZSH_DISABLE_COMPFIX=1

# ===============================
#   Zinit installation (with nice messages)
# ===============================
if [[ ! -f "${HOME}/.zinit/bin/zinit.zsh" ]]; then
    echo "📦 Configuring the terminal..."
    if command -v git >/dev/null; then
        git clone https://github.com/zdharma-continuum/zinit.git "${HOME}/.zinit/bin" && \
            echo "✅ Zinit installed successfully."
    else
        echo "❌ Git is not installed – cannot fetch Zinit."
        echo "   Please install Git and restart your shell."
        return 1
    fi
fi

source "${HOME}/.zinit/bin/zinit.zsh" 2>/dev/null

# ===============================
#   Plugins (loaded asynchronously)
# ===============================
echo "⏳ Loading plugins (autosuggestions & syntax highlighting)..."

zinit ice wait lucid depth=1
zinit light zsh-users/zsh-autosuggestions

zinit ice wait lucid depth=1
zinit light zdharma-continuum/fast-syntax-highlighting

# ===============================
#  Modern utilties to increase quality of life
# ===============================
if command -v zoxide &>/dev/null; then
    eval "$(zoxide init zsh)"
fi

if command -v mise &>/dev/null; then
    export PATH="$HOME/.local/share/mise/shims:$PATH"
fi

if command -v eza &>/dev/null; then
    alias ls='eza -l --color=auto'
    alias tree='eza --tree'
fi

if command -v bat &>/dev/null; then
    alias cat='bat --style=plain --paging=never'
fi

if command -v rg &>/dev/null; then
    alias grep='rg --color=auto'
fi

if command -v fd &>/dev/null; then
    alias find='fd'
fi

if command -v btop &>/dev/null; then
    alias top='btop'
fi

if command -v tldr &>/dev/null; then
    alias help='tldr'
fi

if command -v fzf &>/dev/null; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi

if command -v starship &>/dev/null; then
    eval "$(starship init zsh)"
fi