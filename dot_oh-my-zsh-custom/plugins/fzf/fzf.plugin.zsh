# Everything that needs fzf, loaded only when fzf is installed. This stands in
# for oh-my-zsh's fzf plugin (key bindings: Ctrl+T files, Alt+C or Ctrl+G cd)
# and also loads the external fzf-tab, fzf-tab-source and forgit plugins, which
# load silently without fzf and then fail when used.
(( $+commands[fzf] )) || return 0

source "$ZSH/plugins/fzf/fzf.plugin.zsh"

# fzf-tab must load after compinit (oh-my-zsh has run it by now) and before
# zsh-autosuggestions and fast-syntax-highlighting, so keep this plugin ahead
# of them in .zshrc
for _plugin in fzf-tab fzf-tab-source forgit; do
  if [[ -r "$ZSH_CUSTOM/plugins/$_plugin/$_plugin.plugin.zsh" ]]; then
    fpath=("$ZSH_CUSTOM/plugins/$_plugin" $fpath)
    source "$ZSH_CUSTOM/plugins/$_plugin/$_plugin.plugin.zsh"
  fi
done
unset _plugin
