### PiliBabel v1.8.3

**The cover translation button reacts the moment you press it.**

- **Immediate feedback on press.** A tap now shows a toast and starts the button spinner
  before the request goes out, so there is never a silent gap between pressing and seeing
  something.
- **The request can no longer hang.** It carries a 15 second timeout; a stalled connection
  ends in the failure dialog instead of leaving the button spinning forever, which is what a
  dead button looked like from the outside.
- **Back to the old size.** The icon is 13 again with the original 3 pixel padding, so the
  button looks exactly as it did before. The tap area underneath is an invisible 28x28, which
  is what makes it easy to hit.
- **Ripple instead of a bare gesture detector.** The button now uses an `InkWell` inside a
  transparent `Material`, so a press is visibly acknowledged.

Downloads are below.
