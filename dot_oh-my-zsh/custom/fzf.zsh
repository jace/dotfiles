export FZF_DEFAULT_OPTS=" --border sharp --layout reverse --prompt '∷ ' --pointer ▶ --marker ⇒"
# Use bat to preview files in the Ctrl+T file browser
export FZF_CTRL_T_OPTS=' --height=100% --preview="bat --line-range=:500 --color=always {}" --preview-window=right:60%:wrap'
# Use Ctrl+G in addition to Alt+C for the `cd` widget as `Alt+C` is not available on macOS
zle     -N            fzf-cd-widget
bindkey -M emacs '\C-g' fzf-cd-widget
bindkey -M vicmd '\C-g' fzf-cd-widget
bindkey -M viins '\C-g' fzf-cd-widget
