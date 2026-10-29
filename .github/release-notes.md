### PiliBabel v3.4.3

**Fixes a regression introduced in v3.4.2: cache-screen covers grew again.**

**Cause.** In v3.4.2 I removed the fixed cover height from `DetailItem` on the grounds that "its grid uses a fixed `mainAxisExtent` of 100". **That premise was wrong** — `DetailItem` is reused by two different grids:
- "Cached videos / Folders": hard-coded `mainAxisExtent: 100`
- "Currently caching / Download search": uses `GridMixin`, which grows to 148 when "show full title" is enabled

With no fixed height, it derived its cover from the available height again on the latter two pages, so the cover grew back.

**Fix.** `DetailItem` again pins its own cover height, computed against the **shortest** container: `100 − 5 px padding top and bottom = 90`. A new constant `Style.cardHCoverHeightCompact` documents this, so a future change can't re-break it by reasoning about only one of the two containers.

**Full audit included.** Every horizontal-card cover was scanned: the other 26 are already pinned; the 9 unpinned ones were verified to be **vertical** cards (cover inside a `Column`, width-driven, unaffected by container height), and only `DownloadFolderCard` sits in a `Row` — but it is used solely by the fixed-height-100 grid, so it is safe.

Downloads are below.