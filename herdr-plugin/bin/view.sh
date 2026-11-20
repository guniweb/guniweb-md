#!/bin/sh
# Pane entrypoint: show $MDR_TARGET (a file or a directory) in gmd.
#
# The pane stays reusable: open.sh writes a new target to "$state.next" and
# quits gmd, and this loop restarts it on the new target.

if ! command -v gmd >/dev/null 2>&1; then
  printf 'gmd (guniweb-md) is not installed on this machine.\n'
  printf 'See https://github.com/guniweb/guniweb-md#installation\n\n'
  printf 'Press Enter to close this pane.'
  read -r _
  exit 1
fi

state_dir=${HERDR_PLUGIN_STATE_DIR:-${TMPDIR:-/tmp}}
state=$state_dir/viewer-${HERDR_PANE_ID:-$$}
printf '%s\n' "${MDR_TARGET:-.}" > "$state"
trap 'rm -f "$state" "$state.next"' EXIT

while :; do
  gmd "$(cat "$state")"
  [ -f "$state.next" ] || break
  mv "$state.next" "$state"
done
