### PiliBabel v3.8.14

**Collapsed replies come back, collection pages can be read backwards, and Linux desktops get proper media controls.**

**Folded replies can be expanded.** B 站会把重复或低质回复折进一张卡片。现在评论区页脚遇到折叠卡片时显示「展开被折叠的回复」，点一下才真正拉取那一批，拉完直接并入列表并给出提示——以前这些回复是看不到的。

**订阅合集支持页码倒序.** 合集详情右上角多了页码顺序按钮：选「倒序」时从最后一页往前翻，先看到最新的内容，不用一路翻到底。收藏夹原本就有这个能力，这次把订阅合集补齐了。

**Linux 有了系统媒体控制.** 播放状态通过 MPRIS 暴露给 GNOME / KDE 的媒体控件，锁屏与顶栏可以直接暂停、切集、看当前曲目。

**直播弹幕开关统一到控制器.** 直播页的弹幕开关逻辑抽到 `LiveRoomController.toggleDanmaku()`，临时播放配置下不落盘，为后续通知栏/画中画按钮复用做准备。
