### PiliBabel v2.6.4

**Audio cache polish: no duplicate caching, a progress line that tells the whole story, and a start toast**

**Fixed: the cache-audio button appeared while playing an already cached audio**

- Opening a cached audio from *Mine → Offline cache → Cached audio* plays the local file, but the top-right cache button was still there — tapping it cached the same audio all over again.
- While the player is on a local cached file, the cache entry is now hidden from both the top bar and the *More* menu. It comes back automatically if you switch to another, not-yet-cached track in the playlist. (Playing cached videos was already guarded this way.)

**Improved: the cache-audio progress row now shows speed and size**

- It used to show only a percentage. It now reads like `45% 358K/s 3.4M/12.6M` — percentage, current speed, and loaded / total size — using nothing but digits and the unit letters K / M / G, so every language can read it without translation.

**New: a start toast for cache audio**

- *Download to local* already announced itself with a small toast when the download started; caching audio stayed silent. Caching audio now shows `Caching audio: <title>`, AI-translated like every other string.

**Docs**

- The AI-written note at the bottom of the README was removed from every language version (the Taiwanese one keeps it).

Everything inherited from PiliNara / PiliPlus is unchanged.

Downloads are below.
