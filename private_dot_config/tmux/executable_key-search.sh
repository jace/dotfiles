#!/bin/sh
# Fuzzy-search tmux's key bindings by their descriptions, then press the chosen
# key for the client that asked. Run from prefix / (tmux.conf) as:
#   key-search.sh <client-name>
# Needs fzf, and tmux 3.4 or later for `send-keys -K`.
client=$1

# One line per key: table, key, description. list-keys -N labels every key with
# the prefix whatever its table, so label each table ourselves.
choice=$(
  {
    tmux list-keys -N -T prefix -P 'prefix '
    tmux list-keys -N -T root -P 'nokey '
  } | fzf --reverse --no-sort --prompt 'key: ' --header 'Enter presses the key'
) || exit 0
table=$(echo "$choice" | awk '{print $1}')
key=$(echo "$choice" | awk '{print $2}')
[ -n "$key" ] || exit 0

# Press it once this popup has closed, or the popup would get the key. The key
# goes through a tmux option so #{q:} can quote it (" and % are keys too).
tmux set -g @key-search-key "$key"
if [ "$table" = prefix ]; then
  tmux run-shell -b "sleep 0.1; tmux send-keys -K -c '$client' #{q:prefix} #{q:@key-search-key}"
else
  tmux run-shell -b "sleep 0.1; tmux send-keys -K -c '$client' #{q:@key-search-key}"
fi
