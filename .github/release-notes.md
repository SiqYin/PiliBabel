### PiliBabel v1.8.8

**The cover translation strings go through the translation table again.**

- **Interface text is translated.** The progress toast, the dialog title and the close button
  were hardcoded while chasing the dialog bug; they run through the translation table now, the
  same way the rest of the app does. Failure messages use the template form so each distinct
  error does not turn into its own dictionary entry.
- **Everything else is unchanged from 1.8.7.** The result dialog is a plain container that does
  not depend on any Material context, failures are printed verbatim instead of being swallowed,
  and the button stays the topmost element of the cover stack with its original small size and
  a 28x28 tap target.

Downloads are below.
