import 'package:material_ui/material_ui.dart';

/// 封面两个小按钮（翻译 / 识图）共用的进度环。
///
/// 尺寸、描边、留白只在这里定义一次 —— 3.7.5 只把上方按钮的环从 13 放大到 17，
/// 下方识图按钮还是 13，两个按钮挨在一起时一大一小，看起来像两套控件。
///
/// **必须是确定进度**：以前没有精确进度时传 `value: null`，走的是不定态
/// 转圈动画 —— 一旦某个阶段拿不到进度（准备中 / 校验中 / 识图），用户看到的
/// 就是永远转不完的圈，既看不出加载到哪一步，也判断不出有没有结束。
/// 这里在缺进度时给一条缓动估计曲线：仍然顺时针从无到有地填充，
/// 只是停在 [estimateTarget] 之前，等真实进度或完成态接管。
class TranslateProgressRing extends StatefulWidget {
  const TranslateProgressRing({
    super.key,
    this.value,
    this.size = 17,
    this.strokeWidth = 2,
    this.color = Colors.white,
    this.estimateTarget = 0.9,
    this.estimateDuration = const Duration(seconds: 22),
  });

  /// 真实进度（0~1）。为 null 时按 [estimateTarget] 做缓动估计。
  final double? value;

  /// 与上方图标按钮同一套视觉：17 的环 + 2 的描边。
  final double size;
  final double strokeWidth;
  final Color color;

  /// 估计曲线的上限。识图没有服务端进度，可以走到 0.9；字幕的「准备中」
  /// 只是拉列表/解析分P，很快就会切到真实进度，给 0.12 就够，不能让人
  /// 以为已经翻了 90%。
  final double estimateTarget;
  final Duration estimateDuration;

  @override
  State<TranslateProgressRing> createState() => _TranslateProgressRingState();
}

class _TranslateProgressRingState extends State<TranslateProgressRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _estimate = AnimationController(
    vsync: this,
    duration: widget.estimateDuration,
  );

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(covariant TranslateProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) _sync();
  }

  void _sync() {
    if (widget.value == null) {
      if (!_estimate.isAnimating) {
        _estimate.animateTo(
          widget.estimateTarget.clamp(0.0, 1.0),
          duration: widget.estimateDuration,
          curve: Curves.linear,
        );
      }
    } else {
      _estimate.stop();
    }
  }

  @override
  void dispose() {
    _estimate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _estimate,
      builder: (context, _) {
        final raw = widget.value ?? _estimate.value;
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: CircularProgressIndicator(
            // 永远给确定值：null 会退回不定态转圈，正是要修的那个表现。
            value: raw.clamp(0.0, 1.0),
            strokeWidth: widget.strokeWidth,
            strokeCap: StrokeCap.round,
            color: widget.color,
            // 淡淡的底环：能看出「已经走了多少」，不只是看还剩多少。
            backgroundColor: widget.color.withValues(alpha: 0.18),
          ),
        );
      },
    );
  }
}
