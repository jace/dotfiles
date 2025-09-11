# Older bat doesn't support `--theme(light|dark)` in config, so use ENV
export BAT_THEME_LIGHT="Coldark-Cold"
export BAT_THEME_DARK="Visual Studio Dark+"

if (( $+commands[bat] )); then
  alias cat='bat --paging=never --style=plain'
elif (( $+commands[batcat] )); then
  alias cat='batcat --paging=never --style=plain'
fi
