#!/usr/bin/env sh

session="alacritty-$(date +%Y%m%d-%H%M%S)-$$"

# Create a dedicated session for this terminal, enable auto-destroy on detach,
# then attach to it.
exec tmux new-session -d -s "$session" \; \
    set-option -t "$session" destroy-unattached on \; \
    attach-session -t "$session"
