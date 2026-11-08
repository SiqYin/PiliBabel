
import 'package:flutter_test/flutter_test.dart';
import 'package:PiliPlus/services/ui_translate/app_language.dart';

void main() {
  test('Uyghur autonym search survives fold + invisible strip', () {
    // canonical autonym as stored
    final autonym = String.fromCharCode(0x0626) + String.fromCharCode(0x06C7) +
        String.fromCharCode(0x064A) + String.fromCharCode(0x063A) +
        String.fromCharCode(0x06C7) + String.fromCharCode(0x0631) +
        String.fromCharCode(0x0686) + String.fromCharCode(0x06D5);
    // user typed with farsi yeh (06CC) + heh (0647) instead of yeh(064A)/ae(06D5),
    // plus an RLM mark from copy-paste
    final typed = String.fromCharCode(0x200F) +
        String.fromCharCode(0x0626) + String.fromCharCode(0x06C7) +
        String.fromCharCode(0x06CC) + String.fromCharCode(0x063A) +
        String.fromCharCode(0x06C7) + String.fromCharCode(0x0631) +
        String.fromCharCode(0x0686) + String.fromCharCode(0x0647);
    final fq = foldLanguageSearch(typed);
    final fn = foldLanguageSearch(autonym);
    expect(fq, fn);
    expect(fq.isNotEmpty, true);
  });

  test('firstStrongIsRtl detects RTL autonym, ignores neutral prefix', () {
    final autonym = String.fromCharCode(0x0626) + String.fromCharCode(0x06C7);
    expect(firstStrongIsRtl(autonym), true);
    expect(firstStrongIsRtl('  ' + String.fromCharCode(0x0626)), true);
    expect(firstStrongIsRtl('日本語'), false);
    expect(firstStrongIsRtl('  '), false);
  });
}
