### PiliBabel v1.8.4

**The cover translation button is now the topmost element on the cover.**

- **Nothing can sit in front of it any more.** The button used to be inserted right after the
  cover image, which left the badges painted after it. Stack hit testing walks children from
  the last one backwards, so anything painted later gets first claim on a tap. The button is
  now the last child of the cover stack, which makes it the topmost element and the first one
  a tap reaches.
- **The dialog no longer depends on the card.** It is opened through the app level dialog
  rather than the card's own context, so a list rebuild or a recycled card can no longer
  swallow a result that already arrived.
- **Explicit hit area.** The tap target is a fixed 28x28 block with an opaque hit test, while
  the visible button keeps its original 13 pixel icon and 3 pixel padding.

Downloads are below.
