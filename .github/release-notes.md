### PiliBabel v2.1.3

**The listen-video sleep timer translated only one of its options**

- Four of the five options stayed Chinese: Disable, 15 minutes, 30 minutes and 45
  minutes. Only 60 minutes came out translated. Two separate misses in the same panel -
  the "Disable" entry was a bare string, and the shared formatter returned
  `'$minute分钟'` without going through the translation table, a branch that exactly the
  15 / 30 / 45 minute options take. Both go through translation now, so the whole row
  follows your interface language.

**Listen-video playback stopping part way through**

- Audio could stop at some point mid-track; pressing play jumped the position to 00:00
  and nothing played. The server's total duration was being filled in first, but then
  overwritten unconditionally by whatever duration the player reported - and when a CDN
  edge serves a truncated file, the player only sees the length up to the cut. The
  progress bar shrank to that point, and reaching it looked exactly like the track
  finishing.
- The duration from the server is now authoritative and is not overwritten by a shorter
  one. A premature end is recognised for what it is - the stream was cut, not finished -
  and the address is fetched again from the current position, which lands on a fresh
  connection. It gives up after two attempts rather than looping on a bad edge.

Downloads are below.
