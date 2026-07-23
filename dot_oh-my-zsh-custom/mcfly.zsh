if (( $+commands[mcfly] )); then
  export MCFLY_DISABLE_RUN_COMMAND=1
  eval "$(mcfly init zsh)"
fi
