<p>
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="assets/logo-dark.svg">
    <img src="assets/logo.svg" alt="GuniWeb md" width="294">
  </picture>
</p>

# guniweb-md

Read **and** edit Markdown right next to your coding agent.

Coding agents such as Claude Code or Codex write plans, handoffs and notes as
Markdown files. `guniweb-md` gives you one place to read them nicely rendered
and to change them, without leaving the terminal and without a heavyweight
editor:

- **`gmd`**, a terminal Markdown viewer and editor. Press `i` for hybrid live
  preview: everything stays rendered except the block under your cursor.
  Tables, Mermaid diagrams, math, search, tabs and a file tree included.
- **A [herdr](https://herdr.dev) plugin.** Ctrl+click a `.md` link in your
  agent's output and the file opens in a split pane next to the agent. The
  pane reloads live while the agent keeps writing, and it is reused for the
  next file you click.

It works the same on your laptop and on remote machines you reach through
herdr, because it runs entirely in the terminal.

## Status

Early and private. Built and tested on macOS with iTerm2 and herdr 0.9.5.

## Install

Build from source (Rust stable, edition 2024):

```sh
cargo install --path . --locked
```

This installs the `gmd` binary into `~/.cargo/bin`.

### herdr plugin

```sh
herdr plugin link /path/to/guniweb-md/herdr-plugin
```

The plugin needs `gmd` and `jq` on the machine where the herdr server runs.

### Make Ctrl+click reach herdr

Two one-time settings are needed so that a Ctrl+click on a file link arrives
at the plugin:

1. **iTerm2:** Settings → Pointer → General → enable
   *"Ctrl-click is reported to apps, does not open menu"*. Otherwise iTerm2
   turns Ctrl+click into a right click.
2. **Clickable links from your agent:** inside herdr, `TERM_PROGRAM` is
   `herdr`, which most tools do not recognise as hyperlink-capable. Force
   OSC 8 links in your shell profile:

   ```sh
   [ "$TERM_PROGRAM" = herdr ] && export FORCE_HYPERLINK=1
   ```

   Restart the agent afterwards. herdr forwards only real OSC 8 `file://`
   links to plugins, not plain paths.

## Using it

| Where | Key | Action |
|---|---|---|
| Agent output | Ctrl+click on a `.md` link | Open the file in the Markdown pane |
| Markdown pane | `i` | Edit in hybrid live preview |
| Editing | `Esc` then `:w` / `:x` / `:wq` / `:q!` | Save / save if changed and stop editing / save and stop / discard |
| Editing | `:` | Just a colon: type `Note:`, `12:30` or `:)` freely |
| Markdown pane | `q` | Close the pane |
| Markdown pane | `?` | All keyboard shortcuts |

A pane that you are editing is never restarted: a click then opens a second
pane, so unsaved changes are safe.

## Credits

`gmd` is a fork of [markdown-reader](https://github.com/leboiko/markdown-reader)
by leboiko, used under the MIT license. Its full documentation is kept in
[docs/UPSTREAM-README.md](docs/UPSTREAM-README.md). Changes made in this fork
are listed in [CHANGELOG.md](CHANGELOG.md).

## License

MIT, see [LICENSE](LICENSE).
