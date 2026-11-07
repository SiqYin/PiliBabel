### PiliBabel v3.7.12

**Cancel/undo for the three cover buttons: tap while loading stops the job and wipes its caches; tap a finished one (green check) to revoke it too — even a successful translation can always be taken back.**

**Cancel while loading.** Tapping a loading button stops its job and resets it: the cover request is aborted via its cancellation token; the subtitle coordinator session is cancelled and its checkpoint deleted; danmaku segment fetching and translation batches drain without further network calls. Everything already written to caches is removed.

**Undo when done.** Tapping a finished button (green checkmark) revokes it: subtitle artifacts (VTT + checkpoint) are deleted from the registry; the danmaku source-text list (persisted per task) is removed from the translation cache; the cover completion marker resets. The button returns to its initial state and can be started again at any time.

Downloads are below.
