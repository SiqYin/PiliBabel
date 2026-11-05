# Active work

- Objective: Stabilize verified Vietnamese subtitles, integrate upstream PiliBabel `v3.6.7`, and pretranslate the next `0-5` playlist items without replacing the custom subtitle pipeline.
- Branch: `codex/subtitle-translation-proxy` tracking `origin/codex/subtitle-translation-proxy`.
- Upstream merge commit: `8fdaabfc7`; implementation changes are staged for a separate commit.
- Status: Source implementation, affected tests/analyze, release build, APK integrity and signature checks pass. ADB install/startup smoke is pending because no device is connected.

## Completed

- Created backup branch `codex/backup-before-v3.6.7-sync` and merged stable upstream tag `v3.6.7` with a merge commit; no rebase or force-push.
- Preserved the custom runtime: independent Vietnamese playback tracks, durable artifacts/checkpoints, proxy routing, chunk retries, strict JSON output and Vietnamese UI behavior.
- Replaced partial Han detection with a shared rune/code-point classifier covering `〇`, CJK Unified Ideographs, Extensions A-I and the Compatibility Supplement.
- Output cues containing Han are rejected regardless of source-language detection and do not count as translated or verified.
- Added two-stage completion: `translating -> verifying -> ready`. The app no longer advertises 100%/completed until atomic cache readback and full VTT verification pass.
- Verification requires exact cue count/order/timestamps, no context overlap leakage and no residual Han. Invalid cues reopen only their owning chunks while valid chunks remain cached.
- Added artifact verifier metadata. Legacy caches remain reusable, but stale completion markers and old verifier versions are revalidated before being exposed as ready.
- Added `SubtitlePlaybackTrackPhase.verifying` and separate translated/verified/error progress values for player/menu status.
- Kept stable-ID Vietnamese track selection as the default. A manual track/off choice suppresses auto-switching only for the current video part.
- Replaced the old prefetch boolean with `subtitleTranslationPrefetchCount` (`0-5`, default `1`) and migration `true -> 1`, `false -> 0`.
- Added pure playlist prefetch selection, deduplication and priority rules. Playback/current-video work remains above prefetch jobs, and per-video settings are captured when queued.
- Fixed detached playlist-prefetch listeners so background jobs remain tracked until completion.

## Files changed

- Quality/validation: `lib/services/ui_translate/subtitle_text_quality.dart`, `subtitle_translation_job.dart`, `subtitle_translation_artifact.dart`.
- Playback/progress: `lib/services/ui_translate/subtitle_playback_track.dart`, `lib/pages/video/controller.dart`, `lib/common/widgets/video_subtitle_translate_button.dart`.
- Prefetch/settings: `lib/services/ui_translate/subtitle_prefetch_policy.dart`, `subtitle_translation_background_service.dart`, `subtitle_translate_service.dart`, `lib/pages/setting/ui_translate/view.dart`, `lib/utils/storage_key.dart`, `lib/utils/storage_pref.dart`.
- Tests: artifact/job/prefetch/text-quality tests under `test/services/ui_translate/`.

## Validation

- FAST/AFFECTED: PASS, `flutter test test/services/ui_translate` (`65/65`).
- Affected Flutter analyze: PASS with exit code 0; 28 existing/info-only notices remain, mainly slow async I/O and test style.
- `git diff --check`: PASS.
- Release build: PASS on 2026-11-05 using Flutter 3.47.2, Android SDK build-tools 37 and Temurin JDK 17.
- APK: `build/app/outputs/flutter-apk/app-release.apk`, 120,065,502 bytes, SHA-256 `a0f9de187f2a8f602b4785a23e7042f036741ff87ba6747db7935d52b14a2ddd`.
- APK ZIP integrity: PASS. APK Signature Scheme v2 verification: PASS (existing Android debug signing certificate).
- ADB: no connected device returned by `adb devices -l`; install and startup/crash smoke were not run.
- Independent Antigravity review: bridge health passed, but review attempts were unavailable (permission denial, then timeout); do not retry repeatedly.

## Remaining risks and next action

- Reconnect the Android device, then run `adb install -r -g`, launch `com.example.pilibabel`, scan for `AndroidRuntime`/`FATAL EXCEPTION`, and perform interactive subtitle checks (seek past minute four, track switching, cache restore and playlist prefetch).
- Push is gated on successful device startup smoke per the requested release plan. Commit may be prepared locally while the device is disconnected.
- Real provider/proxy translation throughput still requires device/network smoke evidence.
- Preserve user-owned untracked `.agentboard/`, `.codebase-memory/`, `.cursor/` and `.ruler/` directories.
