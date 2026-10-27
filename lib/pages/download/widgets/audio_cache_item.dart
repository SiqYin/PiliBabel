import 'package:PiliPlus/common/widgets/image/network_img_layer.dart';
import 'package:PiliPlus/models_new/download/audio_cache_entry.dart';
import 'package:PiliPlus/services/ui_translate/ui_translate_service.dart';
import 'package:material_ui/material_ui.dart';

/// 缓存音频列表里的一项。
class AudioCacheItem extends StatelessWidget {
  const AudioCacheItem({
    super.key,
    required this.entry,
    required this.onTap,
    required this.onMore,
    this.selectMode = false,
    this.selected = false,
  });

  final AudioCacheEntry entry;
  final VoidCallback onTap;
  final VoidCallback onMore;
  final bool selectMode;
  final bool selected;

  static String formatSize(int bytes) {
    if (bytes <= 0) {
      return '0 B';
    }
    const units = ['B', 'KB', 'MB', 'GB'];
    var size = bytes.toDouble();
    var i = 0;
    while (size >= 1024 && i < units.length - 1) {
      size /= 1024;
      i++;
    }
    return '${size.toStringAsFixed(size >= 100 || i == 0 ? 0 : 1)} ${units[i]}';
  }

  static String formatDuration(int ms) {
    if (ms <= 0) {
      return '';
    }
    final total = ms ~/ 1000;
    final h = total ~/ 3600;
    final m = (total % 3600) ~/ 60;
    final s = total % 60;
    String two(int v) => v < 10 ? '0$v' : '$v';
    return h > 0 ? '$h:${two(m)}:${two(s)}' : '${two(m)}:${two(s)}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final duration = formatDuration(entry.durationMs);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (selectMode)
              Padding(
                padding: const EdgeInsets.only(right: 8, top: 22),
                child: Icon(
                  selected
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  size: 20,
                  color: selected ? colorScheme.primary : colorScheme.outline,
                ),
              ),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: NetworkImgLayer(
                src: entry.cover,
                width: 96,
                height: 60,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(
                    () => Text(
                      uiTx(entry.title),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14, height: 1.25),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    [
                      entry.qualityDesc,
                      if (entry.ext.isNotEmpty) entry.ext.toUpperCase(),
                      if (duration.isNotEmpty) duration,
                      formatSize(entry.fileSize),
                    ].where((e) => e.isNotEmpty).join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: colorScheme.outline),
                  ),
                  if (entry.ownerName case final name?)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Obx(
                        () => Text(
                          uiTx(name),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.outline,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (!selectMode)
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: onMore,
                icon: Icon(
                  Icons.more_vert_outlined,
                  size: 18,
                  color: colorScheme.outline,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// 音频缓存的「更多」菜单。
Future<void> showAudioCacheItemMenu({
  required BuildContext context,
  required VoidCallback onDelete,
  required VoidCallback onCopyPath,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            dense: true,
            leading: const Icon(Icons.copy_outlined, size: 20),
            title: Text(uiTx('复制缓存路径')),
            onTap: () {
              Navigator.of(context).pop();
              onCopyPath();
            },
          ),
          ListTile(
            dense: true,
            leading: const Icon(Icons.delete_outline, size: 20),
            title: Text(uiTx('删除缓存')),
            onTap: () {
              Navigator.of(context).pop();
              onDelete();
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}
