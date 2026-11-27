### PiliBabel v3.10.6

**Playback-speed settings and CDN fixes.**

- **Playback-speed settings**: the "default speed" and "default long-press speed" rows are now tappable and open a speed picker, so the default can be changed repeatedly (previously tapping did nothing); the bottom-sheet menu now closes via the sheet's own `Navigator`.
- **CDN**: fixed the CDN list showing every speed test as failed when playing from the app-source stream (an app-signed direct link cannot be host-rewritten); it now fetches its own web sample, with a clear message if that fails. When the user explicitly selects a custom CDN or a non-default CDN service, on-demand playback now uses web direct links so the selected CDN actually applies (fixing stutter); default users are unaffected.
- **Verification**: `flutter analyze` reports 0 errors, the full `flutter test` suite passes 192/192, and `verify_readmes.py` reports 44/44 READMEs at 3.10.6.

**Thanks**: thanks to @masktao for reporting these issues and helping make PiliBabel better.