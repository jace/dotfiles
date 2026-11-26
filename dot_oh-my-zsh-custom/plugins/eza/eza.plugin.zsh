# Quiet stand-in for oh-my-zsh's eza plugin, which warns at every shell start
# when eza isn't installed. oh-my-zsh loads this file instead of the stock one.
(( $+commands[eza] )) || return 0
source "$ZSH/plugins/eza/eza.plugin.zsh"
