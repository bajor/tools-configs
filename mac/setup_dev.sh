#!/bin/bash

# Workspace setup script for macOS
# Run with: ./setup_workspace.sh

echo "Setting up workspace..."
echo ""

# Function to switch to desktop using Command+Number
switch_to_desktop() {
    local desktop_num=$1
    echo "  → Switching to Desktop $desktop_num"
    
    # Key codes: 18=1, 19=2, 20=3, 21=4, 23=5, 22=6
    case $desktop_num in
        1) keycode=18 ;;
        2) keycode=19 ;;
        3) keycode=20 ;;
        4) keycode=21 ;;
        5) keycode=23 ;;
        6) keycode=22 ;;
    esac
    
    osascript -e "tell application \"System Events\" to key code $keycode using command down" 2>/dev/null
    sleep 1.5
}

# Desktop 1: Ghostty + VSCode
echo "Desktop 1: Setting up Ghostty with VSCode..."
switch_to_desktop 1

osascript <<'EOF' 2>/dev/null
tell application "Ghostty"
    activate
    delay 1
end tell

tell application "System Events"
    tell process "Ghostty"
        set frontmost to true
        -- Open new window
        keystroke "t" using command down
        delay 1
        -- Type the command exactly as it works in terminal
        keystroke "current && code ."
        keystroke return
    end tell
end tell
EOF

sleep 3

# Desktop 2: Ghostty window with Cmd+Shift+F
echo "Desktop 2: Opening Ghostty window..."
switch_to_desktop 2

osascript <<'EOF' 2>/dev/null
tell application "Ghostty"
    activate
    delay 1
end tell

tell application "System Events"
    tell process "Ghostty"
        set frontmost to true
        -- Create new window
        keystroke "t" using command down
        delay 1
        -- Run Cmd+Shift+F (likely fullscreen or some Ghostty feature)
        keystroke "f" using {command down, shift down}
    end tell
end tell
EOF

sleep 2

# Desktop 3: Safari with AI tabs
echo "Desktop 3: Opening Safari with AI tabs..."
switch_to_desktop 3

osascript <<'EOF' 2>/dev/null
tell application "Safari"
    activate
    delay 1
end tell

tell application "System Events"
    tell process "Safari"
        set frontmost to true
        
        -- Create new window
        keystroke "n" using command down
        delay 1
        
        -- Open first URL (Claude)
        keystroke "l" using command down
        delay 0.5
        keystroke "https://claude.ai/new"
        keystroke return
        delay 3
        
        -- Open second tab (ChatGPT)
        keystroke "t" using command down
        delay 0.5
        keystroke "https://chatgpt.com"
        keystroke return
        delay 2
        
        -- Open third tab (Gemini)
        keystroke "t" using command down
        delay 0.5
        keystroke "https://gemini.google.com/app?hl=pl"
        keystroke return
        delay 2
        
        -- Switch back to first tab (Claude)
        keystroke "1" using command down
    end tell
end tell
EOF

sleep 2

# Desktop 4: Spotify - ENSURE it's on Desktop 4
echo "Desktop 4: Opening Spotify..."
switch_to_desktop 4

# Kill any existing Spotify first to ensure it opens on this desktop
osascript <<'EOF' 2>/dev/null
tell application "System Events"
    if exists (process "Spotify") then
        tell application "Spotify" to quit
        delay 1
    end if
end tell

-- Now open Spotify fresh on this desktop
tell application "Spotify"
    activate
end tell

-- Make sure it's really on this desktop
delay 1
tell application "System Events"
    tell process "Spotify"
        set frontmost to true
    end tell
end tell
EOF

sleep 2

# Desktop 5: Safari with empty tab
echo "Desktop 5: Opening Safari with empty tab..."
switch_to_desktop 5

osascript <<'EOF' 2>/dev/null
tell application "Safari"
    activate
    delay 1
end tell

tell application "System Events"
    tell process "Safari"
        set frontmost to true
        
        -- Create new window
        keystroke "n" using command down
        delay 0.5
        
        -- Open new empty tab
        keystroke "t" using command down
    end tell
end tell
EOF

sleep 1

# Desktop 6: Docker Desktop
echo "Desktop 6: Opening Docker Desktop..."
switch_to_desktop 6

# Try to open Docker Desktop with various methods
osascript <<'EOF' 2>/dev/null
try
    tell application "Docker Desktop" to activate
on error
    try
        tell application "Docker" to activate
    on error
        do shell script "open -a Docker || open -a 'Docker Desktop' || true"
    end try
end try
EOF

sleep 5

# Return to Desktop 1
echo "Returning to Desktop 1..."
switch_to_desktop 1

echo ""
echo "✓ Workspace setup complete!"
echo ""
echo "Summary:"
echo "  Desktop 1: Ghostty → VSCode (current && code .)"
echo "  Desktop 2: Ghostty (with Cmd+Shift+F)"
echo "  Desktop 3: Safari (Claude, ChatGPT, Gemini)"
echo "  Desktop 4: Spotify"
echo "  Desktop 5: Safari (empty tab)"
echo "  Desktop 6: Docker Desktop"
