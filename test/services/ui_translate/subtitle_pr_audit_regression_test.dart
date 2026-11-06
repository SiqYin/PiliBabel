import 'package:PiliPlus/models_new/video/video_play_info/subtitle.dart';
import 'package:PiliPlus/services/ui_translate/subtitle_selection.dart';
import 'package:PiliPlus/services/ui_translate/subtitle_source_resolver.dart';
import 'package:PiliPlus/services/ui_translate/subtitle_translation_job.dart';
import 'package:PiliPlus/utils/subtitle_utils.dart';
import 'package:flutter_test/flutter_test.dart';

Subtitle _track(String lan, {bool ai = false}) =>
    Subtitle(lan: lan, lanDoc: lan, isAi: ai);

List<SubtitleCue> _sequential(int count) => List.generate(
  count,
  (index) => SubtitleCue(
    '00:00:${index.toString().padLeft(2, '0')}.000',
    '00:00:${(index + 1).toString().padLeft(2, '0')}.000',
    '句$index',
  ),
);

void main() {
  group('PR #2 合并后遗留：目标语言/轨道判定', () {
    test('裸中文轨不能冒充繁體中文的现成译文', () {
      expect(_track('zh-CN').isNativeTarget('zh-Hant'), isFalse);
      expect(_track('ai-zh', ai: true).isNativeTarget('zh-Hant'), isFalse);
      expect(_track('zh').isNativeTarget('zh-Hant'), isFalse);
      expect(_track('zh-Hant').isNativeTarget('zh-Hant'), isTrue);
      // 简体目标下裸 zh 就是现成字幕，不该强行翻译。
      expect(_track('zh').isNativeTarget('zh-CN'), isTrue);
      expect(_track('vi').isNativeTarget('vi-VN'), isTrue);
      expect(_track('en').isNativeTarget('vi-VN'), isFalse);
    });

    test('自己生成的 -app-ai 译文轨必须优先当现成译文', () {
      // 下载缓存按主标签保存 `zh-app-ai`；繁中目标下不能因为「没写字形」
      // 又把它当中文源重新翻一遍。
      expect(_track('zh-app-ai').isNativeTarget('zh-TW'), isTrue);
      expect(_track('yue-app-ai').isNativeTarget('yue-Hant'), isTrue);
      expect(_track('vi-app-ai').isNativeTarget('zh-TW'), isFalse);
      final selection = SubtitleSelectionPolicy.choose(
        [_track('zh-CN'), _track('zh-app-ai')],
        'zh-TW',
        canTranslate: true,
      );
      expect(selection.translate, isFalse);
      expect(selection.index, 2);
    });

    test('粤语/吴语/闽南语同样要区分简繁字形', () {
      expect(_track('yue-Hans').isNativeTarget('yue-Hant'), isFalse);
      expect(_track('wuu').isNativeTarget('wuu-Hant'), isFalse);
      expect(_track('nan-CN').isNativeTarget('nan-TW'), isFalse);
      expect(_track('yue-Hant').isNativeTarget('yue-Hant'), isTrue);
      // 非中文语言里的地区子标签不能被误读成简繁字形。
      expect(_track('vi-VN').isNativeTarget('vi-VN'), isTrue);
    });

    test('后台源解析对繁體中文目标应返回中文源而不是 nativeTarget', () async {
      final resolved = await SubtitleSourceResolver.resolve(
        tracks: [_track('ai-zh', ai: true), _track('zh-CN')],
        targetLanguage: 'zh-Hant',
        loadCues: (_) async => _sequential(3),
      );
      expect(resolved, isNotNull);
      expect(resolved!.kind, SubtitleSourceKind.chineseTranslation);
      expect(resolved.cues, hasLength(3));
    });

    test('目标语言轨下载失败时不能谎报「已有译文」', () async {
      final resolved = await SubtitleSourceResolver.resolve(
        tracks: [_track('ai-vi', ai: true), _track('vi'), _track('zh-CN')],
        targetLanguage: 'vi',
        loadCues: (track) async {
          if (track.langTag == 'vi') throw StateError('404');
          return _sequential(3);
        },
      );
      expect(resolved, isNotNull);
      expect(resolved!.kind, SubtitleSourceKind.chineseTranslation);
      expect(resolved.track.langTag, 'zh');
      expect(resolved.cues, hasLength(3));
    });

    test('播放页选轨策略与后台解析结论一致', () {
      final selection = SubtitleSelectionPolicy.choose(
        [_track('ai-zh', ai: true), _track('zh-CN')],
        'zh-Hant',
        canTranslate: true,
      );
      expect(selection.translate, isTrue);
    });

    test('汉字目标语言的译文不能再因含汉字被整块拒收', () {
      for (final target in [
        'zh-CN',
        'zh-TW',
        'zh-Hant',
        'yue-Hans',
        'yue-Hant',
        'wuu-Hans',
        'wuu-Hant',
        'nan-CN',
        'nan-TW',
        'nan_TW',
        'ja',
        'ja-JP',
        'ko',
        'ko-KR',
      ]) {
        expect(
          SubtitleTranslationOutput.targetUsesHan(target),
          isTrue,
          reason: '$target 的译文本来就带汉字',
        );
      }
      for (final target in ['vi', 'vi-VN', 'en', 'fr', 'bo', 'za', 'th']) {
        expect(
          SubtitleTranslationOutput.targetUsesHan(target),
          isFalse,
          reason: '$target 的译文不该带汉字',
        );
      }
      expect(SubtitleTranslationOutput.targetUsesHan(null), isFalse);
    });

    test('中文家族判定以语言清单为准，不再靠手写前缀', () {
      for (final target in [
        'zh-CN',
        'zh-Hant',
        'yue-Hant',
        'wuu-Hans',
        'wuu-Hant',
        'nan-TW',
      ]) {
        expect(
          SubtitleTranslationOutput.isChineseFamilyTarget(target),
          isTrue,
          reason: '$target 属于中文家族',
        );
      }
      for (final target in ['vi-VN', 'ja', 'ko', 'en-US']) {
        expect(
          SubtitleTranslationOutput.isChineseFamilyTarget(target),
          isFalse,
          reason: '$target 不属于中文家族',
        );
      }
    });

    test('中文家族目标的整块照抄判定必须豁免', () {
      final source = ['你好', '再见', '谢谢'];
      expect(
        SubtitleTranslationOutput.isCompleteTranslatedVtt(
          [
            SubtitleCue('00:00:00.000', '00:00:01.000', source[0]),
            SubtitleCue('00:00:01.000', '00:00:02.000', source[1]),
            SubtitleCue('00:00:02.000', '00:00:03.000', source[2]),
          ],
          'WEBVTT\n\n'
              '00:00:00.000 --> 00:00:01.000\n${source[0]}\n\n'
              '00:00:01.000 --> 00:00:02.000\n${source[1]}\n\n'
              '00:00:02.000 --> 00:00:03.000\n${source[2]}\n\n',
          targetLanguage: 'zh-Hant',
        ),
        isTrue,
      );
    });
  });

  group('PR #2 合并后遗留：坏 cue 与 V2 地址', () {
    test('fromBody 丢掉零长度/倒序/负数 cue', () {
      final cues = SubtitleCues.fromBody([
        {'from': 0, 'to': 1, 'content': '好'},
        {'from': 2, 'to': 2, 'content': '零长度'},
        {'from': 5, 'to': 4, 'content': '倒序'},
        {'from': -1, 'to': 1, 'content': '负数'},
        {'from': 6, 'to': 7, 'content': '  '},
        {'from': 8, 'to': 9, 'content': '尾句'},
      ]);
      expect(cues.map((e) => e.text), ['好', '尾句']);
      expect(SubtitleCues.hasSafePlaybackTimeline(cues), isTrue);
    });

    test('fromVtt 同样清洗坏 cue，并支持 mm:ss 时间戳', () {
      final cues = SubtitleCues.fromVtt(
        'WEBVTT\n\n'
        '00:01.000 --> 00:02.000\n短格式\n\n'
        '00:00:02.000 --> 00:00:02.000\n零长度\n\n'
        '00:00:05.000 --> 00:00:03.000\n倒序\n\n'
        '00:00:06.000 --> 00:00:07.000\n正常\n\n',
      );
      expect(cues.map((e) => e.text), ['短格式', '正常']);
      expect(SubtitleCues.hasSafePlaybackTimeline(cues), isTrue);
    });

    test('超过 3 条重叠的 cue 被裁掉，而不是整条轨判死', () {
      final cues = SubtitleCues.fromVtt(
        'WEBVTT\n\n'
        '${List.generate(5, (i) => '00:00:00.000 --> 00:00:10.000\n叠$i').join('\n\n')}\n\n'
        '00:00:10.000 --> 00:00:11.000\n后句\n\n',
      );
      expect(cues.length, 4); // 前 3 条 + 后句
      expect(SubtitleCues.hasSafePlaybackTimeline(cues), isTrue);
    });

    test('json2Vtt 不把坏 cue 写进播放轨', () {
      final vtt = SubtitleUtils.json2Vtt([
        {'from': 0, 'to': 1, 'content': '好'},
        {'from': 2, 'to': 2, 'content': '零长度'},
        {'from': 5, 'to': 4, 'content': '倒序'},
      ]);
      expect(vtt, contains('好'));
      expect(vtt, isNot(contains('零长度')));
      expect(vtt, isNot(contains('倒序')));
      expect(SubtitleCues.fromVtt(vtt), hasLength(1));
    });

    test('主地址与 v2 地址都可用，且缺字段不会炸', () {
      final sub = Subtitle.fromJson({
        'subtitle_url': '//hdslb.com/a.json',
        'subtitle_url_v2': 'https://hdslb.com/b.json',
      });
      expect(sub.lan, isEmpty);
      expect(sub.lanDoc, isNull);
      expect(sub.subtitleUrlCandidates, [
        '//hdslb.com/a.json',
        'https://hdslb.com/b.json',
      ]);
      final onlyV2 = Subtitle.fromJson({
        'lan': 'zh-CN',
        'subtitle_url_v2': 'https://hdslb.com/b.json',
      });
      expect(onlyV2.subtitleUrlCandidates, ['https://hdslb.com/b.json']);
      expect(onlyV2.isNativeTarget('zh-CN'), isTrue);
    });
  });
}
