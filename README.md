# Dotfiles

Personal configuration files managed with
[chezmoi](https://www.chezmoi.io/).

This repository is an environment snapshot rather than a portable installer.
Review the rendered diff before applying it to a new machine because some files
depend on operating-system packages, locally installed tools, and
machine-specific paths.

## Managed configuration

The repository contains configuration for:

- shells and command-line tools
- terminals and desktop applications
- user services
- local helper scripts

SSH configuration and credentials are intentionally machine-local and are not
managed by this repository.

Neovim configuration is managed by the standalone
[`mora1n/nvim`](https://github.com/mora1n/nvim) repository. tmux plugin sources
are installed by TPM from the declarations in `40-plugins.tmux`; this repository
only manages tmux's own configuration and plugin bootstrap script.

Herdr's Auto Title plugin is installed from the latest stable release when its
chezmoi installer runs. An existing installation with the same release commit
is reused. The installer replaces Automatic Rename before its old configuration
is removed. Plugin checkouts and runtime state remain managed by Herdr.

Auto Title polls once per second and names tabs and panes from their project,
branch, foreground activity, and agent task. The agent sidebar displays each
pane's generated name on its second row through the `pane` token. Workspace
topics and tab-number prefixes are disabled. Claude transcript reading is
enabled for sessions that do not supply a terminal title.

Changing the managed Auto Title configuration restarts the plugin on the next
full `chezmoi apply`. To apply only its settings and restart it:

```sh
chezmoi apply --parent-dirs ~/.config/herdr-auto-title/config.env \
  ~/configure-herdr-auto-title.sh
```

To restart the plugin manually:

```sh
herdr plugin action invoke herdr.auto-title.restart
```

To install a newer stable release, rerun the installer and startup scripts:

```sh
set -o pipefail
chezmoi execute-template --file \
  "$(chezmoi source-path)/run_onchange_before_install-herdr-auto-title.sh.tmpl" | bash
chezmoi execute-template --file \
  "$(chezmoi source-path)/run_onchange_after_configure-herdr-auto-title.sh.tmpl" | bash
```

The first start applies generated names to existing panes. Later manual names
are preserved; clearing a pane or tab name returns it to automatic naming.

Zim installs Zsh plugins from the managed module declarations. Plugin sources,
generated initialization files, and compiled completion caches stay local.

## Bootstrap

Install `git` and `chezmoi`, then initialize the repository:

```sh
chezmoi init mora1n/dotfiles
```

Inspect the destination changes before applying them:

```sh
chezmoi diff
chezmoi apply --interactive
```

For an existing checkout, update and review first:

```sh
chezmoi update --dry-run
chezmoi diff
chezmoi update --interactive
```

Do not run an unreviewed full apply on a machine that already has local
configuration. Apply individual targets when only one component is needed:

```sh
chezmoi apply ~/.zshrc
```

After applying the Zsh configuration on a new machine, initialize its plugins:

```sh
zsh ~/.config/zsh/bootstrap.zsh
```

Run the same command after changing the Zim module declarations, then start a
new Zsh session. It installs missing modules and rebuilds initialization files
without updating already installed plugins. Normal shell startup does not
download or install plugins.

## Repository layout

Chezmoi source names encode target paths and file attributes:

```text
private_dot_config/  -> ~/.config/
private_dot_local/   -> ~/.local/
private_dot_zshrc    -> ~/.zshrc
dot_bashrc           -> ~/.bashrc
scripts/             -> ~/scripts/
```

Files prefixed with `executable_` are rendered with executable permissions;
files or directories prefixed with `private_` are rendered with private
permissions according to chezmoi's source-state conventions.

The repository configures chezmoi with `umask = 0o22`, so ordinary managed
files and executable files are rendered as `0644` and `0755`, respectively.
