# Demo recording for the README: an agent writes PLAN.md in herdr, the
# Markdown pane opens next to it, reloads live, and the plan gets edited.
#
#   cargo build --release && vhs demo/demo.tape   (from the repository root)
#
# Needs herdr and vhs. demo/setup.sh isolates HOME, so no personal sessions,
# machines or files appear in the recording.

Output docs/media/demo-raw.mp4

Set Shell "bash"
Set Width 1600
Set Height 900
Set FontSize 17
Set Padding 16
Set Theme "Catppuccin Mocha"
Set TypingSpeed 45ms
Set CursorBlink false

Hide
Type `unset HERDR_ENV HERDR_PANE_ID HERDR_TAB_ID HERDR_WORKSPACE_ID HERDR_SOCKET_PATH HERDR_BIN_PATH; export TERM_PROGRAM=vhs FORCE_HYPERLINK=1 PATH="$PWD/target/release:$PATH"`
Enter
Type `cd "$(sh demo/setup.sh)" && export HOME=/tmp/gmd-demo-home PS1='$ ' && clear`
Enter
Sleep 1s
Type "herdr --session demo"
Enter
Sleep 4s
Show

# The agent writes the plan.
Sleep 1s
Type "sh agent.sh"
Sleep 400ms
Enter
Sleep 2.5s

# Open the most recent Markdown next to the agent: Ctrl+b, then m.
Ctrl+b
Type "m"
Sleep 2s
Screenshot docs/media/recent-picker.png
Sleep 1s
Enter
Sleep 6s
Screenshot docs/media/split-live-reload.png
Sleep 1s

# Move into the Markdown pane and edit in hybrid live preview.
Ctrl+b
Type "l"
Sleep 1s
Type "i"
Sleep 1s
Down 2
Ctrl+E
Sleep 500ms
Type " – reviewed :)"
Sleep 1.5s
Screenshot docs/media/hybrid-editing.png
Escape
Sleep 300ms
Type ":x"
Sleep 600ms
Enter
Sleep 2.5s
Screenshot docs/media/saved.png
Sleep 1s

Hide
Ctrl+b
Type "q"
Sleep 1s
Type "HOME=/tmp/gmd-demo-home herdr server stop >/dev/null 2>&1; rm -rf /tmp/gmd-demo /tmp/gmd-demo-home"
Enter
Sleep 1s
