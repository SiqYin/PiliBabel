### PiliBabel v3.5.2

**Short names now actually apply where they matter: titles and the comment
section.** Plus the two previous releases are summarised below.

- **The abbreviation rule is wired up — 31 UI surfaces.** Until now `txTight()`
  existed but nothing called it, so the full/short rule never fired. It now
  covers:
  - **23 list / card titles** — video cards (H/V), dynamic video & extra cards,
    live cards, embedded opus cards, audio lists, download list & detail,
    article list, search suggestions, messages, member pages;
  - **7 navigation labels** — home tabs, the three bottom-bar variants, drawer,
    rail (including the rail width measurement, which must render the same
    form as the label or the width comes out wrong);
  - **the comment section** — comment bodies now pick the short form too,
    because a comment section *is* the community.
- **Result (same data, measured):**

  | Term | Title / comments | Body text |
  |---|---|---|
  | 绝区零 | ゼンゼロ / 젠존제 / ZZZ | ゼンレスゾーンゼロ / 젠레스 존 제로 / Zenless Zone Zero |
  | 崩坏：星穹铁道 | スタレ / 붕스 / HSR | 崩壊:スターレイル / 붕괴: 스타레일 / Honkai: Star Rail |
  | 蔚蓝档案 | ブルアカ / 블아 / BA | ブルーアーカイブ / 블루 아카이브 / Blue Archive |
  | 明日方舟 | アクナイ / 명방 / AK | アークナイツ / 명일방주 / Arknights |

- New helper `uiTxTight(src)`. Glossary entries marked as *inferred* are **live
  and in normal use** — the yellow highlight in the reference sheet only
  distinguishes official sources from inferred ones; it is not a to-do.

中文摘要：简称机制此前只有实现、没有调用方，实际没生效。本版接入 **31 处窄位界面**——
列表/卡片标题 23 处、导航标签 7 处（含侧栏宽度测量，必须与渲染同形态）、
评论区正文（评论区本身就是社区语境）。效果：标题与评论区用 ゼンゼロ / スタレ /
ブルアカ / アクナイ 这类通行简称，正文才用全称。术语表中标记为「推断」的条目
**已正常启用**，标黄只用于区分来源，不是待办。

---

### PiliBabel v3.5.1

**New: Arknights (明日方舟) glossary — the 8th game.**
**Fixed: three kinds of error popups (malformed retry URL / credential leak / type-error crash).**

- **Arknights glossary (5,663 terms).** Official data from all five servers
  (CN 简中 / TW 繁中 / EN / JA / KR, `ArknightsAssets/ArknightsGamedata` client
  data tables, auto-synced daily), joined by the same in-game IDs — official
  text, not machine translation. Covers operators / NPCs / enemies / items /
  skills. Traditional Chinese comes straight from the TW server (no conversion).
  Game title carries community short forms per our slang-first policy:
  アークナイツ→**アクナイ**, 명일방주→**명방**, Arknights→**AK**.
- **Fixed the malformed retry URL (`https://https//app.bilibili.com/...`).**
  The host list stores full URLs (`https://app.bilibili.com`), but the
  host-switch retry composed `scheme://$host` with it, producing
  `https://https://app.bilibili.com` — exactly the broken URL in the error
  popups; every such retry was doomed. Worse, the "current host" comparison
  compared a bare hostname against full URLs and never matched, so host
  switching had never actually switched. Both fixed.
- **Fixed error popups leaking the full request URL.** Toasts appended the raw
  request URI, whose query string contains `access_key` / `sign` credentials —
  one screenshot and they are out. Popups now show only `scheme://host + path`
  (truncated), with a space between message and URL.
- **Hardened the cookie header handling.** dio headers are
  `Map<String, dynamic>`; when the cookie header holds a List, the previous
  `as String?` cast threw
  `type 'List<dynamic>' is not a subtype of type 'String'` — the most likely
  source of that popup. Both String and List are now accepted. Per user
  decision, raw type-error text is still shown verbatim (to help future
  diagnosis) until the root cause is fully pinned down.

中文摘要：新增《明日方舟》术语表（五服官方数据按 ID 对齐，5663 条，繁中为台服官方数据）；
修复换主机重试拼出 `https://https//...` 坏地址（且换主机从未真正生效）的根因；
修复错误弹窗泄露带 `access_key`/`sign` 的完整 URL（现只显示 host+path 并截断）；
兼容 cookie 头为 List 时的类型崩溃，类型错误信息按要求保留上屏以便查证。

---

### PiliBabel v3.5.0

**New: game glossary + full/short name mechanism.** UI translation now uses
official localized names for game proper nouns instead of leaving them to the
model.

- **Seven games, five languages, ~4,900 core terms embedded**: Genshin Impact /
  Honkai: Star Rail / Zenless Zone Zero / Wuthering Waves / Honkai Impact 3rd /
  Blue Archive / Goddess of Victory: NIKKE. Sources: official HoYoWiki API,
  game-extracted text (StarRailRes / ZenlessRes), and community wikis
  (Fandom / BWIKI), aligned by official IDs — not machine translation.
- **Two activation paths**: (1) exact match — any-language full or short form of
  a term returns the official name directly (no cache, no request, cannot be
  overridden by the model); (2) prompt injection — terms found in the batch are
  forced onto the model via the system prompt.
- **Full/short name mechanism (no longer hard-coded per phrase)**: official and
  community short forms (ゼンレスゾーンゼロ→ゼンゼロ, 崩壊:スターレイル→スタレ,
  ブルーアーカイブ→ブルアカ, Wuthering Waves→WuWa…) are first-class. Bilibili
  gaming comment sections *are* the community, so community slang is legitimate
  and preferred: any term with an established short form defaults to it;
  body-text width expands to the full name. New `txTight()` for narrow spots
  (list titles / buttons / tabs).
- The old hard-coded `'绝区零': 'ゼンゼロ'` pin was removed — it now falls out of
  the general mechanism. Prompt revision +1 (9): old translation caches are
  retranslated once after upgrade.

中文摘要：内嵌七款游戏五语核心术语表（约 4900 条，官方渠道按 ID 精确对齐）；
命中术语直接返回官方译名 + 批量翻译注入提示词双链路；全称/简称通用机制——
社区俚语简称（ゼンゼロ/スタレ/ブルアカ/WuWa 等）直接转正、默认使用，
正文宽度才展开全称；移除「绝区零→ゼンゼロ」硬编码。

Downloads are below.
