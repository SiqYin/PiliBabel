### PiliBabel v3.3.16

**Seek hardening: the seek path can no longer hang indefinitely.**

`seekTo` had an un-timed `await …stream.buffer.first` (a delay used to avoid jitter while dragging). When you seek to an unbuffered position, that buffer event can take a long time to arrive — and with no timeout, the seek never executed at all. That is exactly the "dragged there and it just sits there / stuck at 99%" symptom. It now waits at most 600 ms, then performs the seek anyway and lets the player fetch the data at the new position.

Downloads are below.