# Use common names for tools installed with alternative names

if (($+commands[batcat])) && ((!$+commands[bat])); then
  alias bat=batcat
fi
if (($+commands[difftastic])) && ((!$+commands[difft])); then
  alias difft=difftastic
fi
if (($+commands[fd-find])) && ((!$+commands[fd])); then
  alias fd=fd-find
fi
