#!/bin/sh
# Pane entrypoint: show $MDR_TARGET (a file or a directory) in gmd.
#
# open.sh reaches a running pane in two ways:
#   - "$state.ctl": gmd opens every path appended there as a new tab.
#   - "$state.next": a new target (e.g. a directory); open.sh quits gmd and
#     this loop restarts it on that target.

# Prefer gmd from PATH, then the copy that install-gmd.sh put into the plugin.
if ! command -v gmd >/dev/null 2>&1 && [ -x bin/gmd ]; then
  PATH=$PWD/bin:$PATH
fi

if ! command -v gmd >/dev/null 2>&1; then
  printf 'gmd (guniweb-md) is not installed on this machine.\n'
  printf 'See https://github.com/guniweb/guniweb-md#install\n\n'
  printf 'Press Enter to close this pane.'
  read -r _
  exit 1
fi

state_dir=${HERDR_PLUGIN_STATE_DIR:-${TMPDIR:-/tmp}}
state=$state_dir/viewer-${HERDR_PANE_ID:-$$}
printf '%s\n' "${MDR_TARGET:-.}" > "$state"
: > "$state.ctl"
trap 'rm -f "$state" "$state.ctl" "$state.next"' EXIT

while :; do
  gmd --control "$state.ctl" "$(cat "$state")"
  [ -f "$state.next" ] || break
  mv "$state.next" "$state"
done
