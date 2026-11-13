### PiliBabel v3.9.2

**Switching the AI-translation target language no longer leaves the old language behind.**

The bug was in the order of operations, not in the cache. Switching languages bumped `revision` — which only *marks* listeners dirty — and then immediately called `Get.forceAppUpdate()`. Some pages rebuilt inside that same frame, before the dirty flags landed, and rendered the previous language; nothing afterwards touched them again, so the old text simply stayed. The rebuild now happens in a post-frame callback, so the dirty pass always completes first.

Two smaller leaks fixed alongside it:

- the pending-width table (source text → width tier) was never cleared on switch, so a string could still be laid out with the previous language's short/full form;
- a `languageEpoch` counter was added, incremented on every switch, for any screen that needs to key its subtree off the language.

Nothing else changed.
