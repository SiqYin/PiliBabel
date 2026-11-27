### PiliBabel v3.10.7

**Compact home-feed video cards with two-line titles.**

- **Home-feed cards**: recommendation cards now show at most two title lines, and the grid no longer reserves the extra 38px used for the "full title" option, so single-line titles no longer leave large gaps — matching the web/plus layout.
- **Unchanged elsewhere**: the global "full video title" option still applies to other pages, so long translated titles keep displaying in full there.
- **Verification**: `flutter analyze` reports 0 errors, the full `flutter test` suite passes 192/192, and `verify_readmes.py` reports 44/44 READMEs at 3.10.7.

**Thanks**: thanks to @masktao for reporting this issue.