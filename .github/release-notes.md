### PiliBabel v1.8.7

**The cover translation result now actually shows up.**

- **The dialog no longer fails to build.** It was an `AlertDialog`, which depends on
  `MaterialLocalizations`; the app level overlay that hosts it does not necessarily provide
  that context, so building it failed and all that was left was the dimmed barrier behind it.
  It is now a plain container that depends on nothing, with its own close button.
- **Failures are shown, not swallowed.** Whatever goes wrong - a request error, a timeout, an
  empty response - is printed verbatim in the dialog, so a failure can be read instead of
  guessed at.
- **Tap handling kept from 1.8.6.** The button is the topmost child of the cover stack, its
  tap target is a fixed 28x28 block, the visible icon stays at its original 13 pixels, and a
  press shows a toast and starts the spinner immediately.

Downloads are below.
