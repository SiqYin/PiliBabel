import 'package:PiliPlus/services/ui_translate/translation_queue_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('nextFlushFromUrgent 队列轮转', () {
    test('只有一边非空时取非空那边', () {
      expect(
        nextFlushFromUrgent(
          urgentNotEmpty: false,
          pendingNotEmpty: true,
          lastFlushTookUrgent: false,
        ),
        isFalse,
      );
      expect(
        nextFlushFromUrgent(
          urgentNotEmpty: true,
          pendingNotEmpty: false,
          lastFlushTookUrgent: false,
        ),
        isTrue,
      );
      expect(
        nextFlushFromUrgent(
          urgentNotEmpty: false,
          pendingNotEmpty: false,
          lastFlushTookUrgent: true,
        ),
        isFalse,
      );
    });

    test('两边都非空时交替，任何一侧都不被饿死', () {
      // 上一轮取过优先队列 → 这一轮必须给普通队列
      expect(
        nextFlushFromUrgent(
          urgentNotEmpty: true,
          pendingNotEmpty: true,
          lastFlushTookUrgent: true,
        ),
        isFalse,
      );
      // 上一轮取过普通队列 → 这一轮给优先队列
      expect(
        nextFlushFromUrgent(
          urgentNotEmpty: true,
          pendingNotEmpty: true,
          lastFlushTookUrgent: false,
        ),
        isTrue,
      );
    });

    test('回归：预热大批量不得让下拉刷新的新标题连续挨饿', () {
      // 场景复刻 3.6.7 评估：urgent 积压 200 条预热，pending 是下拉刷新
      // 刚出来的 10 条新标题。旧「排他取空」逻辑下 pending 要等 urgent
      // 全部排空（20+ 轮）才轮到；交替策略下最迟第 2 轮就轮到。
      var urgent = 200;
      var pending = 10;
      var lastTookUrgent = false;
      var round = 0;
      var firstPendingRound = 0;
      while (urgent > 0 || pending > 0) {
        round++;
        final takeUrgent = nextFlushFromUrgent(
          urgentNotEmpty: urgent > 0,
          pendingNotEmpty: pending > 0,
          lastFlushTookUrgent: lastTookUrgent,
        );
        if (takeUrgent) {
          urgent -= 10;
          if (urgent < 0) urgent = 0;
        } else {
          if (firstPendingRound == 0) firstPendingRound = round;
          pending -= 10;
          if (pending < 0) pending = 0;
        }
        lastTookUrgent = takeUrgent;
        if (round > 60) fail('排空轮数失控');
      }
      expect(firstPendingRound, lessThanOrEqualTo(2));
    });
  });
}
