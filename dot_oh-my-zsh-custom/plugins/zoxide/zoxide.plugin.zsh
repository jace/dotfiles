# Quiet stand-in for oh-my-zsh's zoxide plugin, which warns at every shell start
# when zoxide isn't installed. oh-my-zsh loads this file instead of the stock one.
(( $+commands[zoxide] )) || return 0
source "$ZSH/plugins/zoxide/zoxide.plugin.zsh"
