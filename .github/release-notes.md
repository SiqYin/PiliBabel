### PiliBabel v1.8.6

**The cover translation button, take three.**

- **Build fix.** 1.8.4 and 1.8.5 never produced a release: 1.8.4 shipped with an unbalanced
  parenthesis and 1.8.5 called a dialog API this codebase does not have. Both are corrected.
- **Nothing can sit in front of the button.** It is now the last child of the cover stack,
  which makes it the topmost element and the first one a tap reaches. It used to be inserted
  right after the cover image, leaving the badges painted after it.
- **The dialog no longer depends on the card.** It opens through the app level dialog rather
  than the card's own context, so a list rebuild or a recycled card cannot swallow a result
  that has already arrived.
- **Immediate feedback.** A tap shows a toast and starts the button spinner before the request
  goes out, and the request carries a 15 second timeout.
- **Original size.** The visible button keeps its 13 pixel icon and 3 pixel padding; the tap
  target underneath is a fixed 28x28 block.

Downloads are below.
