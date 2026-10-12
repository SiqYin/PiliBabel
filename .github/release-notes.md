### PiliBabel v1.6.1

- **Fixed: sound playing over a black picture.** One of Bilibili's CDN hosts was truncating the video segment mid-response (measured: 835 KB of a 956.9 MB file, and 3.7 MB of a 284.8 MB file). ffmpeg treats that as end-of-file, so the video track simply stops — no packets, no frames — while the audio, a separate stream, keeps playing. These errors used to be logged and nothing else.
- **Bad hosts are now remembered by host, not by line index.** The same host often sits at several positions in the candidate list, so banning an index still landed on the same machine — that is why reloading never helped. A truncated response now blacklists that host, and line switching skips it.
- **Network streams reconnect instead of ending.** `--stream-lavf-o=reconnect=1,reconnect_streamed=1,reconnect_delay_max=10` resumes the download with a Range request rather than treating the cut connection as a finished file.
- Recovery now starts the moment a truncation is seen, instead of waiting for the watchdog to conclude the video track is frozen.

Downloads are below.
