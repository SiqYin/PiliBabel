### PiliBabel v2.2.2

**The "jumping to 12:34" popup is translated now**

- Tapping a timestamp in a comment seeks the player and shows a small popup naming the
  position. That popup stayed Chinese in every interface language, for two reasons
  stacked on top of each other: the timestamp was interpolated into the string before it
  was handed to the translation table, so every different timestamp became its own entry
  that the cache could never hit, and a toast is drawn once and never redrawn, so even a
  cache hit would have arrived too late.
- It now goes through a template - one entry, filled in with whatever the timestamp is -
  and waits for the translation before showing. The failure popup next to it had the same
  problem and is fixed the same way.

Downloads are below.
