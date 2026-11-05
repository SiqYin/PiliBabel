/// Shared subtitle text checks used by translation, cache restoration and
/// artifact promotion. Checking Unicode code points avoids missing Han
/// extensions outside Dart's BMP-oriented regular-expression ranges.
abstract final class SubtitleTextQuality {
  static const int verifierVersion = 1;

  static bool containsHan(String value) => value.runes.any(isHanRune);

  static bool isHanRune(int rune) =>
      rune == 0x3007 ||
      (rune >= 0x3400 && rune <= 0x4DBF) ||
      (rune >= 0x4E00 && rune <= 0x9FFF) ||
      (rune >= 0xF900 && rune <= 0xFAFF) ||
      (rune >= 0x20000 && rune <= 0x2A6DF) ||
      (rune >= 0x2A700 && rune <= 0x2B73F) ||
      (rune >= 0x2B740 && rune <= 0x2B81F) ||
      (rune >= 0x2B820 && rune <= 0x2CEAF) ||
      (rune >= 0x2CEB0 && rune <= 0x2EBEF) ||
      (rune >= 0x2EBF0 && rune <= 0x2EE5F) ||
      (rune >= 0x2F800 && rune <= 0x2FA1F) ||
      (rune >= 0x30000 && rune <= 0x3134F) ||
      (rune >= 0x31350 && rune <= 0x323AF);
}
