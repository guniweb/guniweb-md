# Follow-mode recording: with the Markdown pane open, every Markdown file the
# agent writes appears there as a new tab, without any key press.
#
#   cargo build --release && vhs demo/follow.tape   (from the repository root, outside herdr)

Output docs/media/follow-raw.mp4

Set Shell "bash"
Set Width 1600
Set Height 900
Set FontSize 17
Set Padding 16
Set Theme "Catppuccin Mocha"
Set TypingSpeed 45ms
Set CursorBlink false

Hide
Type `unset HERDR_ENV HERDR_PANE_ID HERDR_TAB_ID HERDR_WORKSPACE_ID HERDR_SOCKET_PATH HERDR_BIN_PATH; export TERM_PROGRAM=vhs FORCE_HYPERLINK=1 PATH="$PWD/target/release:$PATH" GMD_FOLLOW="$PWD/herdr-plugin/bin/follow.sh"`
Enter
Type `cd "$(sh demo/setup.sh)" && cp "$OLDPWD/demo/agent-follow.sh" . && DEMO_STEP=0 sh agent.sh >/dev/null && export HOME=/tmp/gmd-demo-home && clear`
Enter
Sleep 1s
Type "herdr --session demo"
Enter
Sleep 4s
# Open PLAN.md in the Markdown pane first (Ctrl+b m, Enter), then clear.
Ctrl+b
Type "m"
Sleep 2s
Enter
Sleep 3s
Type "clear"
Enter
Sleep 1s
Show

Sleep 1.5s
Type "sh agent-follow.sh"
Sleep 400ms
Enter
Sleep 2s
Screenshot docs/media/follow-notes.png
Sleep 3s
Screenshot docs/media/follow-handoff.png
Sleep 3s

Hide
Ctrl+b
Type "q"
Sleep 1s
Type "HOME=/tmp/gmd-demo-home herdr server stop >/dev/null 2>&1; rm -rf /tmp/gmd-demo /tmp/gmd-demo-home"
Enter
Sleep 1s
