### PiliBabel v2.4.0

**New icon**

- Android, Windows and Linux now share one icon: a pure white tower (`#ffffff`) on a diagonal gradient that runs from black (`#000000`) at the top-left to blue (`#3a6da2`) at the bottom-right. The shape, the canvas size and the tower's proportions are unchanged. The README logo and the tray icons use the same palette.

**Index Translate outage handling**

- On launch PiliBabel probes the built-in Bilibili Index Translate endpoint. If it is unavailable, an English notice explains the outage and offers `Got it` (change nothing, keep using the app) or `Use my own AI translation`. The second option walks you through 我的 → 设置 → AI 翻译 → 翻译引擎 and switches the engine to your own API configuration; if you have not set one up yet it simply opens that screen for you to fill in.
- If you were switched over by that prompt and the official endpoint later recovers, PiliBabel asks once whether to keep your current configuration or switch back to the Bilibili model, with the same guided animation. This notice is translated by your own AI translation setup.

Downloads are below.
