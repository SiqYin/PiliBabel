### PiliBabel v2.2.1

**The video page's tab labels no longer overlap in a foreign language**

- On a tablet in landscape the right column opens with a row of small labels - the
  intro, comments, playlist. In a language other than Chinese they were drawn on top of
  each other.
- The tab bar was not scrollable and its label padding was zero, so every tab was given
  an equal share of the row: two or three Chinese characters fit, a longer word does not.
  The labels were also set to keep their overflow visible, so instead of being clipped
  the excess was painted straight over the neighbouring tab.
- The bar now lays its tabs out by their own text width and keeps spacing between them,
  so a long label pushes the row wider and scrolls instead of colliding. This applies to
  every place the video page uses this bar, including the bottom layout.

Downloads are below.
