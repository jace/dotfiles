if (( $+commands[et] )); then
  # Don't send usage data to Eternal Terminal's developers (the client's default)
  if [[ "$TERM" =~ "xterm-(ghostty|kitty)" ]]; then
    # Reset $TERM for remote servers that may not have terminfo
    alias et='TERM=xterm-256color et --telemetry=false'
  else
    alias et='et --telemetry=false'
  fi
fi
