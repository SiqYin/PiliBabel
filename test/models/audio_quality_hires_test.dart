import 'package:PiliPlus/models/common/video/audio_quality.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AudioQuality.isHiRes', () {
    test('only code 30251 counts as HiRes', () {
      expect(AudioQuality.hiRes.isHiRes, isTrue);
      expect(AudioQuality.hiRes.code, 30251);
      for (final qa in AudioQuality.values) {
        if (qa == AudioQuality.hiRes) continue;
        expect(qa.isHiRes, isFalse, reason: '${qa.desc} 不应被判为 HiRes');
      }
    });
  });

  group('AudioQuality.nextLower', () {
    test('HiRes falls back to the highest track below it', () {
      // 杜比（rank 50）高于 192K（rank 40），所以 HiRes 熄灭应落到杜比。
      expect(AudioQuality.hiRes.nextLower, AudioQuality.dolby_30250);
      expect(AudioQuality.hiRes.nextLower.isHiRes, isFalse);
    });

    test('never returns HiRes or the same value for lower tiers', () {
      for (final qa in AudioQuality.values) {
        final lower = qa.nextLower;
        if (qa.rank <= 0) {
          // 未知音质（rank 0）没有任何更低的档位，只能原地返回。
          continue;
        }
        expect(lower.rank, lessThan(qa.rank));
        expect(lower.isHiRes, isFalse);
      }
    });

    test('already lowest tier returns itself', () {
      final lowest = AudioQuality.values.reduce(
        (a, b) => a.rank <= b.rank ? a : b,
      );
      expect(lowest.nextLower, lowest);
    });
  });

  group('AudioQuality.maybeFromCode', () {
    test('known codes resolve, unknown codes return null instead of throwing', () {
      expect(AudioQuality.maybeFromCode(30251), AudioQuality.hiRes);
      expect(AudioQuality.maybeFromCode(30280), AudioQuality.k192);
      expect(AudioQuality.maybeFromCode(null), isNull);
      // B 站新增音质码时，播放栏构建不能因此崩溃。
      expect(AudioQuality.maybeFromCode(30299), isNull);
      expect(AudioQuality.maybeFromCode(0), isNull);
    });

    test('hasHiResAudioTrack ignores unknown codes', () {
      // 复刻 controller.hasHiResAudioTrack 的判据。
      bool hasHiRes(List<int?> codes) => codes
          .map(AudioQuality.maybeFromCode)
          .any((qa) => qa?.isHiRes == true);
      expect(hasHiRes([30299, 30251]), isTrue);
      expect(hasHiRes([30299, 30280]), isFalse);
      expect(hasHiRes([30299]), isFalse);
    });
  });

  group('HiRes toggle target selection', () {
    // 复刻 controller.toggleHiResAudio 的选轨规则：降档时取「真实存在于本条视频里」
    // 的最高非 HiRes 轨，而不是按 rank 硬推——视频可能根本没有杜比轨。
    AudioQuality? pickFallback(List<int> codes) {
      final tracks = codes.map(AudioQuality.fromCode).where((qa) => !qa.isHiRes);
      return tracks.fold<AudioQuality?>(null, (best, qa) {
        if (best == null || qa.rank > best.rank) return qa;
        return best;
      });
    }

    test('picks the highest available non-HiRes track', () {
      expect(
        pickFallback([30251, 30280, 30232, 30216]),
        AudioQuality.k192,
      );
    });

    test('prefers Dolby when the video actually has a Dolby track', () {
      expect(
        pickFallback([30251, 30250, 30280]),
        AudioQuality.dolby_30250,
      );
    });

    test('returns null when HiRes is the only track', () {
      expect(pickFallback([30251]), isNull);
    });

    test('detects whether a video offers HiRes at all', () {
      bool hasHiRes(List<int> codes) =>
          codes.map(AudioQuality.fromCode).any((qa) => qa.isHiRes);
      expect(hasHiRes([30251, 30280]), isTrue);
      expect(hasHiRes([30280, 30232]), isFalse);
      expect(hasHiRes([]), isFalse);
    });
  });
}
