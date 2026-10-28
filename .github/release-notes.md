### PiliBabel v3.3.22

**Fix: video-title line count didn't consistently follow the "expand title (2 → 4 lines)" toggle; search-result titles were clipped.**

**Symptom.** Video titles in search results were stuck at roughly two lines even with "2 lines → 4 lines" enabled — occasionally showing three-and-a-bit lines with only the top sliver of the 4th line visible.

**Two root causes.**
1. The shared `GridMixin` grid delegate had a fixed `mainAxisExtent` of 110, while the card renders its title area with `Pref.videoTitleFull ? 4 : 2`. 110 px only fits a little over three lines, so the 4th line was clipped by the cell. Every other grid (recommended feed, live, member pages, …) had long since added the same 38 px allowance in its own delegate — only this shared one was missing it, so every page using `GridMixin` (search, favourites, history, watch-later, …) was affected together.
2. Inside `VideoCardH`, the "translated title" branch hard-coded `maxLines: 2` and ignored the toggle.

**Fix.**
- `GridMixin`'s delegate now adds `+ (Pref.videoTitleFull ? 38 : 0)`.
- `VideoCardH`'s translated branch now uses `maxLines: Pref.videoTitleFull ? 4 : 2`.
- After auditing the whole app, the remaining video-title renderers were wired to the toggle too (favourite detail, favourite videos, history, watch later, member contributions, subscriptions, subscription detail, music, member-home favourites — 9 places), adding `TextOverflow.ellipsis` where it was missing.

**Also:** the comment label "关注的人" is now pinned to the Japanese translation "フォロー中" via a new "pinned translation" mechanism — on a hit it returns immediately, bypassing both the cache and any model request.

Downloads are below.