# Dracula for Yazi 26.9.1

Adapted on 2026-10-20 from the requested upstream:

- Repository: https://github.com/dracula/yazi
- Commit: `1b1a8d1083474defa9e4c1c3de4db9576f23175f` (2025-11-19)
- Palette and file styles: upstream `flavor.toml`
- License: upstream MIT license, retained in `LICENSE`

The upstream file mixes older Yazi theme keys with settings that current
Yazi does not implement. This adaptation uses its Dracula palette and file
colors with the current theme schema:

- `[manager]` becomes `[mgr]`; hovered styles move to `[indicator]`.
- Mode colors use `[mode]`; notifications use `title_info/warn/error`.
- File rules use `url` instead of `name`, with full-path patterns for names.
- Specific names precede generic extensions; fallbacks are last.
- Duplicate size/duration/ratio variants become one style per pattern.
- Unsupported size, duration, ratio, regex, icon-prefix, animation, opener,
  and preview settings are omitted. Native Yazi icons remain in use.
- UI layout follows the previous compatible Dracula flavor; background,
  foreground, indicator, and remaining accents use the requested palette.

The upstream contains no syntax theme. The existing `tmtheme.xml` and its
`LICENSE-tmtheme` are retained unchanged from `yazi-rs/flavors:dracula`,
revision `1183892`; they are not files supplied by `dracula/yazi`.

This adapted flavor is maintained by chezmoi, separately from `ya`.
Current `ya pkg add` expects a `repo.yazi` repository or a `child.yazi`
package directory. The requested `dracula/yazi` repository has neither
layout, so it cannot be installed directly with `ya pkg add dracula/yazi`.
The old `yazi-rs/flavors:dracula` package entry has been removed to prevent
`ya pkg upgrade` from replacing this adaptation.

To update, pull the repository into a scratch checkout, review upstream
changes against this adaptation and the current Yazi theme schema, then
sync the reviewed flavor directory with chezmoi.
