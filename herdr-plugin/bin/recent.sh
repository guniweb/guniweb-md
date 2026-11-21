#!/bin/sh
# Action: list the Markdown files written most recently near the focused pane
# and let the user pick one in an overlay. The pick opens through open.sh, so
# it lands in the Markdown pane next to that pane.
#
# Searched: the focused pane's git repository (or its working directory) and
# ~/.claude/plans, for files changed in the last $GMD_RECENT_DAYS days (3).

set -eu

herdr=${HERDR_BIN_PATH:-herdr}
state_dir=${HERDR_PLUGIN_STATE_DIR:-${TMPDIR:-/tmp}}
days=${GMD_RECENT_DAYS:-3}

command -v jq >/dev/null 2>&1 || { printf 'guniweb-md: jq is required\n' >&2; exit 1; }

cwd=
if [ -n "${HERDR_PANE_ID:-}" ]; then
  cwd=$("$herdr" pane get "$HERDR_PANE_ID" 2>/dev/null | jq -r '.result.pane.foreground_cwd // empty')
fi
cwd=${cwd:-$HOME}
root=$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null || printf '%s' "$cwd")

list=$state_dir/recent-${HERDR_PANE_ID:-$$}
{
  find "$root" -maxdepth 6 \
    \( -name node_modules -o -name .git -o -name target -o -name .venv -o -name vendor \
       -o -name dist -o -name build -o -path '*/.claude/worktrees' \) -prune \
    -o -type f \( -name '*.md' -o -name '*.markdown' \) -mtime "-$days" -print 2>/dev/null
  [ -d "$HOME/.claude/plans" ] &&
    find "$HOME/.claude/plans" -type f -name '*.md' -mtime "-$days" -print 2>/dev/null
} | tr '\n' '\0' | xargs -0 -r ls -t 2>/dev/null | head -n 30 > "$list" || true

# Overlays always cover the active pane, i.e. the one the key was pressed in.
"$herdr" plugin pane open --plugin "$HERDR_PLUGIN_ID" --entrypoint picker \
  --env "GMD_RECENT_LIST=$list" --env "GMD_RECENT_ROOT=$root" \
  --env "GMD_ORIGIN_PANE=${HERDR_PANE_ID:-}" >/dev/null
