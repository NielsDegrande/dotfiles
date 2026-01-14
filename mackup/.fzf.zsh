# Setup fzf
# ---------
if [[ ! "$PATH" == */opt/homebrew/opt/fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/opt/homebrew/opt/fzf/bin"
fi

source <(fzf --zsh)

# Exports
# -------

export FZF_DEFAULT_COMMAND='rg --files --hidden --glob "!.git"'
export FZF_DEFAULT_OPTS="--height=40% --layout=reverse --info=inline --border --margin=1 --padding=1"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
