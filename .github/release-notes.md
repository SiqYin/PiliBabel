### PiliBabel v3.5.8

**Zenless Zone Zero glossary greatly expanded; glossary can now check for updates; live rooms can save their cover.**

**Zenless Zone Zero glossary switched to a living source.** The previous source stopped updating in July 2024 and only covered versions 1.0/1.1, which is why Chinese/Japanese/Korean coverage sat at 6%. It now uses a community-reviewed multilingual glossary (tagged up to version 3.3): rows **1057 → 2907**, Simplified Chinese **94 → 2270**, Japanese **61 → 2256**, Korean **61 → 2257**.

**Glossary update check.** Settings → AI Translate now has a "Game glossary" entry. It can be checked manually, and will also check itself at most once per 24 hours. The check only fetches a few-KB version manifest (no term data), then compares per-game version and hash; if something moved it reports "N game glossaries can be updated". The manifest URL can be pointed at your own mirror via `Pref.glossaryManifestUrl`.

**Live room "save cover".** The live-room overflow menu previously offered only copy link / share room / open in browser / share to messages — **there was no way to save the cover**. It has been added, reusing the exact same save implementation as the video page's "save cover". The entry is hidden when no cover is available.

**Still incomplete (missing upstream data, not a missing feature):** Japanese/Korean names for Wuthering Waves, EN/JA/KO names for Honkai Impact 3rd, and Korean names for some Genshin NPCs do not exist in any public source I could find. Details are in `docs/outstanding.md` section 9.

Downloads are below.
