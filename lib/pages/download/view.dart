import 'package:PiliPlus/services/ui_translate/ui_translate_service.dart';
import 'dart:io' show Platform;

import 'package:PiliPlus/common/widgets/appbar/appbar.dart';
import 'package:PiliPlus/common/widgets/flutter/popup_menu.dart';
import 'package:PiliPlus/common/widgets/flutter/pop_scope.dart';
import 'package:PiliPlus/common/widgets/loading_widget/http_error.dart';
import 'package:PiliPlus/common/widgets/scaffold/simple_scaffold.dart';
import 'package:PiliPlus/models_new/download/bili_download_entry_info.dart';
import 'package:PiliPlus/models_new/download/download_collection.dart';
import 'package:PiliPlus/pages/common/fab_mixin.dart';
import 'package:PiliPlus/pages/common/multi_select/base.dart';
import 'package:PiliPlus/pages/download/controller.dart';
import 'package:PiliPlus/pages/download/detail/widgets/item.dart';
import 'package:PiliPlus/pages/download/folder/view.dart';
import 'package:PiliPlus/pages/download/folder_manage/view.dart';
import 'package:PiliPlus/pages/download/search/view.dart';
import 'package:PiliPlus/pages/download/sort/view.dart';
import 'package:PiliPlus/pages/download/utils/cache_delete_confirm.dart';
import 'package:PiliPlus/pages/download/utils/cache_export.dart';
import 'package:PiliPlus/pages/download/utils/open_download_entry.dart';
import 'package:PiliPlus/pages/download/widgets/folder_card.dart';
import 'package:PiliPlus/pages/download/widgets/folder_dialog.dart';
import 'package:PiliPlus/services/download/download_collection_service.dart';
import 'package:PiliPlus/services/download/download_service.dart';
import 'package:PiliPlus/utils/grid.dart';
import 'package:PiliPlus/utils/storage.dart';
import 'package:collection/collection.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:PiliPlus/grpc/bilibili/app/listener/v1.pbenum.dart' show PlaylistSource;
import 'package:PiliPlus/models_new/download/audio_cache_entry.dart';
import 'package:PiliPlus/pages/audio/view.dart';
import 'package:PiliPlus/pages/download/widgets/audio_cache_item.dart';
import 'package:PiliPlus/services/download/audio_cache_service.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:PiliPlus/utils/utils.dart';
import 'package:material_ui/material_ui.dart'
    hide SliverGridDelegateWithMaxCrossAxisExtent;
import 'package:PiliPlus/pages/download/local_download/view.dart';

enum _DownloadTab {
  videos('全部视频'),
  folders('文件夹')
  ;

  final String label;
  const _DownloadTab(this.label);
}

enum _DownloadSortAction {
  manual,
  reset,
}

/// 缓存音频任务的进度详情：百分比 + 速度 + 已加载/总容量，如「45% 358K/s 3.4M/12.6M」。
/// 只含阿拉伯数字与 K/M/G/s 单位字母，各语言用户都能看懂，不做翻译。
String _audioTaskDetailText(AudioCacheTask task, bool downloading) {
  final buf = StringBuffer(
    '${(task.progress * 100).toStringAsFixed(0)}%',
  );
  if (downloading) {
    buf.write(' ${_formatCacheBytes(task.speed.value)}/s');
  }
  buf.write(' ${_formatCacheBytes(task.received.value)}');
  final total = task.total.value;
  if (total > 0) {
    buf.write('/${_formatCacheBytes(total)}');
  }
  return buf.toString();
}

String _formatCacheBytes(int bytes) {
  if (bytes <= 0) {
    return '0K';
  }
  const units = ['K', 'M', 'G'];
  var size = bytes / 1024;
  var i = 0;
  while (size >= 1024 && i < units.length - 1) {
    size /= 1024;
    i++;
  }
  return '${size.toStringAsFixed(size >= 100 || i == 0 ? 0 : 1)}${units[i]}';
}

class DownloadPage extends StatefulWidget {
  const DownloadPage({super.key});

  @override
  State<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage>
    with TickerProviderStateMixin, BaseFabMixin, FabMixin {
  final _downloadService = Get.find<DownloadService>();
  final _collectionService = Get.find<DownloadCollectionService>();
  final _controller = Get.put(DownloadPageController());
  late final _folderSelectController = Get.put(
    DownloadFolderSelectController(_controller),
  );
  final _progress = ChangeNotifier();

  late final TabController _tabController;
  int _tabIndex = 0;
  bool _isOpeningContinue = false;

  /// 缓存模块：0 = 缓存视频，1 = 缓存音频。默认取上次停留的模块。
  late int _cacheModule = Pref.downloadCacheModule;
  final _audioCacheService = Get.find<AudioCacheService>();
  final _audioSelected = <String>{};
  bool _audioSelectMode = false;

  void _setCacheModule(int value) {
    if (_cacheModule == value) {
      return;
    }
    Pref.setDownloadCacheModule(value);
    setState(() {
      _cacheModule = value;
      _audioSelectMode = false;
      _audioSelected.clear();
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _DownloadTab.values.length,
      vsync: this,
    )..addListener(_handleTabChanged);
  }

  void _handleTabChanged() {
    if (_tabController.indexIsChanging) {
      return;
    }
    if (_tabIndex != _tabController.index && mounted) {
      setState(() {
        _tabIndex = _tabController.index;
      });
    }
    if (_tabController.index != 0 && _controller.enableMultiSelect.value) {
      _controller.handleSelect();
    }
    if (_tabController.index != 1 &&
        _folderSelectController.enableMultiSelect.value) {
      _folderSelectController.handleSelect();
    }
    if (_tabController.index == 0 &&
        !_controller.enableMultiSelect.value &&
        _controller.continueTarget.value != null) {
      showFab();
    }
  }

  @override
  void dispose() {
    _tabController
      ..removeListener(_handleTabChanged)
      ..dispose();
    _progress.dispose();
    super.dispose();
  }

  Future<void> _createFolder() async {
    final title = await showDownloadFolderNameDialog(
      context: context,
      title: uiTx('新建文件夹'),
      initialValue: _collectionService.buildDefaultFolderTitle(),
    );
    if (title == null) {
      return;
    }
    await _collectionService.createFolder(title);
    SmartDialog.showToast(uiTx('创建成功'));
  }

  Future<void> _renameFolder(DownloadFolder folder) async {
    final title = await showDownloadFolderNameDialog(
      context: context,
      title: uiTx('重命名文件夹'),
      initialValue: folder.title,
    );
    if (title == null || title == folder.title) {
      return;
    }
    await _collectionService.renameFolder(folder.id, title);
    SmartDialog.showToast(uiTx('重命名成功'));
  }

  Future<void> _deleteFolder(DownloadFolder folder) async {
    await confirmDeleteFolders(
      context: context,
      collectionService: _collectionService,
      downloadService: _downloadService,
      folders: [folder],
    );
  }

  Future<void> _addSelectedToFolders() async {
    final folderIds = await showDownloadFolderPickerDialog(
      context: context,
      collectionService: _collectionService,
      title: uiTx('添加到文件夹'),
    );
    if (folderIds == null || folderIds.isEmpty) {
      return;
    }
    await _collectionService.addVideosToFolders(
      _controller.allChecked.map((item) => item.cid),
      folderIds,
    );
    _controller.handleSelect();
    SmartDialog.showToast(uiTx('已添加到文件夹'));
  }

  Future<void> _exportSelected() async {
    final entries = _controller.allChecked.toList();
    _controller.handleSelect();
    await exportDownloadEntries(entries);
  }

  Future<void> _exportSelectedFolders() async {
    final folders = _folderSelectController.allChecked.toList();
    final seenCids = <int>{};
    final entries = folders
        .expand((folder) => _controller.resolveFolderEntries(folder.id))
        .where((entry) => seenCids.add(entry.cid))
        .toList();
    _folderSelectController.handleSelect();
    if (entries.isEmpty) {
      SmartDialog.showToast(uiTx('选中的文件夹里没有可导出的缓存'));
      return;
    }
    await exportDownloadEntries(entries);
  }

  Future<void> _openContinueTarget(DownloadContinueTarget target) async {
    if (_isOpeningContinue) {
      return;
    }
    setState(() {
      _isOpeningContinue = true;
    });
    try {
      await openDownloadEntry(
        entry: target.entry,
        playContext: target.playContext,
      );
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) {
        return;
      }
      _progress.notifyListeners();
      await _controller.refreshContinueTarget();
    } finally {
      if (mounted) {
        setState(() {
          _isOpeningContinue = false;
        });
      }
    }
  }

  Future<void> _openAllSortPage() async {
    if (_controller.allVideos.isEmpty) {
      return;
    }
    await Get.to(
      DownloadVideoSortPage(
        title: uiTx('排序: 全部视频'),
        entries: _controller.allVideos,
        onSave: _collectionService.saveAllVideoOrder,
      ),
    );
  }

  Future<void> _resetAllSort() async {
    await _collectionService.resetAllVideoOrder();
    SmartDialog.showToast(uiTx('已按缓存时间显示'));
  }

  void _onAllSortSelected(_DownloadSortAction action) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) {
        return;
      }
      if (action == _DownloadSortAction.manual) {
        await _openAllSortPage();
      } else {
        await _resetAllSort();
      }
    });
  }

  Future<void> _openFolderManagePage() async {
    await Get.to(
      DownloadFolderManagePage(collectionService: _collectionService),
    );
  }

  List<PopupMenuEntry<void>> _buildFolderQuickMenuItems(
    BuildContext context,
    BiliDownloadEntryInfo entry,
  ) {
    final folders = _controller.folders;
    if (folders.isEmpty) {
      return [
        CustomPopupMenuItem<void>(
          height: 38,
          child: Text(uiTx('添加到文件夹'), style: TextStyle(fontSize: 13)),
          onTap: () async {
            final selectedIds = await showDownloadFolderPickerDialog(
              context: context,
              collectionService: _collectionService,
              title: uiTx('添加到文件夹'),
            );
            if (selectedIds == null || selectedIds.isEmpty) {
              return;
            }
            await _collectionService.addVideosToFolders(
              [entry.cid],
              selectedIds,
            );
            SmartDialog.showToast(uiTx('已添加到文件夹'));
          },
        ),
      ];
    }
    return [
      const PopupMenuDivider(height: 8),
      ...folders.map(
        (folder) => CustomPopupMenuItem<void>(
          height: 38,
          child: Text(uiTx('添加到「${folder.title}」'),
            style: const TextStyle(fontSize: 13),
          ),
          onTap: () async {
            await _collectionService.addVideosToFolders(
              [entry.cid],
              [folder.id],
            );
            SmartDialog.showToast(uiTx('已添加到「${folder.title}」'));
          },
        ),
      ),
      CustomPopupMenuItem<void>(
        height: 38,
        child: Text(uiTx('添加到其他文件夹'), style: TextStyle(fontSize: 13)),
        onTap: () async {
          final selectedIds = await showDownloadFolderPickerDialog(
            context: context,
            collectionService: _collectionService,
            title: uiTx('添加到文件夹'),
          );
          if (selectedIds == null || selectedIds.isEmpty) {
            return;
          }
          await _collectionService.addVideosToFolders(
            [entry.cid],
            selectedIds,
          );
          SmartDialog.showToast(uiTx('已添加到文件夹'));
        },
      ),
    ];
  }

  Widget _buildFolderMoreBtn(DownloadFolder folder) {
    return Builder(
      builder: (context) => IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(
          Icons.more_vert_outlined,
          color: Theme.of(context).colorScheme.outline,
          size: 18,
        ),
        onPressed: () {
          showStaticPositionMenu<int>(
            context: context,
            items: [
              CustomPopupMenuItem(
                value: 0,
                height: 38,
                child: Text(uiTx('重命名'), style: TextStyle(fontSize: 13)),
              ),
              CustomPopupMenuItem(
                value: 1,
                height: 38,
                child: Text(uiTx('删除'),
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            ],
          ).then((value) {
            if (value == 0) _renameFolder(folder);
            if (value == 1) _deleteFolder(folder);
          });
        },
      ),
    );
  }

  Widget _buildAllSortBtn() {
    return Builder(
      builder: (context) => IconButton(
        tooltip: uiTx('排序'),
        icon: const Icon(Icons.sort),
        onPressed: () {
          showStaticPositionMenu<_DownloadSortAction>(
            context: context,
            items: [
              CustomPopupMenuItem(
                value: _DownloadSortAction.manual,
                child: Text(uiTx('手动排序')),
              ),
              CustomPopupMenuItem(
                value: _DownloadSortAction.reset,
                child: Text(uiTx('按缓存时间')),
              ),
            ],
          ).then((value) {
            if (value != null) _onAllSortSelected(value);
          });
        },
      ),
    );
  }

  Widget _buildContinueFab() {
    return Obx(() {
      final target = _controller.continueTarget.value;
      final shouldShow =
          _tabIndex == 0 &&
          !_controller.enableMultiSelect.value &&
          target != null;
      if (!shouldShow) {
        return const SizedBox.shrink();
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          showFab();
        }
      });
      final padding = MediaQuery.viewPaddingOf(context);
      return Positioned(
        right: padding.right + kFloatingActionButtonMargin,
        bottom: 0,
        child: SlideTransition(
          position: fabAnimation,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: padding.bottom + kFloatingActionButtonMargin,
            ),
            child: FloatingActionButton.extended(
              onPressed: _isOpeningContinue
                  ? null
                  : () => _openContinueTarget(target),
              label: Text(uiTx('继续播放')),
            ),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentTab = _DownloadTab.values[_tabIndex];
      final isVideoTab = currentTab == _DownloadTab.videos;
      final MultiSelectBase activeMultiSelectCtr = isVideoTab
          ? _controller
          : _folderSelectController;
      final enableMultiSelect = isVideoTab
          ? _controller.enableMultiSelect.value
          : _folderSelectController.enableMultiSelect.value;
      return popScope(
        canPop: !enableMultiSelect,
        onPopInvokedWithResult: (didPop, result) {
          if (enableMultiSelect) {
            activeMultiSelectCtr.handleSelect();
          }
        },
        child: SimpleScaffold(
          appBar: MultiSelectAppBarWidget(
            ctr: activeMultiSelectCtr,
            visible: enableMultiSelect,
            actions: isVideoTab
                ? [
                    TextButton(
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                      ),
                      onPressed: () async {
                        final futures = _controller.allChecked
                            .map(
                              (e) => _downloadService.downloadDanmaku(
                                entry: e,
                                isUpdate: true,
                              ),
                            )
                            .toList();
                        _controller.handleSelect();
                        final res = await Future.wait(futures);
                        SmartDialog.showToast(
                          res.every((item) => item) ? '更新成功' : '更新失败',
                        );
                      },
                      child: Text(uiTx('更新'),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                      ),
                      onPressed: _controller.checkedCount == 0
                          ? null
                          : _addSelectedToFolders,
                      child: Text(uiTx('添加到')),
                    ),
                    if (Platform.isAndroid)
                      TextButton(
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                        ),
                        onPressed: _controller.checkedCount == 0
                            ? null
                            : _exportSelected,
                        child: Text(uiTx('导出')),
                      ),
                  ]
                : Platform.isAndroid
                ? [
                    TextButton(
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                      ),
                      onPressed: _folderSelectController.checkedCount == 0
                          ? null
                          : _exportSelectedFolders,
                      child: Text(uiTx('导出')),
                    ),
                  ]
                : null,
            child: AppBar(
              title: Text(uiTx('缓存')),
              actions: [
                if (_cacheModule == 1) ...[
                  if (_audioSelectMode)
                    TextButton(
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                      ),
                      onPressed: _audioSelected.isEmpty
                          ? null
                          : () => _confirmDeleteAudio(
                              _audioCacheService.audioList
                                  .where(
                                    (e) => _audioSelected.contains(e.id),
                                  )
                                  .toList(),
                            ),
                      child: Text(uiTx('删除')),
                    ),
                  IconButton(
                    tooltip: uiTx('多选'),
                    onPressed: () => setState(() {
                      _audioSelectMode = !_audioSelectMode;
                      _audioSelected.clear();
                    }),
                    icon: const Icon(Icons.edit_note),
                  ),
                ] else if (isVideoTab) ...[
                  IconButton(
                    tooltip: uiTx('搜索'),
                    onPressed: () async {
                      await _downloadService.waitForInitialization;
      await _audioCacheService.waitForInitialization;
                      if (!mounted) {
                        return;
                      }
                      await Get.to(DownloadSearchPage(progress: _progress));
                      if (mounted) {
                        await _controller.refreshContinueTarget();
                      }
                    },
                    icon: const Icon(Icons.search),
                  ),
                  IconButton(
                    tooltip: uiTx('多选'),
                    onPressed: () {
                      if (_controller.enableMultiSelect.value) {
                        _controller.handleSelect();
                      } else {
                        _controller.enableMultiSelect.value = true;
                      }
                    },
                    icon: const Icon(Icons.edit_note),
                  ),
                  _buildAllSortBtn(),
                ] else ...[
                  IconButton(
                    tooltip: uiTx('新建文件夹'),
                    onPressed: _createFolder,
                    icon: const Icon(Icons.create_new_folder_outlined),
                  ),
                  IconButton(
                    tooltip: uiTx('多选'),
                    onPressed: () {
                      if (_folderSelectController.enableMultiSelect.value) {
                        _folderSelectController.handleSelect();
                      } else {
                        _folderSelectController.enableMultiSelect.value = true;
                      }
                    },
                    icon: const Icon(Icons.edit_note),
                  ),
                  IconButton(
                    tooltip: uiTx('排序'),
                    onPressed: _openFolderManagePage,
                    icon: const Icon(Icons.sort),
                  ),
                ],
                const SizedBox(width: 6),
              ],
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(
                  _cacheModule == 1 ? 46 : 46 + kTextTabBarHeight,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 46,
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          _moduleBtn(0, '缓存视频'),
                          const SizedBox(width: 8),
                          _moduleBtn(1, '缓存音频'),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: () =>
                                Get.to(const LocalDownloadPage()),
                            style: TextButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                            ),
                            child: Text(uiTx('下载情况')),
                          ),
                        ],
                      ),
                    ),
                    if (_cacheModule == 0)
                      TabBar(
                        controller: _tabController,
                        tabs: [
                          Tab(
                            child: Obx(
                              () => Text(
                                uiTx(
                                  '全部视频(${_controller.allVideos.length})',
                                ),
                              ),
                            ),
                          ),
                          Tab(
                            child: Obx(
                              () => Text(
                                uiTx('文件夹(${_controller.folders.length})'),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
          body: _cacheModule == 1 ? _buildAudioTab() : Stack(
            clipBehavior: Clip.none,
            children: [
              NotificationListener<UserScrollNotification>(
                onNotification: (notification) {
                  if (_tabIndex != 0) {
                    return false;
                  }
                  final direction = notification.direction;
                  if (direction == .forward) {
                    showFab();
                  } else if (direction == .reverse) {
                    hideFab();
                  }
                  return false;
                },
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAllVideosTab(),
                    _buildFoldersTab(),
                  ],
                ),
              ),
              _buildContinueFab(),
            ],
          ),
        ),
      );
    });
  }

  Widget _moduleBtn(int value, String label) {
    final selected = _cacheModule == value;
    final colorScheme = Theme.of(context).colorScheme;
    return TextButton(
      onPressed: selected ? null : () => _setCacheModule(value),
      style: TextButton.styleFrom(
        visualDensity: VisualDensity.compact,
        backgroundColor: selected ? colorScheme.primaryContainer : null,
        padding: const EdgeInsets.symmetric(horizontal: 14),
      ),
      child: Text(
        uiTx(label),
        style: TextStyle(
          fontSize: 13,
          color: selected
              ? colorScheme.onPrimaryContainer
              : colorScheme.outline,
          fontWeight: selected ? FontWeight.w600 : null,
        ),
      ),
    );
  }

  Widget _buildAudioTab() {
    final padding = MediaQuery.viewPaddingOf(context);
    return Obx(() {
      final tasks = _audioCacheService.taskList;
      final list = _audioCacheService.audioList;
      if (tasks.isEmpty && list.isEmpty) {
        return Center(
          child: Text(
            uiTx('还没有缓存音频'),
            style: TextStyle(color: Theme.of(context).colorScheme.outline),
          ),
        );
      }
      return ListView.builder(
        padding: EdgeInsets.only(
          left: padding.left,
          right: padding.right,
          bottom: padding.bottom + 24,
        ),
        itemCount: tasks.length + list.length,
        itemBuilder: (context, index) {
          if (index < tasks.length) {
            return _buildAudioTask(tasks[index]);
          }
          final entry = list[index - tasks.length];
          return AudioCacheItem(
            entry: entry,
            selectMode: _audioSelectMode,
            selected: _audioSelected.contains(entry.id),
            onTap: () {
              if (_audioSelectMode) {
                setState(() {
                  if (!_audioSelected.remove(entry.id)) {
                    _audioSelected.add(entry.id);
                  }
                });
                return;
              }
              _playAudio(entry);
            },
            onMore: () => showAudioCacheItemMenu(
              context: context,
              onDelete: () => _confirmDeleteAudio([entry]),
              onCopyPath: () => Utils.copyText(entry.filePath),
            ),
          );
        },
      );
    });
  }

  Widget _buildAudioTask(AudioCacheTask task) {
    final colorScheme = Theme.of(context).colorScheme;
    return Obx(() {
      final failed = task.status.value == AudioCacheStatus.failed;
      final downloading = task.status.value == AudioCacheStatus.downloading;
      final progress = task.progress;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    uiTx(task.title),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: failed ? null : progress,
                    minHeight: 3,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    failed
                        ? uiTx('缓存失败')
                        : _audioTaskDetailText(task, downloading),
                    style: TextStyle(fontSize: 12, color: colorScheme.outline),
                  ),
                ],
              ),
            ),
            if (failed)
              IconButton(
                visualDensity: VisualDensity.compact,
                tooltip: uiTx('重新缓存'),
                onPressed: () => _audioCacheService.retryTask(task),
                icon: Icon(Icons.refresh, size: 18, color: colorScheme.primary),
              ),
            IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: () => _audioCacheService.cancelTask(task),
              icon: Icon(Icons.close, size: 18, color: colorScheme.outline),
            ),
          ],
        ),
      );
    });
  }

  Future<void> _playAudio(AudioCacheEntry entry) async {
    await AudioPage.toAudioPage(
      oid: entry.avid,
      subId: [entry.cid],
      itemType: 1,
      from: PlaylistSource.UP_ARCHIVE,
      audioUrl: Uri.file(entry.filePath).toString(),
      audioQa: entry.quality,
    );
  }

  Future<void> _confirmDeleteAudio(List<AudioCacheEntry> entries) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(uiTx('删除缓存音频？')),
        content: Text(uiTx('本地音频文件会一起删掉，无法恢复。')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(uiTx('取消')),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(uiTx('删除')),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _audioCacheService.delete(entries, deleteFile: true);
      if (mounted) {
        setState(() => _audioSelected.clear());
      }
    }
  }

  Widget _buildAllVideosTab() {
    final padding = MediaQuery.viewPaddingOf(context);
    return Padding(
      padding: EdgeInsets.only(left: padding.left, right: padding.right),
      child: CustomScrollView(
        slivers: [
          Obx(() {
            final entry =
                _downloadService.waitDownloadQueue.firstWhereOrNull(
                  (item) => item.cid == _downloadService.curCid,
                ) ??
                _downloadService.waitDownloadQueue.firstOrNull;
            if (entry == null) {
              return const SliverToBoxAdapter();
            }
            return SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 12, bottom: 7),
                      child: Text(uiTx('正在缓存 (${_downloadService.waitDownloadQueue.length})'),
                      ),
                    ),
                    SizedBox(
                      height: 100,
                      child: DetailItem(
                        entry: entry,
                        progress: _progress,
                        downloadService: _downloadService,
                        showTitle: true,
                        isCurr: true,
                        controller: _controller,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          Obx(() {
            if (_controller.allVideos.isEmpty) {
              if (_downloadService.waitDownloadQueue.isNotEmpty) {
                return const SliverToBoxAdapter();
              }
              return const SliverFillRemaining(
                hasScrollBody: false,
                child: HttpError(isSliver: false),
              );
            }
            return SliverPadding(
              padding: EdgeInsets.only(
                top: _downloadService.waitDownloadQueue.isNotEmpty ? 0 : 7,
              ),
              sliver: SliverGrid.builder(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  mainAxisSpacing: 2,
                  mainAxisExtent: 100,
                  maxCrossAxisExtent: Grid.smallCardWidth * 2,
                ),
                itemCount: _controller.allVideos.length,
                itemBuilder: (context, index) {
                  final entry = _controller.allVideos[index];
                  return DetailItem(
                    entry: entry,
                    progress: _progress,
                    downloadService: _downloadService,
                    showTitle: true,
                    onDelete: () async {
                      await GStorage.watchProgress.delete(entry.cid.toString());
                      await _collectionService.clearLastLocalPlayedIfCid(
                        entry.cid,
                      );
                      await _downloadService.deleteDownload(
                        entry: entry,
                        removeList: true,
                      );
                    },
                    controller: _controller,
                    playContext: const DownloadVideoPlayContext.all(),
                    onPlayReturned: _controller.refreshContinueTarget,
                    customOnLongPress: () => _controller
                      ..enableMultiSelect.value = true
                      ..onSelect(entry),
                    extraMoreItemsBuilder: (menuContext) =>
                        _buildFolderQuickMenuItems(menuContext, entry),
                  );
                },
              ),
            );
          }),
          SliverToBoxAdapter(
            child: SizedBox(height: padding.bottom + 100),
          ),
        ],
      ),
    );
  }

  Widget _buildFoldersTab() {
    final padding = MediaQuery.viewPaddingOf(context);
    return Padding(
      padding: EdgeInsets.only(left: padding.left, right: padding.right),
      child: CustomScrollView(
        slivers: [
          Obx(() {
            if (_controller.folders.isEmpty) {
              return SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(uiTx('还没有文件夹')),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: _createFolder,
                        icon: const Icon(Icons.create_new_folder_outlined),
                        label: Text(uiTx('新建文件夹')),
                      ),
                    ],
                  ),
                ),
              );
            }
            return SliverPadding(
              padding: EdgeInsets.only(top: 7, bottom: padding.bottom + 100),
              sliver: SliverGrid.builder(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  mainAxisSpacing: 2,
                  mainAxisExtent: 100,
                  maxCrossAxisExtent: Grid.smallCardWidth * 2,
                ),
                itemCount: _controller.folders.length,
                itemBuilder: (context, index) {
                  final folder = _controller.folders[index];
                  final entries = _controller.resolveFolderEntries(folder.id);
                  return DownloadFolderCard(
                    title: folder.title,
                    count: entries.length,
                    entry: entries.firstOrNull,
                    checked: folder.checked,
                    onTap: _folderSelectController.enableMultiSelect.value
                        ? () => _folderSelectController.onSelect(folder)
                        : () async {
                            await Get.to(
                              DownloadFolderPage(folderId: folder.id),
                            );
                            await _controller.refreshContinueTarget();
                          },
                    onLongPress: () => _folderSelectController
                      ..enableMultiSelect.value = true
                      ..onSelect(folder),
                    trailing: _folderSelectController.enableMultiSelect.value
                        ? null
                        : _buildFolderMoreBtn(folder),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}
