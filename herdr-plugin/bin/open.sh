#!/bin/sh
# Action: open a Markdown file (from a link click or an argument) or browse the
# focused pane's working directory in a split pane next to it.
#
#   sh bin/open.sh [PATH]       open PATH, or the clicked URL from a link handler
#   sh bin/open.sh --browse     open the directory tree of the focused pane's cwd
#   sh bin/open.sh --existing-only PATH
#                               hand PATH to an open Markdown pane, never open one
#
# A Markdown pane that already exists in the same tab is reused: files open
# there as a new tab, and unsaved changes in that pane are never touched.

set -eu

herdr=${HERDR_BIN_PATH:-herdr}
state_dir=${HERDR_PLUGIN_STATE_DIR:-${TMPDIR:-/tmp}}
log() { printf 'guniweb-md: %s\n' "$*" >&2; }

command -v jq >/dev/null 2>&1 || { log "jq is required"; exit 1; }

# Percent-decode a URL path (file:///a%20b.md -> /a b.md).
urldecode() {
  printf '%b' "$(printf '%s' "$1" | sed 's/+/ /g; s/%\([0-9A-Fa-f][0-9A-Fa-f]\)/\\x\1/g')"
}

pane_field() {
  [ -n "${HERDR_PANE_ID:-}" ] || return 0
  "$herdr" pane get "$HERDR_PANE_ID" 2>/dev/null | jq -r ".result.pane.$1 // empty"
}

existing_only=false
if [ "${1:-}" = "--existing-only" ]; then
  existing_only=true
  shift
fi

if [ "${1:-}" = "--browse" ]; then
  target=$(pane_field foreground_cwd)
  target=${target:-$PWD}
else
  raw=${1:-${HERDR_PLUGIN_CLICKED_URL:-}}
  [ -n "$raw" ] || { log "no file given"; exit 2; }

  path=${raw%%[#?]*}
  case $path in
    file://*)
      path=${path#file://}
      # Drop the host part of file://host/path.
      case $path in /*) ;; *) path=/${path#*/} ;; esac
      path=$(urldecode "$path")
      ;;
  esac
  # Strip editor-style :line[:col] suffixes.
  while :; do
    case $path in *:[0-9]|*:[0-9][0-9]|*:[0-9][0-9][0-9]|*:[0-9][0-9][0-9][0-9]) path=${path%:*} ;; *) break ;; esac
  done
  case $path in
    "~/"*) path=$HOME/${path#\~/} ;;
    /*) ;;
    *) base=$(pane_field foreground_cwd); path=${base:-$PWD}/$path ;;
  esac
  [ -e "$path" ] || { log "file not found: $path"; exit 1; }
  target=$path
fi

# Reuse a Markdown pane of ours in the same tab. A file is handed to the
# running gmd, which opens it as a new tab (or once editing ends). A directory
# needs a restart, which only happens while gmd is not editing.
tab=$(pane_field tab_id)
if [ -n "$tab" ]; then
  for pane in $("$herdr" pane list 2>/dev/null |
    jq -r --arg tab "$tab" '.result.panes[] | select(.tab_id == $tab and .label == "Markdown") | .pane_id'); do
    state=$state_dir/viewer-$pane
    [ -f "$state" ] || continue
    if [ -f "$target" ] && [ -f "$state.ctl" ]; then
      printf '%s\n' "$target" >> "$state.ctl"
      # Make it visible where an explicit open went; follow mode stays quiet.
      if [ "$existing_only" = false ]; then
        "$herdr" notification show "Markdown" --body "$(basename "$target") opened in the Markdown pane" \
          --position bottom-right --sound none >/dev/null 2>&1 || true
      fi
      exit 0
    fi
    [ "$existing_only" = false ] || continue
    # The status line starts with gmd's mode, e.g. " VIEWER  | ...".
    mode=$("$herdr" pane read "$pane" --source visible --lines 1 2>/dev/null | awk '{print $1; exit}')
    case $mode in
      TREE|VIEWER) ;;
      SEARCH) "$herdr" pane send-keys "$pane" esc >/dev/null ;;
      *) continue ;;
    esac
    printf '%s\n' "$target" > "$state.next"
    "$herdr" pane send-keys "$pane" q >/dev/null
    exit 0
  done
fi

[ "$existing_only" = false ] || exit 0

# The pane command is relative to the plugin root, so no --cwd here.
set -- plugin pane open --plugin "$HERDR_PLUGIN_ID" --entrypoint viewer \
  --placement split --direction right --env "MDR_TARGET=$target" --no-focus
if [ -n "${HERDR_PANE_ID:-}" ]; then
  set -- "$@" --target-pane "$HERDR_PANE_ID"
fi
"$herdr" "$@" >/dev/null
