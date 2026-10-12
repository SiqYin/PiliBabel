### PiliBabel v1.6.2

- **Subtitles can now follow your interface language.** Bilibili delivers auto-translated subtitles as *separate tracks the server has already generated* — the official FAQ describes ASR on the foreign-language audio and then a machine translation on top (Chinese → English/Thai/Indonesian/Vietnamese, English/Japanese/Korean → Chinese), and they show up in the subtitle menu as 「中文（自动翻译）」. So the official app's "set the interface to English and the English subtitles turn on" is just picking the matching track on the client; there is no translation API to call and nothing extra to pay for.
- **New subtitle preference: 「跟随界面语言」** (我的 → 设置 → 播放设置 → 字幕偏好). An English interface picks the English track, a Japanese one the Japanese track. It is appended at the end of the enum, so the three existing preferences keep their stored values and behave exactly as they did.
- **Matching is deliberately tolerant.** Bilibili writes the same language in several shapes (`zh-CN`, `zh-Hans`, `ai-zh`), so tracks are scored rather than compared: exact match, same language, same language but a different Chinese script, or no match. Simplified Chinese no longer loses to a Traditional track merely because the string differs.
- **Dual subtitles come along for free.** When the chosen track is a translation rather than the original, the other track is attached as the secondary subtitle — the same English-over-Chinese pairing the official app calls 双语字幕. It only ever fills an empty slot, so a secondary subtitle you picked yourself is never overwritten.
- If nothing matches your interface language, the old rule still applies (first track, unless it is an AI track and the device is not muted), so you get a subtitle rather than none.
- One limit worth stating plainly: the interface language cannot conjure up a track the server never sent — this only chooses among the tracks Bilibili already delivers.

Downloads are below.
