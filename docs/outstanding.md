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
