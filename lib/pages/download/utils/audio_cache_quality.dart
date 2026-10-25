import 'package:PiliPlus/models/common/video/audio_quality.dart';
import 'package:PiliPlus/services/download/audio_cache_service.dart';
import 'package:PiliPlus/services/ui_translate/ui_translate_service.dart';
import 'package:PiliPlus/utils/connectivity_utils.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:material_ui/material_ui.dart';

/// 把「音视频设置」里的默认音质 code 映射到缓存可选档位
/// （Hi-Res / 杜比 / 192K / 132K / 64K）。注意档位高低与 code 数值并不一致
/// （192K=30280 > 杜比=30250），所以按档位序降档而不是按数值比大小。
AudioQuality _recommendedCacheQuality(int code) => switch (code) {
  30251 => AudioQuality.hiRes,
  30250 || 30255 => AudioQuality.dolby_30250,
  30280 => AudioQuality.k192,
  30232 => AudioQuality.k132,
  _ => AudioQuality.k192,
};

/// 选音频缓存的音质档位：从 Hi-Res 无损到 64K，由高到低。
/// 返回 null 表示用户取消。
///
/// 档位含义对新用户并不直观：把「按用户在 音视频设置 里的默认音质 + 当前是
/// WiFi 还是蜂窝」推断出的档位**标蓝提示**（不代选，仍由用户自己点）。
Future<AudioQuality?> showAudioCacheQualityPicker(BuildContext context) async {
  final isWiFi = await ConnectivityUtils.isWiFi;
  final recommended = _recommendedCacheQuality(
    isWiFi ? Pref.defaultAudioQa : Pref.defaultAudioQaCellular,
  );
  if (!context.mounted) {
    return null;
  }
  return showModalBottomSheet<AudioQuality>(
    context: context,
    useSafeArea: true,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
            child: Row(
              children: [
                Text(
                  uiTx('缓存音频'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: Text(
              uiTx('蓝色项是按你的播放设置与当前网络推荐的音质，仅供参考'),
              style: const TextStyle(fontSize: 12),
            ),
          ),
          for (final quality in AudioCacheService.cacheQualities)
            Builder(
              builder: (context) {
                final colorScheme = ColorScheme.of(context);
                final isRecommended = quality == recommended;
                return ListTile(
                  dense: true,
                  title: Text(
                    uiTx(quality.desc),
                    style: TextStyle(
                      fontSize: 14,
                      color: isRecommended ? colorScheme.primary : null,
                      fontWeight: isRecommended ? FontWeight.w600 : null,
                    ),
                  ),
                  trailing: isRecommended
                      ? Icon(
                          Icons.check_rounded,
                          size: 20,
                          color: colorScheme.primary,
                        )
                      : null,
                  onTap: () => Navigator.of(context).pop(quality),
                );
              },
            ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}
