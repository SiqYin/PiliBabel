import 'package:PiliPlus/common/widgets/image/network_img_layer.dart';
import 'package:PiliPlus/models_new/download/local_download_record.dart';
import 'package:PiliPlus/services/download/local_download_service.dart';
import 'package:PiliPlus/services/ui_translate/ui_translate_service.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:material_ui/material_ui.dart';

/// 「下载情况」：看得见下载到本地的视频 / 音频。
///
/// 三个问题一眼可答：
/// - 下载过哪些 —— 视频 / 音频两个分条；
/// - 下到多少了 —— 已下载字节 / 总大小，下载中还有进度条；
/// - 本地文件还在不在 —— 不在就显示「本地文件已删除」。
///
/// 右侧三点菜单：「删除」删掉本地文件，档案保留并转为「本地文件已删除」；
/// 「清理档案」只在本地文件已经不存在时可用，点掉才从列表里消失。
/// 样式对齐「缓存视频 / 缓存音频」两个界面。
class LocalDownloadPage extends StatefulWidget {
  const LocalDownloadPage({super.key, this.initialAudio = false});

  /// 打开时默认停在哪个标签：false = 下载视频，true = 下载音频。
  /// 从「下载视频 / 下载音频」入口进来时显式指定，点哪个就落到哪个。
  final bool initialAudio;

  @override
  State<LocalDownloadPage> createState() => _LocalDownloadPageState();
}

String _formatSize(int bytes) {
  if (bytes <= 0) {
    return '0 B';
  }
  const units = ['B', 'KB', 'MB', 'GB', 'TB'];
  var size = bytes.toDouble();
  var i = 0;
  while (size >= 1024 && i < units.length - 1) {
    size /= 1024;
    i++;
  }
  return '${size.toStringAsFixed(size >= 100 || i == 0 ? 0 : 1)} ${units[i]}';
}

class _LocalDownloadPageState extends State<LocalDownloadPage>
    with SingleTickerProviderStateMixin {
  final LocalDownloadService _service = Get.find<LocalDownloadService>();
  late final TabController _tabController = TabController(
    length: 2,
    vsync: this,
    initialIndex: widget.initialAudio ? 1 : 0,
  );

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // 档案新增、进度、删除都靠这个计数刷新。
      _service.recordsRevision.value;
      return Scaffold(
        appBar: AppBar(
          title: Text(uiTx('下载情况')),
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: uiTx('下载视频')),
              Tab(text: uiTx('下载音频')),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildList(isAudio: false),
            _buildList(isAudio: true),
          ],
        ),
      );
    });
  }

  Widget _buildList({required bool isAudio}) {
    final list = _service.records.where((e) => e.isAudio == isAudio).toList();
    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            isAudio ? uiTx('还没有下载过音频') : uiTx('还没有下载过视频'),
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).colorScheme.outline),
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final record = list[index];
        return _LocalDownloadItem(
          record: record,
          onMore: () => _showMore(record),
        );
      },
    );
  }

  Future<void> _showMore(LocalDownloadRecord record) async {
    // 每次打开菜单都重新判断：用户可能在别处刚把文件删掉。
    final missing = record.fileMissingAndSettled;
    // 下载失败或本地文件已删除时才提供「重新下载」：让用户在原地一键重下，
    // 不用回视频页重新找稿件、重新选画质音质。
    final canRedownload = record.failed || missing;
    final value = await showModalBottomSheet<int>(
      context: context,
      useSafeArea: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (canRedownload)
              ListTile(
                dense: true,
                leading: const Icon(Icons.download_for_offline_outlined, size: 20),
                title: Text(uiTx('重新下载')),
                subtitle: Text(uiTx('按当时的画质 / 音质重新下载')),
                onTap: () => Navigator.of(sheetContext).pop(2),
              ),
            ListTile(
              dense: true,
              leading: const Icon(Icons.delete_outline, size: 20),
              title: Text(uiTx('删除')),
              onTap: () => Navigator.of(sheetContext).pop(0),
            ),
            ListTile(
              dense: true,
              enabled: missing,
              leading: const Icon(Icons.delete_sweep_outlined, size: 20),
              title: Text(uiTx('清理档案')),
              subtitle: missing ? null : Text(uiTx('本地文件还在，先删除文件')),
              onTap: missing ? () => Navigator.of(sheetContext).pop(1) : null,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (!mounted || value == null) {
      return;
    }
    if (value == 2) {
      await _service.redownload(record);
      return;
    }
    if (value == 0) {
      final confirmed = await _confirmDelete(record);
      if (!confirmed) {
        return;
      }
      await _service.deleteLocalFile(record);
      if (mounted) {
        SmartDialog.showToast(uiTx('已删除本地文件'));
      }
      return;
    }
    _service.removeRecord(record);
    if (mounted) {
      SmartDialog.showToast(uiTx('已清理档案'));
    }
  }

  Future<bool> _confirmDelete(LocalDownloadRecord record) async {
    final res = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(uiTx('删除本地文件')),
        content: Text(
          uiTxP(
            '确认删除「{0}」的本地文件吗？删除后这一条会显示「本地文件已删除」，'
            '再点「清理档案」才会从列表里消失。',
            [record.title],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(uiTx('取消')),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(uiTx('确定')),
          ),
        ],
      ),
    );
    return res ?? false;
  }
}

class _LocalDownloadItem extends StatelessWidget {
  const _LocalDownloadItem({required this.record, required this.onMore});

  final LocalDownloadRecord record;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // 下载进行中不做完整性检测：文件要等写完才落盘，中途必然「不存在」，
    // 否则会出现「进度条在走、同时又提示本地文件已删除」的怪状。
    final missing = record.fileMissingAndSettled;
    final sizeText = record.totalBytes > 0
        ? '${_formatSize(record.receivedBytes)} / '
              '${_formatSize(record.totalBytes)}'
        : _formatSize(record.receivedBytes);
    return InkWell(
      onTap: onMore,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: NetworkImgLayer(
                src: record.cover,
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
                      uiTx(record.title),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14, height: 1.25),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Obx(
                    () {
                      // 状态与「分离流」标签都在 Obx 里调用 uiTx，译文异步回落后自动刷新。
                      final String status;
                      if (record.failed) {
                        status = uiTx('下载失败');
                      } else if (record.done) {
                        status = uiTx('已下载');
                      } else {
                        status = uiTx('下载中');
                      }
                      final splitTag = record.splitStream
                          ? ' · ${uiTx('分离流')}'
                          : '';
                      return Text(
                        '$status · $sizeText$splitTag',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.outline,
                        ),
                      );
                    },
                  ),
                  if (!record.done && !record.failed)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: LinearProgressIndicator(
                        value: record.totalBytes > 0 ? record.progress : null,
                        minHeight: 3,
                      ),
                    ),
                  if (record.ownerName case final name?)
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
                  if (missing)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        uiTx('本地文件已删除'),
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.error,
                        ),
                      ),
                    ),
                ],
              ),
            ),
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
