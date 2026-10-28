### PiliBabel v3.3.18

**Continuing the analyzer-tail cleanup (backlog item 68): cascade style and deprecated APIs in our own code — behaviour fully unchanged.**

- `segment_progress_bar`: `markNeedsPaint()` folded into the cascade above it
- `author_panel`: `blockedMids.add(mid)` folded into the cascade
- `vote_decoration`: deprecated `color.alpha` (0–255) → `color.a == 1.0` (0–1, equivalent)

**Deliberately left alone, recorded here for future reference:**

- The 11 `cascade_invocations` and 23 `deprecated_member_use` findings under `lib/common/widgets/flutter/`: those files are copies of Flutter SDK sources (they carry the Flutter Authors copyright header). Editing them would add merge cost on every Flutter upgrade, and the only gain is a quieter analyzer.
- `onReorder` → `onReorderItem` (download folder management / download sorting): the new callback auto-corrects `newIndex`, whereas the old one expects the caller to do it. Swapping them would **change the resulting order**, so it's a behaviour change — not worth doing just to silence a lint.
- `LinearProgressIndicator.year2023: true`: a product appearance choice (2023 vs 2024 progress styling); changing it to satisfy a lint would alter the UI.

Downloads are below.