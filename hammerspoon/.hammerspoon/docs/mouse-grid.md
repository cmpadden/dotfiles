# Mouse grid

Press **⌘⌃G** over the window you want to control. The overlay starts on the part of that window on its current display. The left-hand letter keys map to the grid like this on QWERTY:

```text
Q W E
A S D
Z X C
```

- **Q/W/E**, **A/S/D**, and **Z/X/C** zoom into the corresponding cell (no Shift needed). At small sizes the drawing stays large enough to read, while the outline shows the actual selection. Choose one more letter on that smallest grid to switch to a crosshair.
- In crosshair mode, the same letters nudge by one point in the corresponding direction: **W/A/X/D** move up/left/down/right, and **Q/E/Z/C** move diagonally. **S** stays put. Hold a movement key to keep moving, or add **Shift** for ten-point steps. You can move anywhere inside the original window area, not just inside the last cell.
- **Return** left-clicks the crosshair and closes the grid.
- **Space** moves the pointer there without clicking and closes the grid. Use this to reveal Slack's hover controls, then reopen the grid to pick one.
- **Esc** or **⌘⌃G** cancels. Reopen the grid to start over. The grid also cancels if the target window loses focus, moves, or resizes.

This works with coordinates, not app controls. It won't track content moving inside the window (such as when Slack scrolls), and a floating window or menu can cover the point you're aiming at. For a window spanning displays, the grid covers only the portion on that window's current display. Change the entry shortcut in `init.lua`.
