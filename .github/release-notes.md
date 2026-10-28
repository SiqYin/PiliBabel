### PiliBabel v3.3.20

**Fix: multiple comment labels were joined into one string, so line wrapping broke words across labels.**

**Symptom.** When a comment carried both labels — "UP主觉得很赞" (liked by the uploader) and "相互关注" (mutual follow) — v3.3.19 merged them into a single string separated by spaces and let that wrap to two lines. The wrap then happened *inside* a label, producing things like 「投稿主がいいねしま／した 相互フォロー」: one word split in half with the other label trailing after it.

**Cause.** The v3.3.19 fix used `join('  ')` to combine the labels into one `Text`, so wrapping naturally crossed label boundaries.

**Fix.** Each label is now rendered **independently** (a vertical `Column` of separate `Text` widgets). Every label may wrap to at most two lines — and only if it actually needs to; short labels stay on one line. The `Expanded` constraint is kept so the like button and other trailing controls remain on screen and tappable, and the semantic boundary between labels is no longer broken.

Downloads are below.