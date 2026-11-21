#!/bin/sh
# Stand-in for a coding agent in the follow-mode recording: writes two more
# Markdown files and, like Claude Code's PostToolUse hook would, hands each one
# to follow.sh, which adds it as a tab to the Markdown pane that is open.

set -eu

follow=${GMD_FOLLOW:?path to herdr-plugin/bin/follow.sh}
step() { sleep "${DEMO_STEP:-2.5}"; }

write() {
  tmp=$(mktemp "$PWD/.md.XXXXXX")
  cat > "$tmp"
  mv "$tmp" "$PWD/$1"
  printf '{"tool_name":"Write","tool_input":{"file_path":"%s"}}' "$PWD/$1" | sh "$follow"
}

printf '\033[2m› Write the launch notes and a handoff for tomorrow\033[0m\n\n'
printf '● Writing NOTES.md\n'
write NOTES.md <<'EOF'
# Launch notes

- Freeze content on **Thursday**
- Search index rebuild takes ~20 min
- Old URLs redirect via the edge proxy

> Ask Design for the final navigation labels.
EOF
step

printf '● Writing HANDOFF.md\n'
write HANDOFF.md <<'EOF'
# Handoff – Friday

## Done

- [x] Plan reviewed
- [x] Launch notes written

## Next

- [ ] Rebuild the search index
- [ ] Test the redirects
EOF
printf '\n● Both files are open next to me.\n'
