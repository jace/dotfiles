#!/bin/sh
# Animate tab widths when the current window changes: the new current tab grows
# to its full name a step at a time while the tab just left shrinks to the
# short width at the same rate. Run from tmux.conf's session-window-changed
# hook as:
#   tab-animate.sh <session-id> <old-window-id> <new-window-id>
# Each tab's width is its window option @tab-w (unset means the short width);
# the current tab ends at 999, which shows the full name.
session=$1 old=$2 new=$3
# Characters per frame and the pause between frames; each frame also costs a
# tmux call (about 20 ms)
short=12 step=2 delay=0.005

tmux set -t "$session" @tab-prev "$new"
[ -n "$old" ] && [ "$old" != "$new" ] || exit 0

# A newer switch takes over: each animation has a number, and stops once a
# later one has started
gen=$(($(tmux show -t "$session" -qv @tab-gen 2>/dev/null || echo 0) + 1))
tmux set -t "$session" @tab-gen "$gen"

width() {
  w=$(tmux show -w -t "$1" -qv @tab-w 2>/dev/null)
  echo "${w:-$short}"
}
full=$(tmux display -p -t "$new" '#{n:#{E:@tab-name}}' 2>/dev/null) || exit 0
grow=$(width "$new")
[ "$grow" -gt "$full" ] && grow=$full
# The tab just left starts from its full name, or wherever an interrupted
# animation left it
shrink=$(width "$old")
oldfull=$(tmux display -p -t "$old" '#{n:#{E:@tab-name}}' 2>/dev/null) || oldfull=$short
[ "$shrink" -gt "$oldfull" ] && shrink=$oldfull

# Each frame is one tmux call: it applies the widths and redraws the status
# lines only while this is still the newest animation
redraw=$(tmux list-clients -t "$session" -F '; refresh-client -S -t #{client_name}' 2>/dev/null | tr '\n' ' ')
frame() {
  tmux if -t "$session" -F "#{==:#{@tab-gen},$gen}" "$1 $redraw" 2>/dev/null
}

n=0
while [ "$grow" -lt "$full" ] || [ "$shrink" -gt "$short" ]; do
  grow=$((grow + step)) shrink=$((shrink - step))
  [ "$grow" -gt "$full" ] && grow=$full
  [ "$shrink" -lt "$short" ] && shrink=$short
  frame "set -w -t $new @tab-w $grow ; set -w -t $old @tab-w $shrink"
  sleep "$delay"
  # Stop early once a newer animation has taken over
  n=$((n + 1))
  if [ $((n % 4)) = 0 ] && [ "$(tmux show -t "$session" -qv @tab-gen)" != "$gen" ]; then
    exit 0
  fi
done
frame "set -w -t $new @tab-w 999 ; set -wu -t $old @tab-w"
