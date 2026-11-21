#!/bin/sh
# Claude Code PostToolUse hook: when the agent writes or edits a Markdown file,
# show it in the Markdown pane that is already open next to the agent.
#
# It never opens a pane on its own: no open Markdown pane, no effect. Close the
# pane (q) to stop following. Works on remote machines too, because the hook
# runs where the agent runs.
#
# Install in ~/.claude/settings.json (adjust the path):
#   "hooks": { "PostToolUse": [ { "matcher": "Write|Edit|MultiEdit",
#     "hooks": [ { "type": "command",
#                  "command": "sh /path/to/guniweb-md/herdr-plugin/bin/follow.sh" } ] } ] }

[ -n "${HERDR_PANE_ID:-}" ] || exit 0
command -v jq >/dev/null 2>&1 || exit 0

file=$(jq -r '.tool_input.file_path // empty' 2>/dev/null)
case $file in
  *.md | *.markdown | *.MD) ;;
  *) exit 0 ;;
esac
[ -f "$file" ] || exit 0

root=$(cd "$(dirname "$0")/.." && pwd)
export HERDR_PLUGIN_ID=${HERDR_PLUGIN_ID:-guniweb.md}
export HERDR_PLUGIN_STATE_DIR=${XDG_STATE_HOME:-$HOME/.local/state}/herdr/plugins/$HERDR_PLUGIN_ID
cd "$root" && sh bin/open.sh --existing-only "$file" >/dev/null 2>&1
exit 0
