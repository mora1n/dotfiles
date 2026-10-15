# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Environment
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Keep tmux's default SSH and desktop variables, including additions in 3.7.
# Reset first so reloading does not append duplicate entries.
set-option -gu update-environment
set-option -ga update-environment "XMODIFIERS GTK_IM_MODULE QT_IM_MODULE DBUS_SESSION_BUS_ADDRESS"

# IBus input method support.
set-environment -g XMODIFIERS @im=ibus
set-environment -g GTK_IM_MODULE ibus
set-environment -g QT_IM_MODULE ibus
