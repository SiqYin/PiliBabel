### PiliBabel v3.3.23

**Urgent fix for the oversized-cover regression in v3.3.22, plus title line counts now follow each screen's original design by doubling.**

**Regression.** v3.3.22 added grid height allowance (+38 px) to fit 4-line titles. But `VideoCardH` is a horizontal card and its cover uses `AspectRatio`: a `Row` gives children unbounded width, so `AspectRatio` derives its width **from the available height**. Raising the cell height therefore enlarged the cover, squeezing the title/uploader into a narrow strip on the right.
**Fix:** the cover height is now pinned to its original 100 px (old cell 110 − 5 px padding top and bottom), so any extra cell height goes to the content column only. Cover size is decoupled from cell height from now on.

**Title line rule is now "double" rather than always four lines**, matching each screen's original design:
- screens that defaulted to **2 lines** → **4 lines** when "show full title" is on
- screens that defaulted to **1 line** → **2 lines** when it is on

Applied across: home/recommended horizontal cards, search (including its "All" tab), favourite detail, favourite videos, history (keeping the original "multi-part ⇒ 1 line" behaviour and doubling it), watch later, member contributions, subscriptions, subscription detail, music, member home, the Mine page, bangumi cards, comics, mall, articles, audio, and courses.

**The height allowance now lives inside `Grid.videoCardHDelegate()`**, so every caller — including the search "All" tab — follows it automatically and no screen can be left with a clipped 4th line.

The Japanese label "关注的人" remains pinned to "フォロー中".

Downloads are below.