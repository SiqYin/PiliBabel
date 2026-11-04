# Active work

- Objective: Keep the durable Vietnamese subtitle pipeline intact while integrating stable upstream PiliBabel `v3.6.5` fixes and glossary improvements.
- Branch: `codex/subtitle-translation-proxy` tracking `origin/codex/subtitle-translation-proxy`.
- Status: Upstream `v3.6.5` integration is complete and release-ready; affected tests/analyze, APK build/signature, ADB install and startup smoke pass.

## Completed

- Added stable-ID `SubtitlePlaybackTrack` models and a shared source resolver. Bilibili Chinese tracks retain their original URI; app-translated Vietnamese uses a separate VTT and menu entry.
- Added `SubtitleTranslationArtifact` identity keyed by video, CID, target/source language, source content and timeline fingerprint. Completion requires atomic write/readback, exact cue count/order/timestamps, and no unresolved Chinese/source-copy/likely-English output.
- Unified online playback, background-card translation, playlist/multipart work, retranslations and offline download around the same source-selection and artifact validation rules.
- Manual track/off selection no longer cancels jobs. Automatic switching occurs only after translated output is available and respects manual choice for the current part.
- Background progress includes translated cue count and failed chunks. Multi-part status reports `x/y phần`; old completion markers are treated only as hints and verified artifacts rebuild completion state.
- Offline downloads materialize a verified Vietnamese artifact as `vi-app-ai.vtt` and expose it as `Tiếng Việt (AI dịch)`.
- Translation defaults remain 20 cues/chunk, overlap 4, five direct workers, 60-second request timeout and six slots per healthy proxy. A proxy begins with one probe slot and expands after success; connection/auth/429/5xx failures trigger cooldown/rotation.
- Merged upstream `v3.6.5` without replacing the custom subtitle runtime. The merge retains stable Vietnamese tracks, durable artifacts, proxy workers and retry/checkpoint behavior.
- Integrated upstream glossary indexing, first-character buckets, short/full term handling, glossary management UI, prewarmed UI strings and black-screen/crash fixes.
- Embedded glossary terms no longer produce a partially translated mixed-language sentence. The full sentence is sent to the model with the official/community term supplied as a prompt hint.

## Files changed

- Player/UI: `lib/pages/video/controller.dart`, `lib/plugin/pl_player/view/view.dart`, `lib/common/widgets/video_subtitle_translate_button.dart`.
- Translation/cache: `lib/services/ui_translate/subtitle_playback_track.dart`, `subtitle_source_resolver.dart`, `subtitle_translation_artifact.dart`, `subtitle_translation_background_service.dart`, `subtitle_translation_job.dart`, `subtitle_translation_proxy.dart`.
- Offline: `lib/services/download/download_service.dart`.
- Upstream UI translation: `lib/services/ui_translate/ui_translate_service.dart`, `game_glossary.dart`, `glossary_update_service.dart`, `prewarm_strings.dart`, and `lib/pages/setting/ui_translate/glossary_tables.dart`.
- Tests: playback-track, source-resolver, artifact, job, proxy, Vietnamese UI and glossary regressions under `test/services/ui_translate/`.

## Validation

- FAST/AFFECTED tests: PASS, 60 focused subtitle/cache/source/proxy/Vietnamese UI/glossary tests.
- Affected Flutter analyze: PASS across 19 changed Dart files with no issues.
- `git diff --check`: PASS.
- Release build: PASS on 2026-11-04 using Flutter 3.47.2, Android SDK 37 and a locally extracted Temurin JDK 17.
- APK: `build/app/outputs/flutter-apk/app-release.apk`, 120.5 MB, SHA-256 `1b9580fc32be6b7a89ba6bbd687d44544b4f18567c7019ea60399edc724f49a8`; ZIP integrity and APK Signature Scheme v2 verification pass.
- ADB install: PASS with `adb install -r -g` on `XHK6R20612001230` (`MRX_W29`), preserving app data/cache. Package `com.example.pilibabel` reports version `3.6.5`; `MainActivity` resumed and no `AndroidRuntime`/`FATAL EXCEPTION` appeared in the startup log scan.
- Startup log still reports non-fatal media option warnings for `reconnect_streamed`, `reconnect_delay_max`, `multiple_requests` and `http-persistent`; they do not prevent launch.
- Independent Antigravity review: unavailable because the required Antigravity bridge is absent; no native `agy` fallback used.

## Remaining risks and next action

- Next action: perform interactive subtitle smoke tests on the device: switch Chinese/Vietnamese/off, seek past minute four, change video while translation runs, background/restore the app, verify proxy expansion and test offline Vietnamese playback.
- Jobs resume from durable chunk checkpoints when restarted, but there is no Android foreground service that guarantees execution after the OS kills the app process.
- Real translation-provider and proxy behavior still require device/network smoke evidence.
- Preserve user-owned untracked `.cursor/` and `.ruler/` directories.
