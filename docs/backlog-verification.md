# 大修清单「未做 / 部分」项的代码核实结果

**核实时间**：2026-10-28
**核实方式**：逐项对照 `lib/` 实际代码与 git 历史，不以清单文字为准
**背景**：`12-大修总清单（3.0.5以来）.md` 整理于 v3.3.4 前后，用户明确「这份清单仅供参考，
部分标未做/部分的后来也补做了，项目是全的」。本文档记录核实后的**真实状态**，
避免以后重复按过时清单排查。

---

## 一、清单标「未做」的 5 项 —— 核实后全部已实现

| 条目 | 清单状态 | **核实结果** | 证据 |
|---|---|---|---|
| **A1.4** DNS 解析失败/超时埋点 | 未做 | ✅ **已实现** | `dns_resolver.dart`：`resolveCount` / `systemFailCount` / `totalResolveMs` / `lastResolveMs` / `slowestResolveMs` 计数，`stats()` 汇总串（含 avg/last/slow），`logStats()` 输出 |
| **A4.2** 测速结果与连接池共享 | 未做 | ✅ **已实现** | `host_health.dart`：`recordSpeed()` / `speedOf()`，`_score()` 把实测速率按峰值归一化后以最高 0.3 权重折入主机评分；`cdn_speed_test.dart` 两处 `result.forEach(HostHealth.instance.recordSpeed)` 写入 |
| **B3.1** 二屏卡片接口预取 | 未做 | ✅ **已实现** | `rcmd/controller.dart` `_prefetchNextPage()`；`feed_next_page.dart` 的 `FeedNextPage`（TTL 90s、一次性消费）；首屏成功后 `page==0` 触发 |
| **B3.2** 下拉刷新去重 | 未做 | ✅ **已实现** | `feed_next_page.dart` `generation` 代次机制 + `put()` 代次不符即丢弃；`onRefresh()` 里 `FeedNextPage.bumpGeneration()` + `FeedIdx.clear()` |
| **D4.2** 展开更多回复与官方对齐 | 未做 | ✅ **已实现** | `reply_item_grpc.dart`：未展开显示「共 {0} 条回复，点击展开」、已展开显示「展开剩余 {0} 条回复」，点击续加载，文案走 `uiTxP` 接 AI 翻译 |

## 二、清单标「部分」的 5 项 —— 核实结果

| 条目 | 清单标 | **核实结果** |
|---|---|---|
| **A1.3** DoH | 部分（缺独立开关/默认关/灰度） | ✅ **开关已独立**：`Pref.dnsDoh` + 设置项「DNS 加密兜底解析」+ `SettingBoxKey.dnsDoh`，默认**开**。<br>⚠️ 与「默认关」的原计划不同 —— **刻意保持默认开**：DoH 只在系统解析失败后才介入，正常路径零成本，默认关反而削弱弱网兜底。<br>「灰度」无实施对象（无灰度通道/用户分群），不适用。 |
| **A2.1** 主机清单表 | 部分（未落成可读表） | ✅ **已落成**：`http/constants.dart` 的 `hostTable`（`List<HttpHostInfo>`），逐条写明「主机 / 用途 / 是否走 gRPC / 是否参与故障切换」，并有 `isGrpcHost()` / `isPolicyHost()` / `grpcAlternatives()` 消费它 |
| **B4.1** open_event / login_event | 部分 | ✅ `open_event`（进程内首次取 feed 置 1）、`login_event`（登录后首次取 feed置 1）均已实现并接入 `rcmdVideoListApp`。<br>⚠️ `banner_hash` **未传** —— 见下方说明 |
| **C1.2** 已缓存时长与字节统计 | 部分 | ✅ `audio/view.dart`：`buffered` 秒数 + 占全长百分比（`已缓存 {0}，占全长 {1}%`）+ 进度条已缓存段（`buffered`/`bufferedBarColor`）；`audio/controller.dart` 取 `player.state.buffer` |
| **C2.2** 预取与 A4 候选探测合并 | 部分 | ✅ `video_utils.dart` `_firstUsable()`：先排除冷却主机，再取 `HostHealth` + `CdnSpeedTest.bestOf()` 结论；音频与视频共用同一套候选结论 |

### 关于 `banner_hash`（唯一仍未实现的子项）

`banner_hash` 是官方首页 feed 的**横幅曝光去重**参数：客户端把已曝光横幅的哈希回传，
服务端据此不再重复下发同一个横幅。

**不实现的原因**：本项目的首页没有渲染服务端下发的 feed 横幅（`RcamdVideoItemAppModel`
与首页布局都不使用该字段）。传一个永远为空/伪造的 `banner_hash` 属于**凑参数**，
既不改变任何实际行为，也谈不上「对齐官方」。等真的接入 feed 横幅渲染时，再连同
「记录已曝光横幅哈希」一起实现才有意义。

## 三、清单第 68 条 analyze 尾巴 —— 已于 v3.3.17 完成

**CI 实证**：`errors 0 / warnings 42 → 0 / infos 377`（infos 主要是 `prefer_const_constructors`）

清理内容（22 个文件）见 CHANGELOG 3.3.17 与提交 `9d10f7dee` / `a108cf796` / `23f054609`。

> 过程中我自己误删 import 导致 `member_opus` 留下悬空 `hide` 续行、产生 2 个 error，
> 被 CI 抓到后修复。再次印证清单第 90 条：**analyze 带 `|| true` 时不可信，以真实编译为准**。

## 四、清单第 84–86 条 README 文档缺口 —— 已处理

- **第 84 条「下载情况未进任何 README」**：清单已过时。各语言 README 均有
  「Offline audio caching & download-to-local」独立小节（含媒体缓存与下载到本地两段）。
- **第 85 条「部分语言三节正文仍英语」**：核实发现早期语言（中/粤/日/法等）正文已是
  完整本地化；只有免责声明/开源协议几节沿用英文原文（法律文本刻意不译）。
- **第 86 条「缺 AI 撰写声明」**：已为全部 **44 份** README 补上
  「文档由 AI 翻译工具协助撰写维护、以英文为准」的说明。
- 另发现并修复：早期 11 种语言的**语言数量描述过时**（写「含 4 种少数民族语言 + 3 种方言 /
  150 种」，英文基准已改为「151 种 + 官方未收录 6 种」），已按英文同步。

## 五、阻塞 / 后置项（不硬做，原因见下）

| 项 | 状态 | 原因 |
|---|---|---|
| 首页 feed 迁 gRPC | 未做 | 仓库内与公开 proto 合集都没有 `bilibili.app.show` 的 feed proto，无字段依据；无真机无法验证。需从官方 APK 提取描述符或找带 .proto 的公开包才能推进 |
| 动态主 feed 迁 gRPC | 未做 | 仓内已有 dynamic v2 的 pb 与端点，属「有基础但要真机逐字段对齐」，风险高 |
| 主搜索迁 gRPC | 不做 | 无 pb，且按计划保持 REST |
| 换播放内核 | 后置 | 需独立评估（mpv → 其他栈），改动面过大 |
