### PiliBabel v2.1.0

This release is about image translation growing up: long images get their own progress
window, the prompts stop guessing, and the messages that used to stay in Chinese now go
through translation like everything else.

**Long images translate in their own window**

- A long image - the kind that carries the little long-image badge, a chat log screenshot
  for instance - is recognised as such and translated from the original at full size.
- A window opens on its own while it works: "translating a long image, this may take a
  while" with a spinner, then two progress bars with arabic percentages - one for fetching
  the image, one for reading and translating the text.
- When it is done the full translation appears in the same window. If it is longer than
  the window, it scrolls on the right instead of stretching the dialog off the screen.
- A Close button at the bottom cancels the request. If you would rather not wait, the
  translation stops and you carry on with something else.
- Image translation now waits much longer before giving up, which is what long images
  need.

**Error messages are translated now**

- Network failures used to show a Chinese sentence followed by a long URL no matter which
  language the interface was in. The wording was already marked for translation, but a
  toast is drawn once and never redrawn, so it was showing the value from before the
  translation arrived. These paths now wait for the translation and then show it - the
  same fix covers the image-translation error dialog.

**The translator no longer skips text just because it looks like the target language**

- A title with a little English in it, read with English as the target language, used to
  be taken as "already English" and left alone. So did a half-Chinese half-Japanese title
  read with Japanese as the target language - one kana character was enough to skip the
  whole thing. The check is now about proportion rather than the presence of a single
  character: text counts as written in the target language only when that script makes up
  the large majority of it. Mixed text is translated in full.

**Image translation output**

- The result is now laid out segment by segment: the original text as it appears in the
  image first, then its translation, one pair per line, with several segments listed
  separately - and a short description of the picture after the text. Previously the
  original and the translation were often the same string, which made the output useless
  for checking anything.
- Long images are the exception: those show the translation only. Listing the original
  next to it would double the length of a chat log for no benefit.

Downloads are below.
