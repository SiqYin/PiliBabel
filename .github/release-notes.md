### PiliBabel v3.3.19

**Fix: long translated comment labels used to push the like button off-screen, making it unclickable.**

**Symptom.** When a comment carried labels such as "UP主觉得很赞" (liked by the uploader) and "相互关注" (mutual follow) at the same time, the AI-translated text grew long enough to push the like button on the right out of the visible area — so it could not be tapped.

**Cause.** The label `Text` had no width constraint inside its `Row`. Long text simply expanded to its content width, pushing the following `Spacer` and the trailing buttons past the right edge of the screen.

**Fix.** The label is now wrapped in `Expanded`, so it is constrained to the remaining space. When it overflows it is allowed to wrap to **two lines** (matching how the "Mine" page handles e.g. "offline cache") rather than being truncated to a single ellipsized line, so the translation isn't lost; only if it still doesn't fit in two lines does it fall back to an ellipsis. The trailing buttons now always stay on screen and remain tappable.

Downloads are below.