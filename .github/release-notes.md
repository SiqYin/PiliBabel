### PiliBabel v3.4.8

**Diagnostic release: a failed play-url fetch now shows the server's actual reason instead of a bare generic message.**

In v3.4.7 the failure toast contained only "failed to fetch stream, cannot download locally" with no cause at all — because all three fetch paths only matched the `Success` case and **discarded the code / message the server returned**.

This release adds `_fetchErrReason`, which appends `Error.errMsg` to the message, e.g. "failed to fetch stream, cannot download locally: 错误(-404): …". A failure now immediately tells you whether it is a login/session problem, risk control, a video with no audio stream, or a bad URL — no more guessing.

Everything else (bangumi parameter fix, persistent failed records for retry, 绝区零 → ゼンゼロ) is as in v3.4.7.

Downloads are below.