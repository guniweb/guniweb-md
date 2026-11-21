# guniweb-md – rules for coding agents

> Read by every harness: Claude Code (via `CLAUDE.md` = `@AGENTS.md`), Codex, OpenCode and Pi.

## Project
- **Product:** guniweb-md, a GuniWeb product. Terminal Markdown viewer/editor `gmd` plus a herdr
  plugin that opens agent-written `.md` files next to the agent.
- **Owner:** Jonas Härtfelder (product decisions, releases, publishing).
- **Origin:** fork of [markdown-reader](https://github.com/leboiko/markdown-reader) by leboiko (MIT).
  Keep the license and credit intact. The remote `upstream` points there; merge it regularly.

## Layout
| Path | What |
|---|---|
| `src/` | `gmd` (Rust, edition 2024). `src/fs/control.rs` = `--control` file for open requests |
| `crates/mermaid-text/` | upstream library crate, leave untouched unless needed |
| `herdr-plugin/` | herdr plugin `guniweb.md`: `open.sh`, `view.sh`, `recent.sh`, `pick.sh`, `install-gmd.sh` |
| `demo/` | scripted VHS recording (`demo.tape`, `setup.sh`, `agent.sh`) for README media |
| `docs/media/` | README screenshots (raw recordings are git-ignored) |
| `assets/` | logo (`logo.svg`, `logo-dark.svg`, `mark.svg`) in the GuniWeb Match style |

## Commands
| Purpose | Command |
|---|---|
| Toolchain (macOS) | `export PATH=/opt/homebrew/opt/rustup/bin:$PATH` (rustup is keg-only) |
| Checks before every commit | `cargo fmt --all && cargo clippy --all-targets --all-features -- -D warnings && cargo test --all-targets` |
| Local install | `cargo build --release && install -m 755 target/release/gmd ~/.local/bin/gmd` |
| Plugin (dev) | `herdr plugin link "$PWD/herdr-plugin"` |
| Demo media | `vhs demo/demo.tape` **outside** a herdr pane (herdr refuses nested sessions), e.g. `env -u HERDR_ENV -u HERDR_PANE_ID -u HERDR_TAB_ID -u HERDR_WORKSPACE_ID -u HERDR_SOCKET_PATH -u HERDR_BIN_PATH vhs demo/demo.tape` |
| Release | tag `vX.Y.Z` → `.github/workflows/release.yml` builds Linux + macOS archives and `SHA256SUMS`. Keep `herdr-plugin/herdr-plugin.toml` `version` equal to the release version (`install-gmd.sh` downloads that tag). |

## Rules
- Code, comments, commits and docs in **English**.
- **No AI attribution** in commits, PRs or comments (no `Co-Authored-By: Claude`, no "Generated with").
- Every behaviour change gets a test and a `CHANGELOG.md` entry under `[Unreleased]`.
- Snapshot files are named after the binary (`gmd__*.snap`).
- Pushing, tagging releases and changing repository visibility only after Jonas says so.
- No secrets, no personal data in tests, fixtures, demo media or screenshots.

## Known constraints
- Claude Code writes files atomically (new inode per edit); reload must follow the path, not the inode.
- Hybrid editing is modeless: a bare `:` is text, commands start with `Esc` then `:`.
- herdr forwards only OSC 8 `file://` links to plugin link handlers (not plain paths), only on
  Ctrl+click, and not on remote machines yet (herdr issue #4447). `Ctrl+b m` works everywhere.
- Ctrl+click needs iTerm2 "Ctrl-click is reported to apps" and `FORCE_HYPERLINK=1` inside herdr.
