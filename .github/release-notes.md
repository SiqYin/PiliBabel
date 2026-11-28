### PiliBabel v3.10.8

**Related-video sidebar and "full title" fixes.**

- **Related videos**: the sidebar is back to a single column (no longer split into two columns in windowed playback).
- **"Show full title"**: fixed the option being ignored on the home feed; the default is now compact two lines (matching the web/plus), and enabling it shows full titles (four lines). With AI translation on, long translated titles still display in full automatically.
- **Verification**: `flutter analyze` reports 0 errors, the full `flutter test` suite passes 192/192, and `verify_readmes.py` reports 44/44 READMEs at 3.10.8.

**Thanks**: thanks to @masktao for reporting this issue.