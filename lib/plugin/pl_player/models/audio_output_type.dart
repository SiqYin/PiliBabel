import 'package:PiliPlus/models/common/enum_with_label.dart';

enum AudioOutput implements EnumWithLabel {
  opensles('OpenSL ES'),
  aaudio('AAudio'),
  audiotrack('AudioTrack'),
  ;

  /// 默认音频后端顺序。
  ///
  /// `--ao` 是**优先级列表**，mpv 取第一个能打开的后端，所以顺序即优先级。
  ///
  /// **AudioTrack 必须排第一 —— 这是向 B 站官方 APP 的音画同步方案靠拢。**
  /// 官方播放器（以及 Android 框架自带的 `MediaSync`）走的是同一条路：以音频为
  /// 主时钟，用「已写入的采样数 − 已播出的采样数」**实时测量**系统音频输出延时，
  /// 再把这个量作为画面延迟、让画面等声音。官方技术复盘里把这个算法叫「音频播放
  /// 采样守恒」，iOS 上靠它把音画差从 150ms 压到 50ms 左右。
  ///
  /// mpv 的三个 Android 后端里，只有 `audiotrack` 做的是同一件事：用
  /// `AudioTrack.getPlaybackHeadPosition()` 取已播出帧数，再叠
  /// `AudioTrack.getTimestamp()`（设备呈现时间戳）／`getLatency()` 兜底，
  /// 报给 mpv 的是**实测**延迟。`opensles` 报的是**估**出来的值 —— 固定 250ms
  /// 软缓冲 + 一个未必拿得到的 `androidGetAudioLatency`（可选接口，取不到按 0
  /// 算）。蓝牙这类外接设备上估不准，音频时钟就会偏，画面被提前呈现，听感上就是
  /// 「耳机里的声音晚半拍」。
  ///
  /// `opensles` 留在最后只作兜底；用户仍可在 设置 → 视频 → 音频输出设备 里自行
  /// 调整选择与顺序。
  static final defaultValue = [
    AudioOutput.audiotrack.name,
    AudioOutput.aaudio.name,
    AudioOutput.opensles.name,
  ].join(',');

  @override
  final String label;
  const AudioOutput(this.label);
}
