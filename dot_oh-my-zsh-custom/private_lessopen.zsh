# Setup LESSOPEN with lesspipe

if (( $+commands[lesspipe.sh] )); then
  eval "$(lesspipe.sh)"
elif (( $+commands[lesspipe] )); then
  eval "$(lesspipe)"
fi

# Tell less (v609+) to display nerd icons
# https://github.com/ryanoasis/nerd-fonts/issues/1337
export LESSUTFCHARDEF="23fb-23fe:w,2665:w,2b58:w,e000-e00a:w,e0a0-e0a3:p,e0b0-e0bf:p,e0c0-e0c8:w,e0ca:w,e0cc-e0d7:w,e200-e2a9:w,e300-e3e3:w,e5fa-e6b5:w,e700-e7c5:w,ea60-ec1e:w,ed00-efce:w,f000-f2ff:w,f300-f375:w,f400-f533:w,f0001-f1af0:w"
