# VHS Tape — generates docs/demo.gif
# Compile from the repo root with:  vhs docs/demo.tape
# The visible session is rendered by docs/demo.py so timing and output stay
# stable and match the real plugin (see skills/persona/SKILL.md).

Output docs/demo.gif

# --- Look & feel ------------------------------------------------------------
Set Shell "bash"
Set FontFamily "Menlo"
Set FontSize 22
Set Width 1180
Set Height 820
Set Padding 28
Set Margin 26
Set MarginFill "#161b2e"
Set BorderRadius 12
Set WindowBar Colorful
Set TypingSpeed 55ms
Set PlaybackSpeed 1.0

Set Theme { "name": "persona", "background": "#0d1117", "foreground": "#e6edf3", "black": "#0d1117", "red": "#ff7b72", "green": "#56d364", "yellow": "#e3b341", "blue": "#79c0ff", "magenta": "#d2a8ff", "cyan": "#39c5cf", "white": "#e6edf3", "brightBlack": "#6e7681", "brightRed": "#ffa198", "brightGreen": "#56d364", "brightYellow": "#e3b341", "brightBlue": "#79c0ff", "brightMagenta": "#d2a8ff", "brightCyan": "#56d4dd", "brightWhite": "#f0f6fc", "selection": "#264f78", "cursor": "#39c5cf" }

# --- Boot the session silently ---------------------------------------------
Hide
Type "clear && python3 docs/demo.py"
Enter
Sleep 900ms
Show
Sleep 1400ms

# --- List the roster --------------------------------------------------------
Type "/persona list"
Sleep 500ms
Enter
Sleep 3400ms

# --- Summon the Auditor -----------------------------------------------------
Type "/persona auditor"
Sleep 500ms
Enter
Sleep 3800ms

# --- Drop back to default ---------------------------------------------------
Type "/persona off"
Sleep 500ms
Enter
Sleep 2600ms
