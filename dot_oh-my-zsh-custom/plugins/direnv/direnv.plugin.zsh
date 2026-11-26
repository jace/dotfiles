# Quiet stand-in for oh-my-zsh's direnv plugin, which warns at every shell start
# when direnv isn't installed. oh-my-zsh loads this file instead of the stock one.
(( $+commands[direnv] )) || return 0
source "$ZSH/plugins/direnv/direnv.plugin.zsh"
