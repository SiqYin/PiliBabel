### PiliBabel v3.9.4

**The download icon in the audio player now downloads the audio.**

On the listen-as-audio screen, the download icon in the top-right corner opened the in-app audio cache. That cache writes into the app's own storage and lists the result under 离线缓存 → 缓存音频 — so nothing ever appeared in a folder you could open, even though the icon promises a download. The icon was wired to the wrong action.

It now saves the audio to the download folder you picked, into the same place as 下载到本地 → 下载音频, and the entry shows up under 离线缓存 → 下载音频 with its progress. If you have never set a download folder, the system folder picker opens right away instead of sending you to the settings page.

**The cache entry is still there — it moved into the ⋮ menu.** Both entries now carry a subtitle that says where the file ends up ("stored in the app's cache, listed under 离线缓存" versus "saved as a file in the folder you picked, listed under 下载音频"), because two entries with almost the same name were exactly what made this confusing in the first place. The quality picker is shared, and its title and hint follow whichever entry you used.

Nothing else changed: both paths still keep the original container without transcoding, still fall back to the closest available quality when the one you picked is not offered, and still keep the failed-download record so you can retry it later.
