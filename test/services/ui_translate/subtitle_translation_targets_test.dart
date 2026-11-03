import 'package:PiliPlus/models_new/video/video_detail/arc.dart';
import 'package:PiliPlus/models_new/video/video_detail/data.dart';
import 'package:PiliPlus/models_new/video/video_detail/episode.dart';
import 'package:PiliPlus/models_new/video/video_detail/page.dart';
import 'package:PiliPlus/models_new/video/video_detail/section.dart';
import 'package:PiliPlus/models_new/video/video_detail/ugc_season.dart';
import 'package:PiliPlus/services/ui_translate/subtitle_translation_targets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'expands every page of a multi-P video and prioritizes selected part',
    () {
      final targets = subtitleTranslationTargetsFromDetail(
        detail: VideoDetailData(
          bvid: 'BV-list',
          aid: 10,
          pages: [Part(cid: 101), Part(cid: 102), Part(cid: 103)],
        ),
        fallbackVideoKey: 'BV-list',
        fallbackBvid: 'BV-list',
        fallbackAid: 10,
        selectedCid: 103,
      );

      expect(targets.map((item) => item.cid), [103, 101, 102]);
      expect(targets.map((item) => item.videoKey).toSet(), {
        'BV-list/101',
        'BV-list/102',
        'BV-list/103',
      });
    },
  );

  test('expands all UGC season episodes and every nested page', () {
    final targets = subtitleTranslationTargetsFromDetail(
      detail: VideoDetailData(
        bvid: 'BV-current',
        aid: 10,
        ugcSeason: UgcSeason(
          sections: [
            SectionItem(
              episodes: [
                EpisodeItem(
                  bvid: 'BV-one',
                  aid: 11,
                  pages: [Part(cid: 111), Part(cid: 112)],
                ),
                EpisodeItem(bvid: 'BV-two', aid: 12, cid: 121),
              ],
            ),
          ],
        ),
      ),
      fallbackVideoKey: 'BV-current',
      fallbackBvid: 'BV-current',
      fallbackAid: 10,
      selectedCid: 121,
    );

    expect(targets.map((item) => item.cid), [121, 111, 112]);
    expect(targets.map((item) => item.bvid), ['BV-two', 'BV-one', 'BV-one']);
  });

  test('uses episode arc aid when a UGC season omits its bvid and aid', () {
    final targets = subtitleTranslationTargetsFromDetail(
      detail: VideoDetailData(
        bvid: 'BV-clicked',
        aid: 10,
        ugcSeason: UgcSeason(
          sections: [
            SectionItem(
              episodes: [
                EpisodeItem(arc: Arc(aid: 99), cid: 991),
              ],
            ),
          ],
        ),
      ),
      fallbackVideoKey: 'BV-clicked',
      fallbackBvid: 'BV-clicked',
      fallbackAid: 10,
      selectedCid: 991,
    );

    expect(targets.single.bvid, isNull);
    expect(targets.single.aid, 99);
    expect(targets.single.videoKey, 'av99/991');
  });

  test('deduplicates repeated cids and includes a missing selected part', () {
    final targets = subtitleTranslationTargetsFromDetail(
      detail: VideoDetailData(
        bvid: 'BV-list',
        aid: 10,
        pages: [Part(cid: 101), Part(cid: 101), Part(cid: 102)],
      ),
      fallbackVideoKey: 'BV-list',
      fallbackBvid: 'BV-list',
      fallbackAid: 10,
      selectedCid: 999,
    );

    expect(targets.map((item) => item.cid), [999, 101, 102]);
  });
}
