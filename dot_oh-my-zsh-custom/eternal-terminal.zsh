if (( $+commands[et] )); then
  # Reset $TERM for remote servers that may not have terminfo
  [[ "$TERM" =~ "xterm-(ghostty|kitty)" ]] && alias et='TERM=xterm-256color et'
fi
