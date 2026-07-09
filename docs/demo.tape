# VHS Tape — Generates docs/demo.gif
# Compile with: vhs docs/demo.tape

Output docs/demo.gif

Set FontSize 18
Set FontFamily "SF Mono"
Set Width 1200
Set Height 600
Set Padding 20
Set Theme "Builtin Dark"
Set PlaybackSpeed 1.0

# Start a Claude Code session
Type "claude"
Sleep 500ms
Enter
Sleep 3.5s

# List the available experts
Type "/persona list"
Sleep 1s
Enter
Sleep 2.5s

# Summon the Auditor
Type "/persona auditor"
Sleep 1s
Enter
Sleep 4s

# Clean up and exit
Type "/persona off"
Sleep 1s
Enter
Sleep 2s
Type "exit"
Sleep 500ms
Enter
Sleep 1s
