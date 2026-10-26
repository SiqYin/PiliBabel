# 上游同步记录 · Upstream sync log

本文件记录 PiliBabel 每次与上游 Starfallan/PiliNara 同步的基准点，下次同步时从这里查起点。
This file records the PiliNara commit each sync of PiliBabel was based on.

| 同步日期 | 上游分支 | 上游基准提交 | 上游提交时间 | 本仓库版本 | 同步方式 |
| --- | --- | --- | --- | --- | --- |
| 2026-10-26 | main | `b5694ccdaf6064b3bf582bfe7991936d508740b8` | 2026-10-24 20:21 | v3.3.4 | 逐项挑选并入（未做整包 merge） |

## 同步方式（固定策略）

只做挑选式并入：从上游最新版里挑出能合的内容，单独摘进本仓库；本仓库是独立项目，
不做整包 merge，也不出专门的同步版。上游的整包重构与本仓库已有功能冲突时，以本仓库为准。
## 当前基准（v3.3.4）

- 上游仓库：Starfallan/PiliNara（本仓库远端名 `upstream`）
- 基准提交：`b5694ccdaf6064b3bf582bfe7991936d508740b8` — `fix(setting): 关键词过滤改为列表项逐项编译`（2026-10-24）
- 本次并入的上游内容：状态栏开屏变暗、下载任务在进程被杀后继续、media-kit 及配套包升级、Wayland 黑屏绕行、缓存视频可选音质（含音质档位、半屏画质规则 `findClosestTarget`、智能修复 100 档）。
- 本次未并入、留待下次：上游把下载模块重构为 `download/`、`folder_sort/`、`page/`、`utils/card_menu.dart` 的新结构；统一评论过滤页；会员主页重构；opus 合集；导出设置重构；直播缓冲设置独立等。

## 下次同步怎么查

```bash
git fetch upstream
git log --oneline b5694ccdaf6064b3bf582bfe7991936d508740b8..upstream/main   # 上游自上次基准以来的新提交
```
