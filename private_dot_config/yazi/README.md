# Yazi configuration

Reviewed against Yazi / ya 26.9.1 on Linux, 2026-10-20.

## Opening files

The first opener is used by `o`, Enter, or smart-enter (`l` on a file).
Press `O` to choose another matching opener. Press `g`, then `o` to use
the system default directly, including all selected files on Linux.

| File type | Default action | Alternatives in `O` |
| --- | --- | --- |
| Images, including SVG | qView | System default, parent directory |
| PDF | System default (Evince on this host) | Parent directory |
| Text, source, configuration, Markdown | Neovim | System default for custom extension rules, parent directory |
| HTML | Neovim | System default browser (Chrome on this host), parent directory |
| Audio / video | System default (GNOME Videos on this host) | Parent directory |
| Office / OpenDocument / RTF | System default (LibreOffice on this host) | Parent directory |
| EPUB | System default | Parent directory |
| ZIP / TAR / GZip / BZip2 / XZ / Zstd / 7z / RAR / JAR | ouch extraction | Built-in extraction, system default, parent directory |
| Other archives supported by Yazi | Built-in extraction | Parent directory |
| Unknown files | System default | Parent directory |

System defaults come from XDG associations; this configuration does not
change them. An association and application must exist for the chosen type.
Ouch uses its normal extraction layout, including archive subdirectories.

Custom open rules extend the presets. Virtual files requiring download and
trash entries are handled before extension rules. MIME subtypes use Yazi's
normalized names (`application/tar`, not `application/x-tar`).

## Shortcuts

- `J` / `K`: move between sibling directories in the parent panel.
- `F`: smart filter.
- `c`, then `m`: chmod selected files.
- `C`: compress selected files with ouch.
- `p`: paste into the hovered directory, or the current directory.
- `i`: show Easyjump hints, then type the displayed one- or two-letter label
  to jump to a visible file. Escape cancels the jump.
- `1` through `9`: use Yazi's preset tab-switching shortcuts.
- `t`, then `t`: create a tab.
- `T`: close the current tab.
- `q`: confirm before quitting when multiple tabs are open.
- `!`: start an interactive shell in the current directory.
- `g`, then `v`: show changed and untracked Git files; `Ctrl+s` cancels this
  search view and returns to its original directory.
- `c`, then `p`: copy a unified diff of the first selected file and the
  hovered file to the clipboard. Select one file with Space, hover another,
  then run the shortcut. This copies a patch; it does not launch an editor.
- `g`, then `p`: hide/restore the preview pane.
- `g`, then `P`: maximize/restore the preview pane.

Git status appears automatically in repository file lists: `?` untracked,
`M` unstaged, `S` staged, `A` added, `D` deleted, `U` conflict/updated, and
`i` ignored. Statuses also propagate to directories. Clean files have no sign.
Git fetchers match `regular://` paths only. The current official plugin
passes its URL directly as the Git working directory, which fails for
`search://` results; remote and virtual URLs also need separate handling.
The Git changes view therefore lists the files without running this fetcher.

## Plugins and maintenance

`package.toml` records 14 plugins and the Dracula flavor managed by `ya`.
Use `ya pkg install` to restore the recorded dependencies and `ya pkg upgrade`
to update them; review the changes, then sync only Yazi files with chezmoi.
The `rev` and `hash` fields are generated installation records. None of the
revisions use the `=` prefix that prevents `ya pkg upgrade` from updating a
package.

The new official plugins are `git`, `vcs-files`, `diff`, and `toggle-pane`.
The existing `smart-enter`, `smart-paste`, `smart-filter`, `chmod`, `mount`,
`full-border`, `piper`, `ouch`, and `starship` remain in use. Their current
features fit this configuration without changing file operation semantics.

Reviewed alternatives on 2026-10-20:

- `augment-command` consolidates several behaviors but would change the
  existing selection, navigation, and archive workflows; not installed.
- `faster-piper` adds preview caching. Keep `piper` for the current eza
  directory tree until a measured preview performance problem warrants it.
- `mime-ext` replaces content-based MIME detection with an extension
  database; not installed. Its current standard `setup()` reads `f.run`,
  while this host's Yazi exposes `f.name`, so the setup leaves the built-in
  fetchers unchanged. Testing the local backend through an explicit fetcher
  rule also showed accuracy costs: it misses an extensionless PDF and
  assigns JSON to a TOML `Cargo.lock`. `fallback_file1 = true` restores
  unknown-extension detection, but does not correct a known, misleading
  extension or a wrong database entry.
- `term-cwd` is optional terminal integration; not installed. It reports
  the browsed directory through OSC7 on Unix. This is distinct from the
  existing Fish `y` wrapper, which changes the shell directory on exit.
  It can help a compatible terminal inherit the browsed directory when
  opening a pane/tab. In a multiplexer that benefit depends on its OSC
  handling. The tested plugin emits spaces and URI delimiters unescaped,
  and also reports search URLs as local file URIs.
- `jump-to-char` is optional navigation convenience; not installed. Its
  official package is `yazi-rs/plugins:jump-to-char`. Tests confirmed that
  it jumps between names starting with a chosen character and shares
  Yazi's finder, including `n`/`N`. Built-in `/` with a query such as `^a`
  already provides that navigation. The plugin accepts ASCII letters,
  digits, and dot; its example `f` binding would replace the current
  filter. `g`, then `f` is also occupied by the built-in symlink follow.
- `yatline` overlaps the existing starship/status bar; not installed.
- `bunny` is a useful lightweight bookmark menu, but its directory symlink
  in `test/plugins` cannot be materialized by this version of `ya`.
  `dedukun/bookmarks` still calls the removed `ya.mgr_emit` API, and `yamb`
  dereferences the hovered entry before checking for an empty directory.
  These candidates are not installed. Built-in `z` (fzf), `Z` (zoxide), and
  `g` directory shortcuts remain available.

Dracula now comes directly from `yazi-rs/flavors:dracula`, installed with
`ya pkg add yazi-rs/flavors:dracula` and recorded in `package.toml`.
The flavor files are unmodified upstream files; the previous custom
`dracula/yazi` adaptation has been replaced. Both dark and light terminal
modes select Dracula. Git status styles remain in `theme.toml`, outside
the managed flavor, so a package update can preserve those overrides.

Easyjump replaces `relative-motions`. Install it with
`ya pkg add mikavilpas/easyjump.yazi:easyjump`; initialize it with
`require("easyjump"):setup()`. It uses upstream defaults and is updated by
`ya pkg upgrade`, without a manually selected tag or commit.

Chezmoi manages the Easyjump dependency declaration, initialization, and
key binding. Its installed source directory is ignored by chezmoi and stays
under `ya pkg` management. The obsolete `relative-motions` source is removed
when applying this configuration.

## Preview dependencies

Configured tools present on this host include `eza`, `ouch`, `starship`,
`file`, `ffmpeg`, `pdftoppm`, and `7z`.

SVG rendering requires `resvg`. AVIF / HEIC / JPEG XL and font previews can
require ImageMagick (`magick`). Neither renderer was installed during this
configuration update. External image opening and PDF opening use their
respective desktop applications and are separate from terminal previews.
