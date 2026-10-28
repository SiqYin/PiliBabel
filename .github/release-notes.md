### PiliBabel v3.3.24

**Completes what v3.3.23 missed: the loading skeleton and several custom cards still had covers enlarged by the taller grid cell.**

**Symptom.** With "show full video title" enabled, cover sizes were correct, but while loading a **large placeholder block would flash first** and then snap back to the normal size.

**Cause.** v3.3.23 only pinned the cover height of the real card (`VideoCardH`). The **skeleton** (`VideoCardHSkeleton`) and several custom cards still used `Row + AspectRatio`, and `AspectRatio` derives its width **from the available height** — so a taller cell made them bigger.

**Fix.** Those covers are now all pinned to their original height (100):
- the skeleton `VideoCardHSkeleton`
- favourite-detail card, watch-later card, member-contribution card, music card, subscription-detail card
- the member pages' comics / audio / articles / article-list / course cards

The skeleton and the real cards now match exactly, so nothing jumps during loading. The remaining vertical cards (which derive height from width) are unaffected and needed no change.

Downloads are below.