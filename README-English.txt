=====================================================================
  MOUSE SIDE PANEL FOR UNREAL WORLD  (urw-panel.ahk)
=====================================================================

A panel of buttons that sits in one of the black bars at the sides of
the game (UnReal World is drawn in 4:3). Each button sends the real key
to the game without taking focus away from it, so you can play almost
everything with the mouse.


---------------------------------------------------------------------
 INSTALLING AND STARTING
---------------------------------------------------------------------

1. Install AutoHotkey v2 (https://www.autohotkey.com).
2. Open UnReal World.
3. Double-click urw-panel.ahk.

The panel appears on the right side. To close it: the "Close" button,
or right-click the green "H" icon in the system tray → Exit.

The panel starts in Spanish; click the 🌐 button until it shows
"English". The choice is remembered.


---------------------------------------------------------------------
 LAYOUT
---------------------------------------------------------------------

At the top are the panel buttons (they don't send keys to the game,
except Help, Save and Quit game):

   [ 🔒 Lock ]  [ ⇄ Side  ]  [ 🌐 Language  ]
   [ Hide    ]  [ Close   ]  [ Help        ]
   [ Save    ]  [ Quit game ] [ Reset      ]

Below them is a status line showing the last key sent (for example
"Inventory → i") or what to do in each mode.

Then come the game buttons, from least used (top) to most used
(bottom). Each group has its own color:

   Lime green ...... menus (inventory, skills, craft…)
   Cyan ............ information (armour, profile, map, F1…)
   Gray ............ survival (eat, drink, fire, sleep…)
   Yellow .......... wait, look, examine, zoom
   Red ............. combat and hunting
   Brown ........... activity (pick up, drop, open, run…)
   Orange .......... single keys (4, 5, 6, 8, Tab, PgUp, PgDn)
   Blue ............ movement and turning
   Magenta ......... Space and Enter
   White ........... Esc

Space, Enter and Esc are at the very bottom, larger.


---------------------------------------------------------------------
 USAGE
---------------------------------------------------------------------

- Click a button = that key is pressed in the game.
- Holding the button down repeats the key for: arrows, sidesteps,
  wait one turn, zoom and + / −.
- "Save" (Ctrl+S) and "Quit game" (Shift+Q) ask for confirmation
  before sending the key.
- Middle click (the mouse wheel) = Esc, but only while the game is
  the active window.


---------------------------------------------------------------------
 THE PADLOCK: MOVING AND PAINTING BUTTONS
---------------------------------------------------------------------

Each click on the padlock moves to the next mode:

   🔒 Lock  →  🔓 Edit  →  🎨 Colors  →  🔒 Lock

While the padlock is not closed, the buttons do NOT send keys.

🔓 EDIT (rearrange buttons)
   The panel background turns dark red.
   1. Click a button: it is highlighted in green.
   2. Click another button (or an empty "·" cell): they swap places.
   Wide buttons (Space, Esc) can also be moved; if they don't fit in
   the chosen spot, "Doesn't fit there" appears.
   "Reset" restores the original order.

🎨 COLORS (paint buttons)
   The panel background turns dark blue and a palette appears below
   the status line.
   1. Click a color in the palette: it gets a ✓ mark.
   2. Click the buttons you want to paint. You can paint several in a
      row with the same color.
   - The ↺ square gives each button you click its original color back.
   - The text color (black or white) is chosen automatically to match
     the background.
   - "Reset", in this mode, restores ALL colors to the originals.
   All game buttons can be painted, and so can Help, Save and Quit
   game. The buttons that control the panel (padlock, Side, Language,
   Hide, Close, Reset) can't be painted: clicking them performs their
   action.

Changes to positions and colors are saved automatically.


---------------------------------------------------------------------
 OTHER PANEL BUTTONS
---------------------------------------------------------------------

⇄ Side ....... moves the panel to the other side of the screen.
🌐 Language ... cycles between Spanish, English, Finnish, Portuguese
               and Italian. (The tray menu stays in the language the
               script started with.)
Hide ......... hides the panel and leaves a "☰" tab at the edge of the
               screen; click the tab to show the panel again.
Close ........ closes the panel (not the game).


---------------------------------------------------------------------
 KEYBOARD SHORTCUTS
---------------------------------------------------------------------

   Ctrl+Alt+P ............ show / hide the panel
   Ctrl+Alt+L ............ switch side
   Double-click the tray icon = show / hide


---------------------------------------------------------------------
 WHERE YOUR CHOICES ARE SAVED
---------------------------------------------------------------------

In urw-panel.ini, in the same folder as the script:

   [panel]   side and language
   [layout]  button order
   [colors]  color chosen for each button

Deleting that file (with the panel closed) resets everything.


---------------------------------------------------------------------
 ADVANCED SETTINGS
---------------------------------------------------------------------

At the top of urw-panel.ahk there are values you can change with
Notepad (then start the script again):

   PANEL_W ....... panel width in pixels; 0 = calculate automatically
   GAME_RATIO .... aspect ratio of the game image (4/3)
   OPACITY ....... panel transparency; 255 = opaque
   USE_EMOJI ..... false if the padlock, globe or palette don't show up
   SEND_MODE ..... how keys are sent: "Event", "Input" or "Play"
   KEY_DELAY / KEY_PRESS ....... timing of each key (ms)
   REPEAT_FIRST / REPEAT_EVERY . timing of key repeat (ms)
   TARGET_WIN .... window to send keys to (optional)
   MBUTTON_ESC ... true / false: middle click = Esc
   GAME_WIN ...... the game's program, for the middle click

A bit further down, next to the group colors:

   PALETTE ....... colors in the 🎨 mode palette, in hex format
                   (e.g. "C0392B"). You can change or add colors.
   PAL_ROWS ...... number of palette rows
   PAL_H ......... height of each palette row (1.0 = one button)


---------------------------------------------------------------------
 TROUBLESHOOTING
---------------------------------------------------------------------

- The game doesn't react to the buttons: try SEND_MODE := "Input" or
  "Play".
- Middle click doesn't send Esc: check that GAME_WIN matches the
  game's program (or leave it empty "" so it works in every window).
- Little squares appear instead of the padlock, globe or palette: set
  USE_EMOJI := false.
- The panel covers part of the game or is too narrow: adjust PANEL_W.
- Something looks wrong after moving or painting buttons: use "Reset"
  in the corresponding mode.
