### PiliBabel v3.8.13

**Eight more upstream features land, and the tâi-gí interface stops showing stale or self-looped translations.**

**PGC pages can cache directly.** 番剧/影视 的简介页多了「缓存」动作，和收藏、再看、转发并排；点它直接打开下载面板，不用先播放再缓存。

**Holding ← rewinds continuously.** 桌面端按住左方向键，每 200 ms 退一档，松开时一次性 seek 到目标位置；短按仍是退一档。

**The recommendation feed has a refresh button.** 桌面端「推荐」右下角出现悬浮刷新按钮，一按回到顶部并重新拉取；可在设置里关掉。

**Videos can be rotated on desktop.** 简介操作行新增「向左旋转 / 向右旋转」，角度写在 `video-rotate` 上，重开播放器也不会丢。

**A third recommendation source: 桌面端.** 推荐源从「App / Web / 合并」扩到四选一，桌面端沿用同一个公开网页接口，但改用官方 Windows 客户端的参数组合（`plat=1`、`feed_version=V1`、3×4 网格、每页 30 条）。

**Full-screen SuperChat has opacity and scale.** 全屏 SC 不再只有宽度可调：设置页新增透明度（0.2–1.0）与缩放（0.5–1.5）两个滑块，预览区实时生效。

**AI chat requests can be stopped.** 流式回答进行中，输入栏的发送键变成停止键；中断后已收到的内容保留，可以立刻重新提问。

**Stale translations are rejected.** 早期 tâi-gí 译文里夹着大量繁简中文、甚至整段照抄原文，这些条目命中缓存就永远不会重译。现在加载时按规则判废并回写：空译文、与原文相同、tâi-gí 仍含汉字，一律丢弃并重新排进翻译队列；界面在译文回来前先回落原文。

**Self-looped translations are blocked.** 「翻译引擎、应用语言与界面翻译」曾被译成 `Ìn-sīn ê ìn-sīn, ìn-sīn ê ìn-sīn, ìn-sīn ê ìn-sīn.` —— 同一分句复读三遍。现在按分句去重判废，并且拉丁字母目标语言遇到不含汉字的原文直接原样返回，不再把译文送去二次翻译。
