import 'package:PiliPlus/models/common/video/audio_quality.dart';
import 'package:PiliPlus/services/download/audio_cache_service.dart';
import 'package:PiliPlus/services/ui_translate/ui_translate_service.dart';
import 'package:material_ui/material_ui.dart';

/// 选音频缓存的音质档位：从 Hi-Res 无损到 64K，由高到低。
/// 返回 null 表示用户取消。
Future<AudioQuality?> showAudioCacheQualityPicker(BuildContext context) {
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
          for (final quality in AudioCacheService.cacheQualities)
            ListTile(
              dense: true,
              title: Text(uiTx(quality.desc)),
              onTap: () => Navigator.of(context).pop(quality),
            ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}
