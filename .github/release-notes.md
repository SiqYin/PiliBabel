### PiliBabel v3.10.9

**Close-window button for the title-bar-hidden desktop layout.**

- When the system title bar is hidden on desktop, a close-window button now appears at the bottom of the left navigation bar; it is hidden when the title bar is shown.
- Note: the 3.10.8 portable package was re-verified — its launcher exe and `app.so` both report 3.10.8.6557, so the release itself was correct (issue #14 was caused by an old file / overlay-extracting over an old folder on the user side).
- **Verification**: `flutter analyze` reports 0 errors, the full `flutter test` suite passes 192/192, and `verify_readmes.py` reports 44/44 READMEs at 3.10.9.

**Thanks**: thanks to @masktao for the suggestion.