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
- **Tap-to-switch caching, always responsive.** Tapping any queued item starts it **immediately** and sends the item that was downloading back to the queue — there is no download lock any more, so a stalled edge or a hung metadata request can never make the list ignore your taps. A hard failure now names its reason, and the queue moves on to the next item instead of dying on the first one.
- **First-launch onboarding** dialog pointing to *Settings → AI → AI interface translation*, with a one-tap shortcut to that page.
- **Toggle semantics are now explicit**: turning AI translation **off** falls back to the original text everywhere and issues **zero** API requests (your token/quota is never touched); turning it **on** translates foreign-language content — e.g. comments — into your selected language.
- **Worldwide playback**: outside mainland China the player now picks bilibili's own **overseas edges** (Akamai / `mirror*ov`) straight from the geo-routed stream URLs instead of forcing a China-only mirror, which is what caused “audio plays, video freezes” and endless retry toasts.
- **Downloads**: a stalled line is now decided in **5 seconds of zero bytes** — switch to the next signed edge, at most twice (so one task tries 3 lines); when there is nothing left to switch to, it either **yields** to another queued item (partial file kept, fresh stream URLs when its turn comes again) or, if nothing else is queued, reports **download failed**. On top of that, a matching 5s “no new bytes in **any** phase” **global** watchdog also covers the phases where the per-line timer isn't running yet (a switched edge that accepts the connection but never replies) — that was the old “frozen at a fixed MB forever” bug. Rotation keeps resuming from the partial file, audio no longer gets corrupted by rejected Range requests, a line trickling below ~32 KB/s on the last edge re-requests fresh stream URLs (or fails), danmaku fetching is time-boxed and optional so a slow overseas `dm` endpoint can't wedge the queue, and if the queue is ever held up longer than 8s the UI names the stage it is stuck in. Any hard failure now surfaces with its reason (disk write errors and other non-HTTP exceptions can no longer leave a row sitting on “downloading” forever), and when an item fails for good the queue automatically moves on to the next one instead of dying on the first failure.

**Fork lineage**: PiliBabel → PiliNara → PiliPlus → PiliPala. GPL-3.0, same as upstream.

> Unofficial third-party client, not affiliated with or endorsed by bilibili. For learning & testing; please delete within 24 hours of download.
