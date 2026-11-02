### PiliBabel v3.5.6

**Search: trending keywords are translated and laid out on two lines. Listen-only page: the media session state is fixed. Subtitles: the track matching the app language is picked automatically.**

- **Trending entries, two lines** - each trending keyword may wrap to two lines and its badge
  moves to a second row. A translation is usually much longer than the Chinese original, and
  keeping the badge inline squeezed the keyword into an ellipsis. The layout follows the
  **标题完全显示** switch (renamed from 视频标题完全显示 in this release); turn it off and the
  single-line layout comes back.
- **Listen-only page media session** - that page drives its own media_kit player and has no
  `PlPlayerController`, while the handler only reported state when one existed. As a result the
  page never reported anything: the play/pause icon and progress in the notification and the
  system media panel stayed at their initial values. The gate now also accepts the page's own
  playing-state callback.
- **Subtitles follow the app language** - with the default subtitle preference, a track matching
  the app language is selected when one exists (Japanese UI plus a Japanese subtitle track shows
  it directly, no translation pass). Without such a track the previous behaviour stands: open the
  Chinese track and translate it in the background.
- The full ranking page (bilibili 热搜) follows the same line-count switch.

中文摘要：本版把热搜条目改成上下两行（关键词最多两行、小标签另起一行），跟随设置里的
「标题完全显示」（原「视频标题完全显示」，本版改名）；「完整榜单」页同步。修好听视频页
从不向系统上报媒体会话状态的问题（该页没有 `PlPlayerController`，被「有播放器才上报」
的门槛挡掉），通知栏与系统媒体面板的播放/暂停图标和进度现在是对的。字幕方面：字幕偏好
保持默认时优先选与界面语言一致的那条轨，没有才退回「开中文轨并翻译」。
