### PiliBabel v3.4.5

**Fixes the leftover silent video after merging in v3.4.4: a folder used to end up with both "xxx (1080P+).mp4" (silent) and "xxx (合并).mp4" (with sound).**

**Cause.** The merged output was given a **new name** via `uniquePath` (`title (合并).mp4`), and only then did the code try to delete the original video track. The deletion was a single `deleteSync`, but the downloader had only just closed its write handle — on some platforms (especially Windows) the file is briefly still held open. The delete failed, the failure was silently swallowed, and the silent original video stayed behind. Hence two files.

**Fix.**
1. Merging now writes to a **temporary file** and only moves it into place after a non-empty check, so a half-written output can never be left behind.
2. Deleting the split tracks now **retries** (up to 6 attempts, 150 ms apart) to let the holding process release the handle.
3. After a successful delete, the merged file is **renamed to the original video's name** (quality suffix preserved, e.g. `title (1080P+).mp4`) — so the folder ends up with exactly **one** file, named consistently with single-file tiers, and no stray "(合并)" file.
4. If the original video track genuinely cannot be deleted (extreme locking), the merged file is kept and its path returned — better an extra file than losing the one the user can actually play.

**No "(合并)" in the exported filename.** The merged output finally uses the **video's own title** (quality suffix preserved, e.g. `title (1080P+).mp4`). The parenthesis marker was only an internal implementation detail and has no business appearing in a filename the user sees.

**Smaller APK.** Bundling FFmpeg had pushed the APK from 75.9 MB to 105.2 MB. The `_min` variant is already the smallest feature set, but it ships `.so` files for five CPU architectures by default. It is now limited to the two a phone actually needs — `arm64-v8a` (modern devices) and `armeabi-v7a` (older 32-bit ones) — dropping x86/x86_64, which only emulators and a handful of ChromeOS devices use. This should save well over ten megabytes. Desktop builds (Windows/Linux) are unaffected.

Downloads are below.