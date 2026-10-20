#!/usr/bin/env zsh
# Install missing Zim modules and rebuild their local initialization files.

_bootstrap_zim() {
  emulate -L zsh
  local ZIM_HOME=${ZIM_HOME:-$HOME/.config/zsh/.zim}
  local ZIM_CONFIG_FILE=${ZIM_CONFIG_FILE:-$HOME/.config/zsh/.zimrc}
  local zim_version=1.19.1 download_file

  if [[ ! -r $ZIM_CONFIG_FILE ]]; then
    print -u2 "Missing Zim configuration: $ZIM_CONFIG_FILE"
    return 1
  fi
  command mkdir -p -- "$ZIM_HOME" "${XDG_CACHE_HOME:-$HOME/.cache}/zsh" || return

  if [[ ! -s $ZIM_HOME/zimfw.zsh ]]; then
    download_file=$(mktemp "$ZIM_HOME/zimfw.XXXXXX") || return
    {
      command curl -fsSL \
        "https://github.com/zimfw/zimfw/releases/download/v${zim_version}/zimfw.zsh" \
        -o "$download_file" || return
      command mv -- "$download_file" "$ZIM_HOME/zimfw.zsh" || return
    } always {
      if [[ -e $download_file ]]; then
        command rm -f -- "$download_file" || return
      fi
    }
  fi

  zstyle ':zim' disable-version-check yes
  source "$ZIM_HOME/zimfw.zsh" install || return
  command rm -f -- "$ZIM_HOME/init.zsh.old" "$ZIM_HOME/login_init.zsh.old" || return
  print 'Zim is ready. Start a new Zsh session to load the configuration.'
}

_bootstrap_zim "$@"
