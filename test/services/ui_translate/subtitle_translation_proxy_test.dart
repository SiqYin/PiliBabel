import 'dart:async';

import 'package:PiliPlus/services/ui_translate/subtitle_translation_proxy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses compact SOCKS5 credentials with a selected default type', () {
    final proxies = SubtitleTranslationProxy.parseMany(
      '103.82.192.94:15406:w1t8:w1t8',
      defaultType: SubtitleTranslationProxyType.socks5,
    );

    expect(proxies, hasLength(1));
    expect(proxies.single.type, SubtitleTranslationProxyType.socks5);
    expect(proxies.single.host, '103.82.192.94');
    expect(proxies.single.port, 15406);
    expect(proxies.single.username, 'w1t8');
    expect(proxies.single.password, 'w1t8');
  });

  test('an explicit HTTP prefix overrides the selected SOCKS5 type', () {
    final proxy = SubtitleTranslationProxy.parse(
      'http://103.82.192.94:15406:w1t8:w1t8',
      defaultType: SubtitleTranslationProxyType.socks5,
    );

    expect(proxy.type, SubtitleTranslationProxyType.http);
  });

  test(
    'probes each proxy once before opening six simultaneous slots',
    () async {
      final pool = SubtitleTranslationProxyPool(
        SubtitleTranslationProxy.parseMany('1.1.1.1:80\n2.2.2.2:80'),
        directWorkers: 5,
      );
      final probes = <String>[];

      await Future.wait([
        pool.run((proxy) async => probes.add(proxy?.host ?? 'direct')),
        pool.run((proxy) async => probes.add(proxy?.host ?? 'direct')),
      ]);

      expect(probes, containsAll(['1.1.1.1', '2.2.2.2']));
      expect(pool.workerCount, 17);

      final gates = List.generate(17, (_) => Completer<void>());
      final active = <String, int>{};
      final allStarted = Completer<void>();
      var started = 0;
      final work = [
        for (final gate in gates)
          pool.run((proxy) async {
            final route = proxy?.host ?? 'direct';
            active.update(route, (value) => value + 1, ifAbsent: () => 1);
            if (++started == 17) allStarted.complete();
            await gate.future;
          }),
      ];

      await allStarted.future;
      expect(active, {'direct': 5, '1.1.1.1': 6, '2.2.2.2': 6});
      for (final gate in gates) {
        gate.complete();
      }
      await Future.wait(work);
    },
  );

  test('classifies proxy failures that require route cooldown', () {
    expect(SubtitleTranslationProxyPool.shouldCooldownStatus(null), isTrue);
    expect(SubtitleTranslationProxyPool.shouldCooldownStatus(407), isTrue);
    expect(SubtitleTranslationProxyPool.shouldCooldownStatus(429), isTrue);
    expect(SubtitleTranslationProxyPool.shouldCooldownStatus(503), isTrue);
    expect(SubtitleTranslationProxyPool.shouldCooldownStatus(400), isFalse);
  });

  test(
    'keeps direct workers usable after a proxy becomes unavailable',
    () async {
      final proxy = SubtitleTranslationProxy.parse('1.1.1.1:80');
      final pool = SubtitleTranslationProxyPool([proxy], directWorkers: 1)
        ..markUnavailable(proxy);

      final route = await pool.run((route) async => route);

      expect(route, isNull);
    },
  );

  test('serves playback work before queued background work', () async {
    final pool = SubtitleTranslationProxyPool([], directWorkers: 1);
    final gate = Completer<void>();
    final order = <String>[];

    final active = pool.run((_) async {
      await gate.future;
      order.add('active');
    });
    await Future<void>.delayed(Duration.zero);
    final background = pool.run(
      (_) async => order.add('background'),
      priority: SubtitleTranslationPriority.background,
    );
    final playback = pool.run(
      (_) async => order.add('playback'),
      priority: SubtitleTranslationPriority.playback,
    );

    gate.complete();
    await Future.wait([active, background, playback]);
    expect(order, ['active', 'playback', 'background']);
  });

  test('shared pool caps routes across multiple video jobs', () {
    final first = SubtitleTranslationProxyPool.shared(
      SubtitleTranslationProxy.parseMany('1.1.1.1:80'),
      directWorkers: 2,
    );
    final second = SubtitleTranslationProxyPool.shared(
      SubtitleTranslationProxy.parseMany('1.1.1.1:80'),
      directWorkers: 2,
    );

    expect(identical(first, second), isTrue);
    expect(first.workerCount, 8);
  });

  test(
    'timed out waiter is removed and cannot steal a released route',
    () async {
      final pool = SubtitleTranslationProxyPool(
        const [],
        directWorkers: 1,
        routeAcquireTimeout: const Duration(milliseconds: 20),
      );
      final releaseFirst = Completer<void>();
      final firstStarted = Completer<void>();
      final first = pool.run((_) async {
        firstStarted.complete();
        await releaseFirst.future;
        return 'first';
      });
      await firstStarted.future;

      await expectLater(
        pool.run((_) async => 'abandoned'),
        throwsA(isA<TimeoutException>()),
      );
      expect(pool.waitingCount, 0);

      releaseFirst.complete();
      expect(await first, 'first');
      expect(await pool.run((_) async => 'next'), 'next');
      expect(pool.waitingCount, 0);
    },
  );
}
