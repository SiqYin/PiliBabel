### PiliBabel v3.7.6

**Both cover buttons now share one clockwise-filling progress ring, and collection jobs can finally finish.**

**The ring is a determinate progress indicator again.** Whenever there was no exact progress to show (preparing, verifying, image recognition), the button fell back to an indeterminate spinner: it spun forever, so you could neither see how far along it was nor tell whether it had ended. Every state now renders a real arc that fills clockwise from nothing; without a server-side progress value it follows a gentle estimate until the true progress (or the finished state) takes over.

**The image button matches the translate button.** The upper button had already been enlarged to a 17-pixel ring, while the lower one below it was still a 13-pixel circle — two different controls sitting side by side. Both now share one progress-ring widget (17 pixels, 2-pixel stroke, visible track) and matching icon sizes.

**Collection / multi-part batches no longer spin forever.** The batch parent used to write its state onto the very task key of the part you had selected, so that part was treated as "already running" and never started; the batch's running count could never drop to zero, which left the button spinning with no way to complete. The parent now lives on its own state key (`…#batch`), so batches finish properly and the selected part really gets translated.

**Zombie states cleared.** After a task key is upgraded (`ep<id>` → `BV…`), the leftover "preparing" state on the old key is removed instead of being read back as a never-ending status; the pre-flight stage gained a fallback and a watchdog, so no unexpected exit can leave a button stuck in "preparing" any more. A custom API base URL without `/v1` is also no longer mangled into a literal `$u/v1`, which used to break every request.

Downloads are below.
