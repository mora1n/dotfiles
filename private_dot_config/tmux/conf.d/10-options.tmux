# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Options
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Keep the systemd-started zero-session server alive so continuum can auto-restore
# sessions after reboot (exit-empty "on" is the default and kills it immediately).
set -g exit-empty off

# Terminal
set -s default-terminal "tmux-256color"
set -g terminal-overrides "linux*:AX@,*256col*:Tc,xterm*:Tc"
set -g allow-passthrough on
set -ga update-environment TERM
set -ga update-environment TERM_PROGRAM

# Input and navigation
set -g mouse on
set -g mode-keys vi
set -g status-keys emacs
set -s escape-time 10
set -g repeat-time 600
set -g display-time 4000
set -g history-limit 50000
set -g focus-events on
setw -g aggressive-resize on
set -g base-index 1
setw -g pane-base-index 1
set -g renumber-windows on
set -g detach-on-destroy off

# tmux 3.6 UI refinements
set -g pane-border-lines heavy
set -g copy-mode-position-style bg=#f1fa8c,fg=#282a36,bold
set -g copy-mode-selection-style bg=#8be9fd,fg=#282a36
set -g prompt-cursor-colour "#8be9fd"
set -g prompt-cursor-style blinking-bar
set -g input-buffer-size 2097152

# tmux 3.7/3.8 copy mode and built-in UI, matching the Dracula theme.
set -s theme dark
set -g copy-mode-line-numbers hybrid
set -g copy-mode-line-number-style fg=#6272a4
set -g copy-mode-current-line-number-style fg=#f1fa8c,bold
set -g copy-mode-current-line-style bg=#44475a
set -g pane-scrollbars auto-hide
set -g pane-scrollbars-style bg=#282a36,fg=#6272a4,width=1,pad=0

# Status bar
set -g status-position top

# Clipboard
set -s set-clipboard on
set -s copy-command "xsel -i --clipboard"
