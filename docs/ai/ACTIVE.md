# Active work

- Objective: Stabilize Vietnamese subtitle playback as an independent track, keep translation jobs/cache durable, and support realtime/background/offline translation without changing source cue timing.
- Branch: `codex/subtitle-translation-proxy` tracking `origin/codex/subtitle-translation-proxy`.
- Status: Implementation complete locally; release APK built, installed over ADB, launched, and startup-smoke verified on the connected Android device.

## Completed

- Added stable-ID `SubtitlePlaybackTrack` models and a shared source resolver. Bilibili Chinese tracks retain their original URI; app-translated Vietnamese uses a separate VTT and menu entry.
- Added `SubtitleTranslationArtifact` identity keyed by video, CID, target/source language, source content and timeline fingerprint. Completion requires atomic write/readback, exact cue count/order/timestamps, and no unresolved Chinese/source-copy/likely-English output.
- Unified online playback, background-card translation, playlist/multipart work, retranslations and offline download around the same source-selection and artifact validation rules.
- Manual track/off selection no longer cancels jobs. Automatic switching occurs only after translated output is available and respects manual choice for the current part.
- Background progress includes translated cue count and failed chunks. Multi-part status reports `x/y phần`; old completion markers are treated only as hints and verified artifacts rebuild completion state.
- Offline downloads materialize a verified Vietnamese artifact as `vi-app-ai.vtt` and expose it as `Tiếng Việt (AI dịch)`.
- Translation defaults remain 20 cues/chunk, overlap 4, five direct workers, 60-second request timeout and six slots per healthy proxy. A proxy begins with one probe slot and expands after success; connection/auth/429/5xx failures trigger cooldown/rotation.

## Files changed

- Player/UI: `lib/pages/video/controller.dart`, `lib/plugin/pl_player/view/view.dart`, `lib/common/widgets/video_subtitle_translate_button.dart`.
- Translation/cache: `lib/services/ui_translate/subtitle_playback_track.dart`, `subtitle_source_resolver.dart`, `subtitle_translation_artifact.dart`, `subtitle_translation_background_service.dart`, `subtitle_translation_job.dart`, `subtitle_translation_proxy.dart`.
- Offline: `lib/services/download/download_service.dart`.
- Tests: playback-track, source-resolver, artifact, job and proxy tests under `test/services/ui_translate/`.

## Validation

- FAST/AFFECTED tests: PASS, 51 focused subtitle/cache/source/proxy tests.
- Affected Flutter analyze: PASS with 21 informational `avoid_slow_async_io` lints; no errors or warnings.
- `git diff --check`: PASS.
- Release build: PASS on 2026-11-04 using Flutter 3.47.2, Android SDK 37 and a locally extracted Temurin JDK 17.
- APK: `build/app/outputs/flutter-apk/app-release.apk`, 113.9 MiB, SHA-256 `04a7dfff53db4c0bff928bb1d7ce3d84228a3e7551f49e69beb9f3a7afcba3ae`; ZIP integrity and APK Signature Scheme v2 verification pass.
- ADB install: PASS on `XHK6R20612001230` (`MRX_W29`), package `com.example.pilibabel`, version `3.6.1`; `MainActivity` resumed and no `AndroidRuntime`/`FATAL EXCEPTION` appeared in the startup log scan.
- Independent Antigravity review: unavailable because the required Antigravity bridge is absent; no native `agy` fallback used.

## Remaining risks and next action

- Next action: perform interactive subtitle smoke tests on the device: switch Chinese/Vietnamese/off, seek past minute four, change video while translation runs, background/restore the app, verify proxy expansion and test offline Vietnamese playback.
- Jobs resume from durable chunk checkpoints when restarted, but there is no Android foreground service that guarantees execution after the OS kills the app process.
- Real translation-provider and proxy behavior still require device/network smoke evidence.
- Preserve user-owned untracked `.cursor/` and `.ruler/` directories.
