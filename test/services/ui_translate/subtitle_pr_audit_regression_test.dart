import 'dart:io';

import 'package:PiliPlus/models_new/video/video_play_info/subtitle.dart';
import 'package:PiliPlus/services/ui_translate/subtitle_translation_artifact.dart';
import 'package:PiliPlus/services/ui_translate/subtitle_selection.dart';
import 'package:PiliPlus/services/ui_translate/subtitle_source_resolver.dart';
import 'package:PiliPlus/services/ui_translate/subtitle_task_state.dart';
import 'package:PiliPlus/services/ui_translate/subtitle_translation_job.dart';
import 'package:PiliPlus/services/ui_translate/subtitle_video_key.dart';
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

  group('3.7.3 统一视频身份键', () {
    test('按 bvid → aid → epId → seasonId 降级，没有编号时返回空串', () {
      expect(
        subtitleVideoKeyFor(bvid: 'BV1xx', aid: 1, epId: 2, seasonId: 3),
        'BV1xx',
      );
      expect(subtitleVideoKeyFor(aid: 123), 'av123');
      expect(subtitleVideoKeyFor(epId: 456, seasonId: 789), 'ep456');
      expect(subtitleVideoKeyFor(seasonId: 789), 'ss789');
      expect(subtitleVideoKeyFor(seasonId: '789'), 'ss789');
      expect(subtitleVideoKeyFor(), isEmpty);
      expect(subtitleVideoKeyFor(bvid: '  ', aid: 0, epId: 0), isEmpty);
    });

    test('番剧封面按钮、播放页自动预翻译、重翻共用同一个键', () {
      const epId = 654321;
      // 竖版推荐卡片：goto == 'bangumi' 时 param 就是 ep_id。
      final card = subtitleVideoKeyFor(
        bvid: null,
        aid: null,
        epId: epId,
      );
      // 播放页：bvid 为空串、aid 为 0，只剩 epId/seasonId。
      final player = subtitleVideoKeyFor(
        bvid: '',
        aid: 0,
        epId: epId,
        seasonId: 9988,
      );
      expect(card, player);
      expect(card, 'ep654321');
      // 以前播放页一律用 bvid（''），两边永远对不上。
      expect(player, isNot(''));
    });

    test('普通视频的键仍然是 bvid，不影响既有缓存', () {
      expect(
        subtitleVideoKeyFor(
          bvid: 'BV1xx411c7mD',
          aid: 170001,
          seasonId: 1,
        ),
        'BV1xx411c7mD',
      );
    });

    test('后台写缓存/产物必须复用调用方传进来的统一键', () {
      // 番剧：播放页传 ep<epId>，bvid/aid 都是空。以前后台硬写
      // `bvid ?? 'av$aid'` 会得到 `avnull`，产物挂到播放页查不到的键下。
      expect(
        subtitleCacheVideoKeyFor(videoKey: 'ep654321', epId: 654321),
        'ep654321',
      );
      // 普通视频：键仍是 bvid，旧缓存/旧产物继续命中。
      expect(
        subtitleCacheVideoKeyFor(
          videoKey: 'BV1xx411c7mD',
          bvid: 'BV1xx411c7mD',
          aid: 170001,
        ),
        'BV1xx411c7mD',
      );
      // 调用方没给键时才回退推导，且不会拼出 `avnull`。
      expect(
        subtitleCacheVideoKeyFor(videoKey: '', epId: 654321),
        'ep654321',
      );
      expect(
        subtitleCacheVideoKeyFor(videoKey: '', aid: 170001),
        'av170001',
      );
      expect(subtitleCacheVideoKeyFor(videoKey: ''), isEmpty);
    });

    test('身份解析出 bvid 后必须升级到播放页的规范键', () {
      // 竖版番剧卡片启动时只有 epId；pgc 详情解析出 bvid 后，
      // 播放页/产物/缓存必须统一到 bvid，否则同一集会翻两遍。
      expect(
        subtitleResolvedVideoKeyFor(
          callerVideoKey: 'ep654321',
          bvid: 'BV1pgc',
          epId: 654321,
          seasonId: 9988,
        ),
        'BV1pgc',
      );
      // 只有 seasonId 的卡片解析到 epId 时，用 ep 键与播放页对齐。
      expect(
        subtitleResolvedVideoKeyFor(
          callerVideoKey: 'ss9988',
          epId: 654321,
          seasonId: 9988,
        ),
        'ep654321',
      );
      // 解析不出任何编号时不丢掉调用方键，供错误提示/调试定位。
      expect(
        subtitleResolvedVideoKeyFor(callerVideoKey: 'fallback-key'),
        'fallback-key',
      );
    });

    test('旧主标签译文轨从 lanDoc 恢复完整目标代码', () {
      // 繁中目标生成的旧文件：zh-app-ai + lanDoc 自称「繁體中文」→ 恢复成
      // 规范代码 zh-TW（AppLanguage 清单里的正式条目），精确匹配、不再被
      // 中文家族规则误杀，也不挂给简体目标。
      expect(
        legacyAppAiLanFor('zh-app-ai', '繁體中文 (AI)'),
        'zh-TW-app-ai',
      );
      expect(
        legacyAppAiLanFor('zh-app-ai', '简体中文 (AI)'),
        'zh-CN-app-ai',
      );
      // 越南语旧文件恢复后不变（本来就只有主标签）。
      expect(
        legacyAppAiLanFor('vi-app-ai', 'Tiếng Việt (AI)'),
        'vi-app-ai',
      );
      // lanDoc 缺失/对不上 → 原样返回，宁可重翻不挂错字形。
      expect(legacyAppAiLanFor('zh-app-ai', null), 'zh-app-ai');
      expect(
        legacyAppAiLanFor('zh-app-ai', 'Tiếng Việt (AI)'),
        'zh-app-ai',
      );
      // 已是完整代码 / 非译文轨：不动。
      expect(
        legacyAppAiLanFor('zh-Hant-app-ai', '繁體中文 (AI)'),
        'zh-Hant-app-ai',
      );
      expect(legacyAppAiLanFor('ai-zh', '中文'), 'ai-zh');
    });
  });

  group('3.7.3 轨道模型边界', () {
    test('AI 前缀大小写容错，译文轨能被单独识别', () {
      expect(_track('AI-ZH').langTag, 'zh');
      expect(_track('zh-app-ai').isAppAiTrack, isTrue);
      expect(_track('ZH-App-Ai').isAppAiTrack, isTrue);
      expect(_track('zh-CN').isAppAiTrack, isFalse);
    });

    test('中文源轨覆盖中文家族，但不包含自己生成的译文轨', () {
      for (final lan in [
        'zh-CN',
        'zh-Hant',
        'ai-zh',
        'yue-Hans',
        'wuu',
        'nan-TW',
        'cmn',
      ]) {
        expect(_track(lan).isChineseSourceTrack, isTrue, reason: lan);
      }
      for (final lan in ['zh-app-ai', 'vi', 'en-US', 'ja']) {
        expect(_track(lan).isChineseSourceTrack, isFalse, reason: lan);
      }
    });

    test('构造函数也能设置 v2 地址', () {
      final sub = Subtitle(lan: 'zh-CN', subtitleUrlV2: '//x/b.json');
      expect(sub.subtitleUrlCandidates, ['//x/b.json']);
    });
  });

  group('3.7.3 下载与时间轴', () {
    test('整条轨都不可用时 json2Vtt / json2Srt 返回空串', () {
      final bad = [
        {'from': 0, 'to': 0, 'content': '零长度'},
        {'from': 5, 'to': 4, 'content': '倒序'},
        {'from': -1, 'to': 2, 'content': '负数'},
        {'from': 1, 'to': 2, 'content': '   '},
      ];
      expect(SubtitleUtils.json2Vtt(bad), isEmpty);
      expect(SubtitleUtils.json2Srt(bad), isEmpty);
    });

    test('json2Vtt 与后台 fromBody 用同一套重叠清洗规则', () {
      final body = [
        for (var i = 0; i < 5; i++) {'from': 1.0, 'to': 3.0, 'content': '叠$i'},
        {'from': 10.0, 'to': 11.0, 'content': '正常'},
      ];
      final fromJob = SubtitleCues.fromBody(body);
      final fromVtt = SubtitleCues.fromVtt(SubtitleUtils.json2Vtt(body));
      expect(fromVtt.length, fromJob.length);
      for (var i = 0; i < fromVtt.length; i++) {
        expect(fromVtt[i].start, fromJob[i].start);
        expect(fromVtt[i].end, fromJob[i].end);
        expect(fromVtt[i].text, fromJob[i].text);
      }
      expect(SubtitleCues.hasSafePlaybackTimeline(fromVtt), isTrue);
    });

    test('json2Srt 时间戳用逗号且序号连续', () {
      final srt = SubtitleUtils.json2Srt([
        {'from': 1.5, 'to': 2.5, 'content': '一'},
        {'from': 3, 'to': 4, 'content': '二'},
      ]);
      expect(srt, contains('00:00:01,500 --> 00:00:02,500'));
      expect(srt, contains('2\n00:00:03,000'));
    });
  });

  group('3.7.3 选源一致性', () {
    test('选轨策略把中文家族轨当中文源，但不把译文轨当源', () {
      final choice = SubtitleSelectionPolicy.choose(
        [_track('yue-Hans')],
        'vi',
        canTranslate: true,
      );
      expect(choice.translate, isTrue);
      expect(choice.index, 1);
      expect(_track('zh-app-ai').isChineseSourceTrack, isFalse);
    });

    test('后台源解析也接受中文家族轨', () async {
      final resolved = await SubtitleSourceResolver.resolve(
        tracks: [_track('yue-Hans')],
        targetLanguage: 'vi',
        loadCues: (_) async => _sequential(2),
      );
      expect(resolved?.kind, SubtitleSourceKind.chineseTranslation);
    });

    test('主语言归一在轨道模型与解析器上一致', () {
      expect(Subtitle.primaryLanguageTag('zh-Hant'), 'zh');
      expect(Subtitle.primaryLanguageTag('AI-ZH'), 'zh');
      expect(SubtitleSourceResolver.primaryLanguageTag('zh-Hant'), 'zh');
      expect(SubtitleSourceResolver.primaryLanguageTag('yue-Hans'), 'yue');
    });
  });

  group('3.7.3 翻译校验与落盘', () {
    test('日语/韩语目标不会因为合法汉字词与原文相同被整块拒收', () {
      final source = ['東京', '学校', '先生', '学生'];
      for (final target in ['ja', 'ja-JP', 'ko', 'ko-KR']) {
        expect(
          () => SubtitleTranslationOutput.sanitizeAndValidate(
            source,
            List<String>.of(source),
            targetLanguage: target,
          ),
          returnsNormally,
          reason: target,
        );
      }
      final cues = _sequential(4);
      final vtt = SubtitleCues.toVtt(
        cues,
        [for (final cue in cues) cue.text],
      );
      expect(
        SubtitleTranslationOutput.isCompleteTranslatedVtt(
          cues,
          vtt,
          targetLanguage: 'ja',
        ),
        isTrue,
      );
    });

    test('不使用汉字的目标仍然拒绝整块照抄', () {
      final source = ['你好', '世界', '谢谢', '再见'];
      expect(
        () => SubtitleTranslationOutput.sanitizeAndValidate(
          source,
          List<String>.of(source),
          targetLanguage: 'en',
        ),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => SubtitleTranslationOutput.sanitizeAndValidate(
          source,
          List<String>.of(source),
          targetLanguage: 'vi',
        ),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('3.7.3 下载译文轨字形', () {
    test('新格式必须精确匹配目标语言', () {
      expect(cachedTranslationLanMatches('zh-Hant-app-ai', 'zh-Hant'), isTrue);
      expect(
        cachedTranslationLanMatches('yue-Hans-app-ai', 'yue-Hans'),
        isTrue,
      );
      expect(cachedTranslationLanMatches('zh-Hant-app-ai', 'zh-CN'), isFalse);
      expect(cachedTranslationLanMatches('zh-CN-app-ai', 'zh-Hant'), isFalse);
      expect(cachedTranslationLanMatches('vi-app-ai', 'vi'), isTrue);
    });

    test('旧格式不带字形，中文家族目标不挂载', () {
      expect(cachedTranslationLanMatches('zh-app-ai', 'zh-CN'), isFalse);
      expect(cachedTranslationLanMatches('zh-app-ai', 'zh-Hant'), isFalse);
      expect(cachedTranslationLanMatches('yue-app-ai', 'yue-Hans'), isFalse);
    });

    test('旧格式非中文目标仍兼容，且不会串到别的语言', () {
      expect(cachedTranslationLanMatches('vi-app-ai', 'vi-VN'), isTrue);
      expect(cachedTranslationLanMatches('en-app-ai', 'en'), isTrue);
      expect(cachedTranslationLanMatches('vi-app-ai', 'ja'), isFalse);
    });

    test('下划线与大小写归一', () {
      expect(cachedTranslationLanMatches('ZH_HANT-app-ai', 'zh-Hant'), isTrue);
    });
  });

  group('3.7.3 乱序时间轴', () {
    test('乱序 VTT 先稳定排序，合法 cue 一条不少', () {
      const vtt =
          'WEBVTT\n\n'
          '00:00:10.000 --> 00:00:11.000\n尾句\n\n'
          '00:00:00.000 --> 00:00:01.000\n首句\n\n'
          '00:00:01.000 --> 00:00:02.000\n次句\n\n';
      final cues = SubtitleCues.fromVtt(vtt);
      expect(cues.length, 3);
      expect(cues.map((cue) => cue.text), ['首句', '次句', '尾句']);
      expect(SubtitleCues.hasSafePlaybackTimeline(cues), isTrue);
    });

    test('乱序 B 站 body 不会被前面那条长 cue 挡掉', () {
      final body = [
        {'from': 20.0, 'to': 21.0, 'content': '尾句'},
        {'from': 0.0, 'to': 1.0, 'content': '首句'},
        {'from': 1.0, 'to': 2.0, 'content': '次句'},
      ];
      expect(
        SubtitleCues.fromBody(body).map((cue) => cue.text),
        ['首句', '次句', '尾句'],
      );
      expect(SubtitleUtils.json2Vtt(body), contains('首句'));
    });

    test('同一时刻保持原顺序，最多保留 3 条重叠', () {
      const vtt =
          'WEBVTT\n\n'
          '00:00:00.000 --> 00:00:01.000\nA\n\n'
          '00:00:00.000 --> 00:00:01.000\nB\n\n'
          '00:00:00.000 --> 00:00:01.000\nC\n\n'
          '00:00:00.000 --> 00:00:01.000\nD\n\n';
      final cues = SubtitleCues.fromVtt(vtt);
      expect(cues.map((cue) => cue.text), ['A', 'B', 'C']);
      expect(SubtitleCues.hasSafePlaybackTimeline(cues), isTrue);
    });
  });

  group('3.7.3 多分P状态聚合', () {
    const idle = SubtitleTranslationTaskState();
    const slow = SubtitleTranslationTaskState(
      phase: SubtitleTranslationTaskPhase.translating,
      progress: 0.2,
    );
    const fast = SubtitleTranslationTaskState(
      phase: SubtitleTranslationTaskPhase.translating,
      progress: 0.9,
    );
    const complete = SubtitleTranslationTaskState(
      phase: SubtitleTranslationTaskPhase.complete,
      progress: 1,
    );
    const failed = SubtitleTranslationTaskState(
      phase: SubtitleTranslationTaskPhase.failed,
    );
    const noSource = SubtitleTranslationTaskState(noSource: true);

    SubtitleTranslationTaskState aggregate(
      List<SubtitleTranslationTaskState> states,
    ) => aggregateCardStates(states);

    test('一个分P完成、另一个还在跑时不能谎报已完成', () {
      final state = aggregate([complete, fast]);
      expect(state.isRunning, isTrue);
      expect(state.phase, SubtitleTranslationTaskPhase.translating);
    });

    test('多个分P在跑时显示进度最低的那个', () {
      expect(aggregate([fast, slow]).progress, 0.2);
    });

    test('任一失败就给可重试的失败态', () {
      expect(
        aggregate([complete, failed, complete]).phase,
        SubtitleTranslationTaskPhase.failed,
      );
    });

    test('全部完成 / 无需翻译才显示完成', () {
      expect(
        aggregate([complete, complete]).phase,
        SubtitleTranslationTaskPhase.complete,
      );
      expect(
        aggregate([complete, noSource]).phase,
        SubtitleTranslationTaskPhase.complete,
      );
      // 有分P还没开始时不能谎报完成：显示准备中 + 已完成比例。
      final partial = aggregate([complete, idle]);
      expect(partial.phase, SubtitleTranslationTaskPhase.preparing);
      expect(partial.progress, 0.5);
      expect(aggregate([idle, idle]).phase, SubtitleTranslationTaskPhase.idle);
    });

    test('空列表返回 idle', () {
      expect(aggregate([]).phase, SubtitleTranslationTaskPhase.idle);
    });
  });

  group('3.7.3 批量产物键兼容', () {
    SubtitleTranslationArtifact artifact(String videoKey) =>
        SubtitleTranslationArtifact(
          key: SubtitleTranslationArtifact.makeKey(
            videoKey: videoKey,
            cid: 123,
            targetLanguage: 'vi',
            sourceLan: 'zh-CN',
            sourceIdentity: 'src',
          ),
          videoKey: videoKey,
          cid: 123,
          targetLanguage: 'vi',
          sourceLan: 'zh-CN',
          sourceIdentity: 'src',
          cueCount: 1,
          verifierVersion: 2,
          cacheFilePath: 'cache.json',
          vttFilePath: 'track.vtt',
          completedAt: DateTime(2026, 1, 1),
        );

    test('旧版批量 videoKey 归一到统一身份键', () {
      expect(artifact('BV1xx/123').stateVideoKey, 'BV1xx');
      expect(artifact('BV1xx').stateVideoKey, 'BV1xx');
    });

    test('产物注册表能按新键查到旧版批量产物', () async {
      final dir = await Directory.systemTemp.createTemp('pb_artifact_');
      addTearDown(() {
        if (dir.existsSync()) dir.deleteSync(recursive: true);
      });
      final registry = SubtitleTranslationArtifactRegistry(
        directoryPath: dir.path,
      );
      final registered = await registry.registerVerified(
        artifact('BV1xx/123'),
        verify: () => true,
      );
      expect(registered, isTrue);
      final found = await registry.find(
        videoKey: 'BV1xx',
        cid: 123,
        targetLanguage: 'vi',
        sourceLan: 'zh-CN',
        sourceIdentity: 'src',
      );
      expect(found, isNotNull);
      final forPart = await registry.findForPart(
        videoKey: 'BV1xx',
        cid: 123,
        targetLanguage: 'vi',
      );
      expect(forPart, isNotNull);
    });
  });

  group('3.7.6 批量父状态键不得与分P键相同', () {
    // 以前父任务直接用「选中那一P」的任务键，于是：
    //   1) stateFor 把父任务当成那个分P「仍在运行」→ 批量的 running 计数
    //      永远降不到 0 → 卡片一直转圈、永远不完成；
    //   2) _startSingle 看到自己那条「准备中」直接早退 → 那一P永远不启动。
    test('父键与被选中分P的键不相等', () {
      final child = subtitleTaskStateKey('BV1xx', 'ja', 111);
      final batch = subtitleBatchStateKey('BV1xx', 'ja', 111);
      expect(batch, isNot(child));
      expect(child, isNot(startsWith('#')));
    });

    test('父键与卡片键、以及合集里其它分P的键都不相等', () {
      final batch = subtitleBatchStateKey('BV1xx', 'ja', 111);
      expect(batch, isNot(subtitleTaskStateKey('BV1xx', 'ja')));
      for (final cid in [111, 222, 333]) {
        expect(batch, isNot(subtitleTaskStateKey('BV1xx', 'ja', cid)));
      }
      for (final key in ['BV1yy', 'BV1zz']) {
        expect(batch, isNot(subtitleTaskStateKey(key, 'ja', 111)));
      }
    });

    test('父键仍以分P键为前缀，便于按前缀定位', () {
      final child = subtitleTaskStateKey('BV1xx', 'ja', 111);
      final batch = subtitleBatchStateKey('BV1xx', 'ja', 111);
      expect(batch, startsWith(child));
      expect(batch, endsWith('#batch'));
    });
  });
}
