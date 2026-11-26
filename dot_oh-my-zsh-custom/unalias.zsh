# Remove aliases that conflict with commands
# (each alias only exists if its plugin loaded)

(( $+aliases[lsd] && $+commands[lsd] )) && unalias lsd  # eza: lsd=eza -d
(( $+aliases[grc] && $+commands[grc] )) && unalias grc  # forgit: grc=git-revert-commit
