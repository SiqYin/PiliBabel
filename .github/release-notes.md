### PiliBabel v3.3.21

**Fix: the two comment labels were stacked vertically; they should stay side by side, each wrapping only within itself.**

**Symptom.** v3.3.20 rendered "UP主觉得很赞" (liked by the uploader) and "相互关注" (mutual follow) as two stacked lines, while the official layout places them **one on the left, one on the right, side by side**.

**Fix.** The labels are now laid out in a horizontal `Row`, each being its own `Flexible` + `Text` with an 8 px gap between them — so the two labels stay side by side. **Each label on its own** may wrap to at most two lines (short translations stay on one line), and wording is never broken across the two labels. The outer `Expanded` still guarantees the trailing like button stays on screen and remains tappable.

Downloads are below.