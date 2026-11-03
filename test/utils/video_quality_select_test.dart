import 'package:PiliPlus/models/common/video/video_decode_type.dart';
import 'package:PiliPlus/models/common/video/video_quality.dart';
import 'package:PiliPlus/models/video/play/url.dart';
import 'package:PiliPlus/utils/video_utils.dart';
import 'package:flutter_test/flutter_test.dart';

PlayUrlModel _playUrl(
  List<VideoQuality> videoIds, {
  List<VideoQuality>? acceptedQualities,
}) => PlayUrlModel.fromJson({
  'dash': {
    'duration': 0,
    'video': [
      for (final id in videoIds)
        {
          'id': id.code,
          'codecs': VideoDecodeFormatType.AV1.codes.first,
        },
    ],
  },
  'accept_quality': [
    for (final id in acceptedQualities ?? videoIds) id.code,
  ],
  'support_formats': [
    for (final id in videoIds)
      {
        'quality': id.code,
        'codecs': VideoDecodeFormatType.AV1.codes,
      },
  ],
});

void main() {
  test('find target quality', () {
    final playUrl = _playUrl(VideoQuality.values);
    final dash = playUrl.dash!;
    final preferQa = VideoQuality.high1080.code;
    final (
      int targetQuality,
      FormatItem targetFormat,
      VideoDecodeFormatType targetDecode,
      VideoItem targetVideo,
    ) = VideoUtils.findTargetVideo(
      dash.video!,
      preferQa,
      playUrl.acceptQuality,
      playUrl.supportFormats!,
      [.AV1],
    );
    expect(targetQuality, preferQa);
  });

  test('find closest quality', () {
    final playUrl = _playUrl(
      VideoQuality.values.toList()..remove(VideoQuality.high1080plus),
    );
    final dash = playUrl.dash!;
    final preferQa = VideoQuality.high1080plus.code;
    final (
      int targetQuality,
      FormatItem targetFormat,
      VideoDecodeFormatType targetDecode,
      VideoItem targetVideo,
    ) = VideoUtils.findTargetVideo(
      dash.video!,
      preferQa,
      playUrl.acceptQuality,
      playUrl.supportFormats!,
      [.AV1],
    );
    expect(targetQuality, VideoQuality.superResolution.code);
  });

  test('find closest quality', () {
    final playUrl = _playUrl([
      VideoQuality.dolbyVision,
      VideoQuality.high1080,
      VideoQuality.clear480,
    ]);
    final dash = playUrl.dash!;
    final preferQa = VideoQuality.speed240.code;
    final (
      int targetQuality,
      FormatItem targetFormat,
      VideoDecodeFormatType targetDecode,
      VideoItem targetVideo,
    ) = VideoUtils.findTargetVideo(
      dash.video!,
      preferQa,
      playUrl.acceptQuality,
      playUrl.supportFormats!,
      [.AV1],
    );
    expect(targetQuality, VideoQuality.clear480.code);
  });

  test('uses an available DASH stream when accept quality is stale', () {
    final playUrl = _playUrl(
      [VideoQuality.high720],
      acceptedQualities: [VideoQuality.high1080, VideoQuality.high720],
    );
    final dash = playUrl.dash!;
    final (
      int targetQuality,
      FormatItem targetFormat,
      VideoDecodeFormatType targetDecode,
      VideoItem targetVideo,
    ) = VideoUtils.findTargetVideo(
      dash.video!,
      VideoQuality.high1080.code,
      playUrl.acceptQuality,
      playUrl.supportFormats!,
      [.AV1],
    );

    expect(targetQuality, VideoQuality.high720.code);
    expect(targetVideo.quality, VideoQuality.high720);
  });
}
