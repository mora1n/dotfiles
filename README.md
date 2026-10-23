# Dotfiles

Personal Linux configuration managed with
[chezmoi](https://www.chezmoi.io/).

These files reflect my working environment, including local paths and installed
tools. Review the rendered changes before applying them to another machine.

## Managed configuration

| Area | Configuration |
| --- | --- |
| Shells | Zsh, Bash, Fish |
| Command-line tools | Starship, Yazi, uv, RTK |
| Terminals and workspaces | Ghostty, Alacritty, Herdr, tmux |
| Desktop applications | Zed, CopyQ, Sioyek, application launchers |
| User services | tmux, IBus |
| Helper scripts | Terminal launchers, proxy controls, Code_Aster and SALOME wrappers |

## Bootstrap

Install `git`, `curl`, and `chezmoi`, along with the applications you intend to
use. Initialize the repository, inspect the changes, and apply them:

```sh
chezmoi init mora1n/dotfiles
chezmoi diff
chezmoi apply --interactive
```

A full apply can download declared external files, run bootstrap scripts, and
remove obsolete paths listed in `.chezmoiremove`. To apply a single component:

```sh
chezmoi apply ~/.zshrc
```

After applying the Zsh configuration, explicitly install its modules:

```sh
zsh ~/.config/zsh/bootstrap.zsh
```

Run this again after changing the Zim module declarations, then start a new Zsh
session. It installs missing modules and rebuilds initialization files without
updating existing modules. Normal shell startup does not install plugins.

## Daily workflow

Pull repository updates, review the destination diff, and apply:

```sh
chezmoi git -- pull --ff-only
chezmoi diff
chezmoi apply --interactive
```

Edit a managed file through its source, then apply only that target:

```sh
chezmoi edit ~/.zshrc
chezmoi diff ~/.zshrc
chezmoi apply ~/.zshrc
```

Use `chezmoi cd` to enter the source directory, review and commit changes with
Git, then push them to the remote repository. Applying files and publishing
commits are separate steps.

## Management boundaries

- SSH configuration and credentials remain machine-local.
- Neovim configuration lives in the separate
  [`mora1n/nvim`](https://github.com/mora1n/nvim) repository.
- Zim manages downloaded modules and generated initialization files. TPM manages
  tmux plugin sources; chezmoi tracks their declarations and bootstrap script.
- Yazi's Easyjump plugin is managed by `ya pkg`; other tracked Yazi plugins and
  flavors remain in this repository.
- Shell caches and Fish universal variables remain local. See `.chezmoiignore`
  for target exclusions.

## Repository layout

Chezmoi source names encode target paths and file attributes:

```text
private_dot_config/  -> ~/.config/
private_dot_local/   -> ~/.local/
private_dot_zshrc    -> ~/.zshrc
dot_bashrc           -> ~/.bashrc
scripts/             -> ~/scripts/
run_*                -> chezmoi lifecycle scripts
```

The `executable_`, `private_`, and `readonly_` prefixes encode file permissions.
Templates use the `.tmpl` suffix. The configured `umask = 0o22` gives ordinary
files mode `0644` and executables `0755`; explicit permission attributes take
precedence. This README is repository documentation and is excluded from home
directory targets.
