# tmux doesn't redraw a pane's title strip when its shell changes folder, so
# the folder shown there lags until something else redraws it (such as
# switching panes). After a cd, redraw the attached clients once, at the next
# prompt, by when oh-my-zsh has set the shell's new title.
(( $+commands[tmux] )) && [[ -n $TMUX ]] || return 0

_tmux_folder_changed=
_tmux_mark_folder_changed() { _tmux_folder_changed=1 }
_tmux_redraw_after_cd() {
  [[ -n $_tmux_folder_changed ]] || return 0
  _tmux_folder_changed=
  # In the background, so the shell stays the pane's foreground program: while
  # tmux itself is, the title strip shows the raw title (user@host:folder)
  {
    local client
    tmux list-clients -F '#{client_name}' 2>/dev/null | while IFS= read -r client; do
      tmux refresh-client -t "$client" 2>/dev/null
    done
  } &!
}
autoload -Uz add-zsh-hook
add-zsh-hook chpwd _tmux_mark_folder_changed
add-zsh-hook precmd _tmux_redraw_after_cd
