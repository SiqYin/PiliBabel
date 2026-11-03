# PiliBabel 待办总清查

**清查时间**：2026-10-28（针对 v3.3.25 代码状态）
**基线**：`flutter analyze` → errors 0 / warnings 0 / infos 373

本文档是「到目前为止还有什么没做」的唯一权威清单，替代
`12-大修总清单（3.0.5以来）.md` 里已过时的状态标记（该清单整理于 v3.3.4 前后）。

---

## 一、需要你在真机上验证的（我无法代劳）

清单第 91–102 条。其中多数**代码侧已经改过**，只是还没得到你的实测确认：

| # | 验证内容 | 代码侧状态 |
|---|---|---|
| 91 | 评论区首屏出评论 / 点击重试真的重发 / 楼中楼翻页 | 已修（gRPC 主机顺序等问题） |
| 92 | 动态缩略图是否恢复 | 已随图片管线修复 |
| 93 | 缓存音频顶部是否还有静止 100% 条；删掉任务后 P1 能否正常播、拖进度是否跳 00:00 | 已修 |
| 94 | 四条「重新缓存 / 重新下载」入口是否出现并生效 | 已实现 |
| 95 | 首页视频封面能否加载 | 已随图片直连 + 预取修复 |
| 96 | 首帧 + 弱网：约 14s 内自动切线路；全坏时给「点击重试」 | 已实现 |
| 97 | 10 分钟播放无 0% 卡死 / 二屏白块 / 换网刷新 / 代理档位 / gRPC 开关 | 已实现 |
| 98 | 更新推送能否收到；「关于」页 Build Time 是否正常 | 已修（真赛马 + 版本号判据） |
| 99 | 更新弹窗 Release 正文的 AI 翻译是否刷新 | 已实现 |
| 100 | 缓存进度文案与开始缓存提示 | 已实现 |
| 101 | 已缓存音频的缓存入口 / 分离流下载 / Hi-Res / 画质音质标蓝 | 已实现 |
| 102 | 动态四种卡片类型渲染 | 已实现 |

**两条待定性**：

- **更新推送（第 83 条）**：逻辑已修，但「收不到」的最可能原因仍是**装的 debug 包**
  （`update.dart` 里 `if (kDebugMode) return;`）。判定方法：看「我的 - 关于」的 Build Time，
  版本号后缀带 commit 短哈希就是 debug / 本地构建。
- **首页视频封面（第 80 条）**：已随 3.3.12~3.3.14 的图片管线改动修复，待你确认。

---

## 二、明确阻塞 / 不做（有充分理由，不硬做）

| 项 | 状态 | 原因 |
|---|---|---|
| 首页 feed 迁 gRPC（第 10 条） | **阻塞** | 仓内与公开 proto 合集都没有 `bilibili.app.show` 的 feed proto，无字段依据、无真机无法验证 |
| 动态主 feed 迁 gRPC（第 87 条） | **不做** | 评估结论：gRPC 返回的动态正文是纯文本，会损失富文本结构 |
| 主搜索迁 gRPC（第 57 条） | **不做** | 无 pb，按计划保持 REST |
| 换播放内核（第 88 条） | **明确不做** | 用户已决定「暂不换播放内核」，本轮大修不涉及 |
| HTTPDNS（第 16 条） | **已由等价方案覆盖** | `DnsProxy` 本机解析代理就是 Flutter 侧能落地的形态 |
| 媒体层多连接（第 15 条 P3 路线） | **已由等价方案覆盖** | `MediaProxy`（2/4 段并发 Range）已实现 |

---

## 三、`prefer_const_constructors` 之外的 analyze 尾巴（infos 373）

**errors 0 / warnings 0**，剩下全是 info：

| 数量 | 规则 | 处理意见 |
|---|---|---|
| 296 | `prefer_const_constructors` | 机械补 `const`，量大且无用户可见收益；需要本地 analyzer 才敢批量做，暂不动 |
| 27 | `deprecated_member_use` | **23 处在上游 Flutter SDK 副本**（`lib/common/widgets/flutter/`），改了会增加升级合并成本；自有代码 4 处中 `color.alpha` 已修，`year2023` 与 `onReorder` 属**行为变更**，不为消 lint 而动 |
| 17 | `cascade_invocations` | 11 处在 SDK 副本；自有代码中已清理可清的 |
| 6 | `prefer_initializing_formals` | 涉及私有字段命名与签名，改动有回归风险，不动 |
| 5 | `use_build_context_synchronously` | 这几处 context 都是**在 await 之后才取得并已判空**，语义安全，不动 |
| 5 | `unnecessary_lambdas` | 其中 `live_room` 一处改成方法引用会改变回调签名，不动 |
| 2+2+2+2 | `unnecessary_import` / `library_private_types_in_public_api` / `unnecessary_async` / `avoid_void_async` | 低价值，暂不动 |
| 各 1 | `unnecessary_const` / `use_named_constants` / `cancel_subscriptions` / `prefer_const_declarations` / `unnecessary_nullable_for_final_variable_declarations` / `unnecessary_this` / `constant_identifier_names` / `package_names` / `prefer_const_literals_to_create_immutables` | 一条条评估过：`package_names` 是包名 `PiliPlus` 本身不能改；`reply_controller` 的 `Object? boxed` 是**故意**绕开 v3.3.3 编译器问题，不能动 |

> 结论：**analyze 侧不存在「还没发现的问题」**，只有「权衡后决定不修」的噪音。

---

## 四、文档

| 项 | 状态 |
|---|---|
| 「下载情况」未进 README（第 84 条） | **已完成**：各语言 README 都有离线缓存/下载小节 |
| 部分语言法律三节仍英文（第 85 条） | **建议保持**：免责声明/许可/致谢属法律文本，译错比不译风险大 |
| README 缺 AI 撰写声明（第 86 条） | **已完成**：44 份全部添加 |
| 各语言语言数量描述不一致 | **已完成**：中文 + 10 种早期语言已与英文基准（151+6）对齐 |

---

## 五、代码里的 TODO 标记（13 处，均非用户可见）

多为上游 PiliNara / PiliPlus 遗留的重构注释，例如：
`image_viewer/hero.dart` `// TODO: use real image rect`、
`sponsor_block.dart` `// TODO: show port video info dialog`、
`video/controller.dart` `// TODO: merge DownloadHttp.getVideoUrl`、
以及对 `dimension` 字段的几处 TODO（列表接口未下发尺寸）。

**这些不影响功能**，属技术债，没有排期。

---

## 六、已知差异（记录在 `docs/known-differences-vs-official.md`，非待办）

- 缓冲区填充节奏：官方「匀速跟随」，我们「临界补充」（你明确要求先记录、暂不改）
- `MediaProxy` 相对官方 ijk 多连接分片的简化点
- 首页 feed / 动态 / 主搜索仍走 REST（原因见第二节）

---

## 七、本轮大修状态

**3.0.5 → 3.4.0 这一轮大修已收尾。** 最终版 v3.4.0 发布后，
除第一节「需要真机验证」与第二节「明确阻塞/不做」之外，没有遗留的开发项。

---

## 八、2026-11-02 新增（官方 AI 声轨 + 耳机媒体键）

评估全文在 `docs/ai-audio-track-evaluation.md`（`docs/*` 被 .gitignore，仅本机）。
下面按「**已改代码但未验证**」与「**发现了但明确没做**」分两类，别混着看。

### 8.1 代码已改、真机未验证

| # | 事项 | 为什么还没底 |
|---|---|---|
| 1 | 耳机播放/暂停键（`49cc5be85`） | 根因确定（`audio_service` 把 PLAY/PAUSE/PLAY_PAUSE/HEADSETHOOK 全路由到 `click(MediaButton.media)`，默认实现看的是**上报给系统**的 `playbackState.playing`），但修复只在本机做了括号配平静检，**没真机按过一次** |
| 2 | 同一根因的**未修完部分**：`setPlaybackState` 的三道门槛（后台播放开关 / mediaItem 已注册 / `PlPlayerController` 实例存在）我**没动**，只改了按键判定路径。所以「听视频」页在通知栏 / 系统媒体面板里的播放-暂停**图标**可能仍是错的（上报值停在 `false`） | 动门槛会影响通知栏形态，没实测不敢改 |
| 3 | Windows SMTC / Linux MPRIS 的媒体键**没查** | 本轮只顺着 Android 的 `MediaButtonReceiver` → `handler.click()` 这条链查。注意本仓库用的是 **audio_service 的 fork**（`bggRGjQaUbCoE/audio_service`，ref `main`，见 pubspec.lock:100-108），Windows 侧的 SMTC 很可能是这个 fork 补的（`audio_handler.dart:320` 有「Windows SMTC 弹窗由 shell 进程渲染」的注释），Linux 走 `audio_service_mpris`；**这两条链路是否同样只看上报的 `playing` 完全没验** |
| 4 | 声轨跟随界面语言（`40ed8bc8c`）实际效果 | 依赖「登录后 `cur_language` 真的换流」——匿名实测被服务端直接忽略，带登录态从没验过。代码只认服务端回显（回显不匹配就当失败、照原声播），所以**不会谎称切换成功**，但也可能**永远切不动** |

### 8.2 发现了、明确没做

| # | 事项 | 位置 / 说明 |
|---|---|---|
| 5 | **gRPC `Playurl.ai_audio` 仍未解析**：官方 APP 是「一条响应并列各语言音轨」（`AIAudioItem{audio_info: repeated DashItem, subtitle_lang}`），比 Web 的 `cur_language` 换流更优（开播前不多一次请求） | `playershared.pb.dart:7923` 的 getter 无人引用。等真机确认它非空再上，不拿播放主链路赌 |
| 6 | **下载 / 音频缓存不传语言** → 缓存下来的永远是原声 | `audio_cache_service.dart:275`、`local_download_service.dart:363/455/826`、`http/download.dart:46`。要先定「同一 cid 的多语言缓存怎么共存」（现 key 是 `bvid_cid`） |
| 7 | **`Dash` 按 `id`（音质码）去重**，同音质不同语言的轨会被 merge 掉 | `url.dart:534-544` `BaseItemExt.merge` 用 `(id, codecid)` 做键。做 5 之前必须先解决，否则多语言轨会被折叠成一条 |
| 8 | `subtitle_lang` / `video_detext` 没消费 | 字幕侧靠 `Subtitle.langScore` 间接覆盖（`ai-en` 会归一化成 `en`），但「切到 en 轨后字幕是否真的跟着走 `ai-en`、两条链路时序会不会打架」**未验证**；`video_detext=true` 时服务端下发的是擦掉烧录字幕的画面，我们没有提示 |
| 9 | 自动切轨会多一次串行 playurl | 只在「支持且命中」的稿件上发生（实测热榜 2.7%），首帧约多 150–400ms。没做「按 cid 记住支持哪些语言」的缓存 |
| 10 | 语种覆盖本身很窄 | 实测只有 `en`/`ja`，且命中的 3 条**全部只有 en**；界面语言是韩/法/德/俄时这功能等于不存在 |

### 8.3 老遗留（与本轮无关，仍开放）

- `type 'List<dynamic>' is not a subtype of type 'String'`：3.5.1 修了高概率抛点（cookie 头为
  List），release 混淆下仍是 `<optimized out>`，**等下一张带完整类型名的截图**才能定位到字段。
- 术语表只内嵌了核心词 10571 条，全量 26739 条的按需加载没做。

---

## 九、2026-11-03：术语表更新 + 直播间封面

### 9.1 已完成

- **绝区零术语表换源**：`Odarom/zenless-translation-database`（社区复核多语库，
  标注 `sourceVersion 3.2`、覆盖到 3.3）。行数 1057 → **2907**，
  zh 94 → 2270、ja 61 → 2256、ko 61 → 2257。
  - 原数据源 `ZZZure/ZenlessRes` **2024-07-14 停更**，只覆盖 1.0/1.1，这是缺口的根因。
- **术语表自动更新检测**：构建侧 `probe_versions.py`（探测 8 款上游版本，实测 8/8 成功）
  → `make_manifest.py`（生成 `manifest.json`）→ 内嵌 `kGlossaryManifest`；
  运行时 `glossary_update_service.dart` 拉远端清单逐游戏比对 version/hash，
  AI 翻译设置页新增「游戏术语表」入口，24h 内不重复检查。
- **直播间「保存封面」**：原 ⋮ 菜单只有复制链接/分享/浏览器打开/分享至消息，**没有保存封面**。
  已加上，走 `ImageUtils.downloadImg`（与视频页「保存封面」同一套实现），
  地址复用 `roomInfoH5.roomInfo.cover`，无需额外请求。

### 9.2 未实现（缺数据源，非工时问题）

以下缺口**没有可行数据源**，不是没做，是试遍已知渠道都拿不到。
需要的是**新的社区/第三方数据源线索**，而不是更多时间。

| 缺口 | 规模 | 已试过并确认无效的渠道 |
|---|---|---|
| **鸣潮 ja/ko** | 缺 1418 条（28/1446 有值） | Fandom 无 `/ja/` `/ko/` 子站（全 404）；官方站为 SPA 取不到接口；`api.encore.moe` 404；`hakush.in` 域名已失效 |
| **崩坏3 en/ja/ko** | en 缺 379、ja 缺 385、ko 缺 404 | 不在 HoYoWiki API（`bh3`/`hi3`/`honkai3`/`bbs` 全 404）；Fandom langlinks 只有 pl/ru；唯一源 BWIKI 只偶尔带日英字段 |
| **原神 1581 条 NPC 韩文** | ko 覆盖 61%（7033/11505） | HoYoWiki 上游本身就没有这些 NPC 的韩文名；缺的全是称号类（「咕噜噜」「坎帕」这类带「」的名字），不是合并丢失 |
| **蔚蓝档案行数偏少** | 149 行（zh 103） | Fandom `name_cn` 字段绝大多数为空；BWIKI 分类仅 94 页 |
| **妮姬行数偏少** | 211 行（zh 91） | Fandom 无 `name_cn`；BWIKI 国服版本落后；`hibikidesu/nikke-data` 已 DMCA 下架 |
| **全量表按需加载** | 内嵌 10608 / 全量 29000+ | 未做（长尾词条仍在 `build/*.json`，不进包） |

### 9.3 术语表版本现状（基准日 2026-11-02，联网核实）

| 游戏 | 当前版本 | 术语表是否已覆盖最新 |
|---|---|---|
| 原神 | Ver 7.2 | ✅ 米提亚/阿罗夏/薇斯纳/沃雅妮莎全在库 |
| 崩坏：星穹铁道 | Ver 4.6 | ✅ Pearl 在库，五语齐 |
| 绝区零 | Ver 3.3 | ✅ 菲欧妮/塞维里安/薇琳娜/诺玛全在库 |
| 鸣潮 | Ver 3.8 | ⚠️ zh 在库，ja/ko 缺 |
| 崩坏3 | 未核到 | ⚠️ ja/ko 缺 |
| 蔚蓝档案 / 妮姬 / 明日方舟 | 未核到 | 前两者行数偏少；方舟五语齐 |
