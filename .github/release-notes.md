### PiliBabel v3.3.17

**Code-quality cleanup (backlog item 68 — the analyzer tail): static-analysis warnings reduced from 42 to 0, errors remain 0.**

No behaviour or UI change — this release only removes analyzer findings:

- **16 unused imports, 3 duplicate imports** — each verified to be genuinely unreferenced before removal
- **5 dead_code + 5 dead_null_aware_expression** — `x` could no longer be null yet code still wrote `x ?? ''`; the never-taken branch is gone
- **5 unnecessary non-null assertions** — redundant `!` markers
- **2 invalid_use_of_protected / visible_for_testing_member** — the download page called `ChangeNotifier.notifyListeners()` directly; now done through a small subclass exposing `notify()`
- **1 override_on_non_overriding_member** — the audio page's `onDownloadAudio` was mislabelled `@override`
- **1 unused_element** — the comment area's `_buildTranslateBtn` had no remaining callers (dead code), removed
- **1 each** of unused_field, unused_local_variable, unused_element_parameter, invalid_null_aware_operator, unawaited_return_in_try_block

> During cleanup CI caught one mistake of mine: removing an import left a dangling `hide` continuation in `member_opus`, producing two errors. Fixed and re-verified back to zero.

Downloads are below.