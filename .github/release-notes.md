### PiliBabel

AI interface & content translation layered on top of **PiliNara / PiliPlus** — the whole app speaks your language.

**Install**
*Android* — download `PiliBabel.apk` below, allow “install unknown apps”, and open it. Every release is signed with the **stable PiliBabel key**, so newer versions **upgrade in place** (no uninstall needed) and the app keeps coexisting with PiliNara.
*Desktop* — `PiliBabel_windows_*` (portable zip / setup exe) and `PiliBabel_linux_*` (deb / rpm / AppImage / tar.gz) are attached to each release.

**What's new**
- AI interface & content translation with **translate-once + local persistence** — never re-translated on reopen.
- ~35 target languages via **your own** OpenAI-compatible endpoint; the translation endpoint is fully **independent** from AI video summary.
- Per-comment **Original ⇄ Translation** toggle; hyperlinks are preserved and stay clickable.
- **Danmaku translation** — an independent player toggle that pre-translates ahead of the playhead in ~15-second batches.
- **Thinking-mode** switch, **test-translate**, and a batched/concurrent pipeline (progressive per-chunk apply for faster first load).
- **First-launch onboarding** dialog pointing to *Settings → AI → AI interface translation*, with a one-tap shortcut to that page.
- **Toggle semantics are now explicit**: turning AI translation **off** falls back to the original text everywhere and issues **zero** API requests (your token/quota is never touched); turning it **on** translates foreign-language content — e.g. comments — into your selected language.
- **Worldwide playback**: outside mainland China the player now picks bilibili's own **overseas edges** (Akamai / `mirror*ov`) straight from the geo-routed stream URLs instead of forcing a China-only mirror, which is what caused “audio plays, video freezes” and endless retry toasts.
- **Downloads**: stall watchdog (no bytes for 5s → hand the slot to another queued item; 10s → rotate to the next signed edge; last edge also stalls 10s → fail loudly instead of hanging), **plus a 15s "no new bytes at all" global watchdog that also covers the request phase where an edge accepts the connection and then never replies** — the old freeze-at-a-fixed-progress bug. Candidate-edge rotation keeps resuming from the partial file, audio no longer gets corrupted by rejected Range requests, a line trickling below ~32 KB/s on the last edge re-requests fresh stream URLs (or fails) instead of showing “downloading” forever, and fetching danmaku is now time-boxed and optional so a slow overseas `dm` endpoint can't wedge the queue.

**Fork lineage**: PiliBabel → PiliNara → PiliPlus → PiliPala. GPL-3.0, same as upstream.

> Unofficial third-party client, not affiliated with or endorsed by bilibili. For learning & testing; please delete within 24 hours of download.
