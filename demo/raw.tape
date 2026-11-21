# "Before" clip for the video: the same PLAN.md printed raw in a terminal,
# the way you read agent-written Markdown without guniweb-md.
#
#   vhs demo/raw.tape   (from the repository root, outside herdr)

Output docs/media/before-cat-raw.mp4

Set Shell "bash"
Set Width 1600
Set Height 900
Set FontSize 17
Set Padding 16
Set Theme "Catppuccin Mocha"
Set TypingSpeed 60ms
Set CursorBlink false

Hide
Type `cd "$(sh demo/setup.sh)" && DEMO_STEP=0 sh agent.sh >/dev/null && export PS1='\[\e[34m\]\W\[\e[0m\] $ ' && clear`
Enter
Sleep 1s
Show

Sleep 800ms
Type "cat PLAN.md"
Sleep 400ms
Enter
Sleep 4s

Hide
Type "rm -rf /tmp/gmd-demo /tmp/gmd-demo-home"
Enter
