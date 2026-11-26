# Use common names for tools installed with alternative names

if (($+commands[batcat])) && ((!$+commands[bat])); then
  alias bat=batcat
fi
if (($+commands[difftastic])) && ((!$+commands[difft])); then
  alias difft=difftastic
fi
if ((!$+commands[fd])); then
  # Debian's fd-find package installs the command as fdfind
  if (($+commands[fdfind])); then
    alias fd=fdfind
  elif (($+commands[fd-find])); then
    alias fd=fd-find
  fi
fi
