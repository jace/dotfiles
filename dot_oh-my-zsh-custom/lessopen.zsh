# Setup LESSOPEN with lesspipe

if (( $+commands[lesspipe.sh] )); then
  eval "$(lesspipe.sh)"
elif (( $+commands[lesspipe] )); then
  eval "$(lesspipe)"
fi
