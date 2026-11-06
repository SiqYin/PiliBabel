import 'package:PiliPlus/common/widgets/translate_progress_ring.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
        home: Scaffold(body: Center(child: child)),
      );

  CircularProgressIndicator indicator(WidgetTester tester) =>
      tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );

  testWidgets('给定进度时按真实进度顺时针填充', (tester) async {
    await tester.pumpWidget(wrap(const TranslateProgressRing(value: 0.4)));
    expect(indicator(tester).value, 0.4);
  });

  testWidgets('没有进度时也不能退回不定态转圈', (tester) async {
    // 以前这里是 value: null —— 不定态动画会一直转，用户既看不出加载到
    // 哪一步，也判断不出有没有结束（视频里表现为按钮永远在转圈）。
    await tester.pumpWidget(wrap(const TranslateProgressRing()));
    expect(indicator(tester).value, isNotNull);
  });

  testWidgets('没有进度时仍然顺时针从无到有地填充', (tester) async {
    await tester.pumpWidget(wrap(const TranslateProgressRing()));
    final start = indicator(tester).value!;
    await tester.pump(const Duration(seconds: 3));
    final later = indicator(tester).value!;
    expect(later, greaterThan(start));
  });

  testWidgets('估计曲线有上限，不会假装已经翻完', (tester) async {
    await tester.pumpWidget(
      wrap(
        const TranslateProgressRing(
          estimateTarget: 0.9,
          estimateDuration: Duration(seconds: 2),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 6));
    expect(indicator(tester).value!, lessThanOrEqualTo(0.9));
  });

  testWidgets('真实进度接管后不再被估计值干扰', (tester) async {
    await tester.pumpWidget(wrap(const TranslateProgressRing()));
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpWidget(wrap(const TranslateProgressRing(value: 0.25)));
    expect(indicator(tester).value, 0.25);
  });
}
