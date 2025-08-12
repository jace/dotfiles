if (( $+commands[bat] )); then
  alias cat='bat --paging=never --style=plain'
elif (( $+commands[batcat] )); then
  alias cat='batcat --paging=never --style=plain'
fi
