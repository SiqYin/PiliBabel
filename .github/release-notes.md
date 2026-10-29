### PiliBabel v3.4.2

**Root-cause fix for the "video cover grows" family of bugs, plus two layout defects on the cache screen.**

- **The cover-height contract is now a single constant** (`Style.cardHCoverHeight`). The root cause: in a horizontal card the cover uses `AspectRatio`, and a `Row` gives children unbounded width — so `AspectRatio` derives its **width from the available height**. Grid `mainAxisExtent` in turn grows by 38 when "show full title" is on, which meant **every card had to remember to pin its own cover height**. That contract was duplicated across 20+ files, so it could only be fixed one reported card at a time. 26 horizontal cards and skeletons now use the shared constant: extra cell height goes to the text column only, and cover size is constant.
- **Cache screen: "cover shrank but the text column didn't narrow back".** `DetailItem` (cached videos / currently caching / folders) lives in a grid whose `mainAxisExtent` is a fixed 100, so it never needed a fixed-height box; an extra `SizedBox` taller than the available height (100 − 5 px padding top and bottom = 90) squeezed the cover while the row still allocated the old width to the text column. Removed — proportions are correct again.
- **Module bar scrolls horizontally.** "Cache video / Cache audio / Download status" get noticeably longer in some languages; a fixed `Row` pushed the right-most label off-screen with no way to see it. It now scrolls sideways when needed.
- **"Download status" is no longer tinted with the theme colour.** It is an entry point, not a module switch, so it now uses exactly the same styling as an unselected module button (`colorScheme.outline`, 13 px) instead of looking selected.

Downloads are below.