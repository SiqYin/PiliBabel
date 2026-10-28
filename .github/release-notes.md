### PiliBabel v3.3.25

**Fix: the "show full title" toggle did not take effect on some screens until the app was restarted.**

**Cause.** `GridMixin`'s `gridDelegate` was a `late final` field, evaluated once using whatever `Pref.videoTitleFull` was at that moment. Screens such as search, favourites, history and watch-later use `AutomaticKeepAliveClientMixin`, so their `State` stays alive — after switching the toggle in Settings they kept using the old cell height and the old title line count. That is exactly the "I flipped the switch and nothing happened, I had to restart" behaviour.

**Fix.** `gridDelegate` is now a **getter**, re-evaluated on every build against the current setting. As soon as a screen rebuilds (pull-to-refresh, returning from another page, list re-layout) the new setting applies, instead of being stuck on the old value forever.

Also added a missing `@override` annotation (audio player controller's `onClose`).

**Note — the remaining analyzer "info" items were deliberately left alone.** The `Object? boxed` in `reply_controller` exists specifically to work around a compiler problem seen in v3.3.3; the lambda and initializing-formal suggestions in `retry_interceptor` / `live_room` involve signature types. Changing them just to silence a lint would risk regressions.

Downloads are below.