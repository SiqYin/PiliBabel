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

  test('provides exactly six simultaneous slots per proxy', () async {
    final pool = SubtitleTranslationProxyPool(
      SubtitleTranslationProxy.parseMany('1.1.1.1:80\n2.2.2.2:80'),
    );
    final gates = List.generate(12, (_) => Completer<void>());
    final active = <String, int>{};
    final allStarted = Completer<void>();
    var started = 0;

    final work = [
      for (final gate in gates)
        pool.run((proxy) async {
          active.update(proxy.host, (value) => value + 1, ifAbsent: () => 1);
          if (++started == 12) allStarted.complete();
          await gate.future;
          active.update(proxy.host, (value) => value - 1);
        }),
    ];

    await allStarted.future;
    expect(active, {'1.1.1.1': 6, '2.2.2.2': 6});
    for (final gate in gates) {
      gate.complete();
    }
    await Future.wait(work);
  });
}
