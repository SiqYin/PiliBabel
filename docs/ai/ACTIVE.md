# Active work

- Objective: Keep realtime Vietnamese subtitles continuous, retry failed chunks safely, and reject overlap-context leakage without losing valid cache or cue timing.
- Branch: `codex/subtitle-translation-proxy` tracking `origin/codex/subtitle-translation-proxy`.
- Upstream base: stable `v3.6.7`, merge commit `8fdaabfc7`.
- Status: Realtime/context implementation, affected validation and release build pass. Push is ready; ADB install/startup smoke is blocked because no device is connected.

## Completed

- Realtime Vietnamese VTT contains only translated, validated chunks; untranslated chunks never copy Chinese source text into the Vietnamese track.
- Playback starts after 60 seconds of continuous Vietnamese coverage and pauses below 15 seconds unless the user manually selects Chinese/off.
- Queue priority follows current playback chunk, the 60-second lookahead window, later chunks, then watched history; seeking reprioritizes immediately.
- Player reloads translated VTT only when `renderRevision` changes, not on each position update.
- Coordinator automatically retries failed/stalled work with backoff reset after progress and supports immediate manual retry without duplicate requests.
- Restored `Thử lại` and `Dịch lại phụ đề` controls in both subtitle menu layouts.
- Overlap validation now compares source-context and translated-context pairs. It rejects merged context, a distinctive context sentence replacing the current cue, and multiple short context elements replacing current cues.
- Short legitimate repeated dialogue such as `Được` remains valid.
- Parallel out-of-order completion is rechecked after workers settle; only the polluted chunk is hidden, reopened and retried.
- Out-of-order chunks whose translated overlap context is not ready are now stored as provisional checkpoint entries. They are not counted, rendered or exposed until all four preceding context cues are translated and the candidate passes context validation.
- The playback queue now orders work as: overlap dependency immediately before playback, current chunk, future chunks in timeline order, then watched history. Seeking rebuilds this order so the current chunk can be verified without waiting behind unrelated future work.
- Cached chunks are checked by the same context contract. `SubtitleTextQuality.verifierVersion` is now `2`, so older artifacts are revalidated and repaired rather than trusted blindly.
- Cue count, order and exact timestamps remain source-owned; translations only replace cue text.

## Files changed

- Runtime/player: `lib/pages/video/controller.dart`, `lib/plugin/pl_player/view/view.dart`.
- Translation/retry/quality: `lib/services/ui_translate/subtitle_translation_coordinator.dart`, `lib/services/ui_translate/subtitle_translation_job.dart`, `lib/services/ui_translate/subtitle_text_quality.dart`.
- Regression tests: `test/services/ui_translate/subtitle_translation_coordinator_test.dart`, `test/services/ui_translate/subtitle_translation_job_test.dart`.

## Validation

- Targeted job tests: PASS (`37/37`), including provisional context hiding and dependency-first queue order.
- AFFECTED subtitle suite: PASS (`77/77`) via `flutter test test/services/ui_translate`.
- Affected Flutter analyze: PASS with `--no-fatal-infos`; 19 info-only notices remain, mainly existing async I/O and test-style lints.
- `git diff --check`: PASS.
- Release build: PASS on 2026-11-06 using Flutter 3.47.2, Android SDK build-tools 37 and Temurin JDK 17.
- APK: `build/app/outputs/flutter-apk/app-release.apk`, 120,099,926 bytes, SHA-256 `761c5e28aaf0dda9fc3418310aafd685606c0c4f95176f363cd86e33465e3ee3`.
- APK ZIP integrity: PASS. APK Signature Scheme v2 verification: PASS (existing Android debug signing certificate).
- Origin fetch: PASS; remote branch has no unseen commits before push.
- ADB: `/Users/minhtuan/.cache/android-sdk/platform-tools/adb devices -l` returns no connected device, so install and startup/crash smoke were not run.

## Remaining risks and next action

- Interactive provider/proxy throughput and the exact wait-5%-then-play behavior still require a connected Android device and live network/API access.
- When a device is connected, run `adb install -r -g`, launch `com.example.pilibabel`, inspect `AndroidRuntime`/`FATAL EXCEPTION`, then test realtime buffering, seeking, manual retry and cache restoration.
- Preserve user-owned untracked `.agentboard/`, `.codebase-memory/`, `.cursor/` and `.ruler/` directories.
