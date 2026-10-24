### PiliBabel v2.6.3

**Download-to-local actually works, and you can see what happened to every download**

**Fixed: download-to-local failed, and the exported MP4 was 0 bytes**

- A `fnval=1` single muxed MP4 is signed *for its own host*. The app rewrote that host to another CDN, which the server rejects with 403 — so every candidate failed and the file that had already been created stayed at 0 bytes.
- Host rewriting is gone: the URL the server returned is tried first, with its backup URLs as fallbacks, exactly like the mature `DownloadHttp` path does for `durl`.
- The request now uses bilibili's own downloader User-Agent and a Referer with the trailing slash, matching the player's own headers.
- If every line fails, the empty file is removed instead of being left behind as a fake 0-byte video.

**New: Download status page**

- *Mine → Offline cache* now has a third button, *Download status*, next to *Cache video* / *Cache audio*.
- It splits into *Downloaded video* / *Downloaded audio*, and for every item shows the cover, the title, the UP name, how much has been downloaded out of the total size, and a progress bar while it is still downloading.
- If the local file is gone, the row says so: *Local file deleted*.
- The three-dot menu offers *Delete* (removes the local file; the row stays and becomes *Local file deleted*) and *Clean up record* (only enabled once the file is missing — that is what finally removes the row). Deleting asks for confirmation first.

**Fixed: translations left over from the previous language**

- The translation cache was a flat *source → translation* map with no language dimension. Switching language cleared it, but requests still in flight when you switched came back afterwards and were written into the cache as if they belonged to the new language — a handful of strings (often UP names or titles) stayed in the old language forever and survived restarts, leaving manual cache-clearing as the only cure.
- The cache is now bucketed per target language, and every in-flight request writes into the language it was issued for. Switching language therefore keeps the previous language's translations available (switching back is instant) without ever mixing them into the new one.

**New: Russian README**

- `README.ru.md`, with the same screenshots as the English one; every language version now links to it.

Everything inherited from PiliNara / PiliPlus is unchanged.

Downloads are below.
