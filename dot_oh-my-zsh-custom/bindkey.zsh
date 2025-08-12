# Customize shift-select's bindkeys

function shift-select::cut {
  zle kill-region
  zle -K main
  # Also transfer to system clipboard
  if [ -n "$(command -v it2copy)" ]; then
    # If in iTerm2, use its utility function
    printf "%s" "$CUTBUFFER" | it2copy
  elif [ -n "$(command -v clipcopy)" ]; then
    # Else use host's clipboard tool
    printf "%s" "$CUTBUFFER" | clipcopy
  fi
}
zle -N shift-select::cut

function shift-select::copy {
  zle copy-region-as-kill -w
  zle -K main
  # Also transfer to system clipboard
  if [ -n "$(command -v it2copy)" ]; then
    # If in iTerm2, use its utility function
    printf "%s" "$CUTBUFFER" | it2copy
  elif [ -n "$(command -v clipcopy)" ]; then
    # Else use host's clipboard tool
    printf "%s" "$CUTBUFFER" | clipcopy
  fi
}
zle -N shift-select::copy

function shift-select::paste {
  zle kill-region
  zle yank
  zle yank-pop
  # TODO: Use the more recent of system clipboard and kill buffer, except neither
  # has age records
  zle -K main
}
zle -N shift-select::paste

function shift-select::escape {
  zle deactivate-region -w
  zle -K main
}
zle -N shift-select::escape

bindkey -M emacs \^U backward-kill-line
for seq       widget (
    '^[[1;6D' backward-word      # Ctrl+Shift+Left
    '^[[1;6C' forward-word       # Ctrl+Shift+Right
    '\e'      escape             # Esc
  ); do
  bindkey -M emacs $seq shift-select::$widget
  bindkey -M shift-select $seq shift-select::$widget
done

bindkey -M main        '^[[1;3D'    backward-word         # Option+Left
bindkey -M main        '^[[1;3C'    forward-word          # Option+Right
bindkey -M main        '^[[127;2u'  backward-delete-char  # Shift+Backspace
bindkey -M main        '^[[3;2~'    delete-char           # Shift+Delete
bindkey -M main        '^[[32;2u'   magic-space           # Shift+Space
bindkey -M main        '^[[D'       beginning-of-line     # Cmd+Left
bindkey -M main        '^[[C'       end-of-line           # Cmd+Right
bindkey -M shift-select '^[[88;5u'  shift-select::cut     # Ctrl+Shift+X
bindkey -M shift-select '^[[67;5u'  shift-select::copy    # Ctrl+Shift+C
bindkey -M shift-select '^[[86;5u'  shift-select::paste   # Ctrl+Shift+V
bindkey -M emacs        '^[[86;5u'  yank                  # Ctrl+Shift+V
