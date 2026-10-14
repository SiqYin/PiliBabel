### PiliBabel v1.8.2

**The cover translation button is back.**

- **Why it vanished in 1.8.1.** The button's state container had been simplified to a plain
  widget, and the `Obx` wrapper around it was left with no observable to read. GetX throws
  when an `Obx` builder reads nothing, so the whole button subtree failed to build and simply
  was not drawn. The same mistake sat in the dialog body on the branch that shows a
  successful translation.
- **What changed.** The button no longer wraps a stateless container in `Obx` - it has no
  reason to rebuild when a translation lands. The dialog keeps `Obx` only where the label
  genuinely reads the translation, and the body is a plain `Text`.
- **Kept from 1.8.1.** The larger tap target (a fixed 32x32 area with an opaque hit test) and
  the guarantee that every tap ends in a dialog, whether the request succeeds or fails.

Downloads are below.
