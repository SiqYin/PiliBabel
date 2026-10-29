### PiliBabel v3.4.0

**Wrap-up release for this whole round (3.0.5 → 3.4.0).** This is the version that closes the round.

The round's theme was overseas-network experience, parity with the official app, and landing the AI translation layer. What 3.4.0 itself does:

- **Analyzer cleaned up** — `flutter analyze` reports **0 errors / 0 warnings**; infos went **373 → 53** (the remainder are items deliberately kept, itemised with reasons in `docs/outstanding.md`). 296 `prefer_const_constructors` and friends were fixed in bulk via CI's `dart fix --apply`; the rest (cascades, anonymous types, `onReorder` migration, `cancel_subscriptions`, context guards) were done by hand and verified by a real compile.
- **Second pass on video-cover sizing** — thirteen more cards (history, favourites for videos/bangumi/columns/notes, member favourites, member search, season series, rankings, article search, subscriptions, comment search, and the bangumi skeleton) still enlarged their cover when "show full title" made the grid cell taller. All covers are now pinned to their original height, so the toggle no longer changes cover size anywhere.
- **UP (uploader) profile translation completed** — the "大会员 / 年度大会员" badge, the personal signature, "xx 人为 TA 充电" and "xx 人加入大航海", the IP-location line and the uploader's own category tags (both come from the same server-provided `spaceTag`), the "主页 / 动态 / 投稿" tab titles, every follow-button state, the follow date, and "等 N 人也关注了 TA" now all go through `uiTx` / `uiTxP`.
- **Documentation closed out** — all 44 language READMEs carry an AI-translation note; the English and Chinese README changelogs are brought up to 3.4.0; what is outstanding, what is blocked, what was deliberately not done, and how the app knowingly differs from the official client are documented in `docs/outstanding.md` and `docs/known-differences-vs-official.md`.
- **Repository tidied** — every temporary `diag/**` diagnostic branch deleted; only `feat/ai-ui-translate` and `main` remain on the remote (plus the local working branch `work/v3.3.7-fixes`).
- **Explicitly not doing**: swapping the player kernel (decided for this round), migrating the home feed / main search / dynamics main feed to gRPC (missing proto definitions, or the gRPC payload degrades rich text).

The three changes from this round that matter most to users:
1. **Image pipeline now connects directly** — fixes "covers only appear after a pull-to-refresh" and removes the tunnel-flooding failure that had taken the whole data layer down.
2. **Data requests connect directly by default** — noticeably faster loading than 3.0.5, with a switch to revert.
3. **Audio and video use multi-connection segmented transfer by default** — the buffer keeps ahead of the playhead, seeking is much faster, and it no longer crashes or hangs.

See the README's "Changelog: 2.6.x → 3.4.0" and the individual 3.3.x entries below for the full itemisation.

Downloads are below.