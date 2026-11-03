### PiliBabel v3.6.0

**Update dialog: page markup is stripped, and its translation now jumps the queue so you no longer stare at an untranslated dialog.**

**No more markup symbols.** The update description comes from a GitHub Release and is raw Markdown. It was displayed as-is, so bold markers, backticks, heading hashes, leading dashes and link syntax all showed up literally in the dialog. It is now flattened to plain text first — code blocks, inline code, images, links, headings, blockquotes, list markers, horizontal rules, bold/italic/strikethrough and tables are all removed, leaving only readable content and line structure.

**The update dialog's translation is now top priority.** The dialog appears the instant the app launches, which is exactly when the main UI pushes dozens of strings into the translation queue. The dialog body used to queue up alongside them, so its translation often took a long time to arrive. It now uses a **separate high-priority queue**:

- the priority queue is neither batched nor debounced — it dispatches immediately
- each translation round drains the priority queue first, before the normal queue
- the two queues are mutually exclusive, so no string is ever translated twice

Net effect: right after launch, the update dialog's translation shows up first and the rest of the UI follows.

Downloads are below.
