### PiliBabel v1.8.18

**The translate button on comment pictures actually responds now.**

- **Taps were being swallowed.** The comment image grid runs its own hit test and only ever
  recorded the grid cell itself, never asking the cell's children - so the button inside the
  picture never received a tap, and the grid's own handler opened the full-size image instead.
  The grid now lets its children hit test first. Tapping the picture still opens the full-size
  image; tapping the button in its bottom-left corner translates it.
- **Both dialog buttons look the same.** "Close" was drawn in the outline colour, which read as
  a disabled button. It uses the same colour as "Detect again" now.

Downloads are below.
