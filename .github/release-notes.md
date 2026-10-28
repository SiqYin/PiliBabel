### PiliBabel v3.4.0

**Wrap-up release for this whole round (3.0.5 → 3.4.0).** No new features — this is the version that closes the round.

The round's theme was overseas-network experience, parity with the official app, and landing the AI translation layer. What 3.4.0 itself does:

- **Analyzer brought to zero** — `flutter analyze` reports **0 errors / 0 warnings**. The 373 remaining *infos* are noise that was deliberately kept, with the reasoning itemised in `docs/outstanding.md`.
- **Documentation closed out** — all 44 language READMEs carry an AI-translation note; the English and Chinese README changelogs are brought up to 3.4.0; what is outstanding, what is blocked, what was deliberately not done, and how the app knowingly differs from the official client are documented in `docs/outstanding.md` and `docs/known-differences-vs-official.md`.
- **Repository tidied** — every temporary `diag/**` diagnostic branch deleted; only `feat/ai-ui-translate` and `main` remain on the remote (plus the local working branch `work/v3.3.7-fixes`).
- **Explicitly not doing**: swapping the player kernel (decided for this round), migrating the home feed / main search / dynamics main feed to gRPC (missing proto definitions, or the gRPC payload degrades rich text).

The three changes from this round that matter most to users:
1. **Image pipeline now connects directly** — fixes "covers only appear after a pull-to-refresh" and removes the tunnel-flooding failure that had taken the whole data layer down.
2. **Data requests connect directly by default** — noticeably faster loading than 3.0.5, with a switch to revert.
3. **Audio and video use multi-connection segmented transfer by default** — the buffer keeps ahead of the playhead, seeking is much faster, and it no longer crashes or hangs.

See the README's "Changelog: 2.6.x → 3.4.0" and the individual 3.3.x entries below for the full itemisation.

Downloads are below.