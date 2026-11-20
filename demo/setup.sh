#!/bin/sh
# Prepare an isolated herdr environment for the demo recording, so nothing
# from your own sessions, machines or files shows up on screen.
#
#   sh demo/setup.sh   (from the repository root, run by demo/demo.tape)
#
# Uses a short HOME under /tmp because herdr's socket path must stay below
# the Unix socket length limit.

set -eu

repo=$PWD
home=/tmp/gmd-demo-home
work=/tmp/gmd-demo/docs-relaunch

rm -rf "$home" /tmp/gmd-demo
mkdir -p "$home/.config/herdr" "$work"
cp demo/agent.sh "$work/agent.sh"

cat > "$home/.config/herdr/config.toml" <<'EOF'
onboarding = false

[ui]
show_agent_labels_on_pane_borders = true

[theme]
name = "catppuccin"
auto_switch = false

[[keys.command]]
key = "prefix+m"
type = "plugin_action"
command = "guniweb.md.recent"
description = "recent markdown"
EOF

HOME=$home herdr plugin link "$repo/herdr-plugin" >/dev/null
printf '%s\n' "$work"
