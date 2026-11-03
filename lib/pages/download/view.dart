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
  const DownloadPage({super.key, this.initialCacheModule});

  /// 打开时默认停在哪个一级页签：
  /// 0 = 缓存视频，1 = 缓存音频，2 = 下载视频，3 = 下载音频。
  ///
  /// 为 null 时沿用「记住上次停留的页签」（Pref.downloadCacheModule）。
  /// 从视频页的「视频缓存 / 音频缓存 / 下载视频 / 下载音频」入口进来时会显式指定，
  /// 让用户点哪个就落到哪个，而不是被上次的选择带偏。
  final int? initialCacheModule;

  @override
  State<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage>
    with TickerProviderStateMixin, BaseFabMixin, FabMixin {
  /// 本页可能出现的**弹窗 / 菜单 / 次级界面**文案清单（预翻译用，见 initState）。
  ///
  /// 判定标准：这段文字在用户**打开本页时看不到**，只有点了某个按钮、
  /// 展开某个 ⋮ 菜单、或弹出某个确认框才会显示。这类文案如果不预热，
  /// 等它出现时才排进翻译队列，用户就会先看到中文、过一会儿跳成译文。
  ///
  /// 维护要求：在本页**新增任何弹窗/菜单/对话框**时，把它的文案同步加到这里。
  static const List<String> _prewarmStrings = [
    // —— 缓存视频右侧 ⋮ 菜单 ——
    '添加到文件夹', '添加到「{0}」', '已添加到文件夹', '已添加到「{0}」',
    '添加到其他文件夹', '重命名', '删除', '排序', '手动排序', '按缓存时间',
    '已按缓存时间显示', '继续播放', '更新', '添加到', '导出', '缓存',
    '多选', '搜索', '新建文件夹', '重命名文件夹', '文件夹', '全部视频',
    '正在缓存', '已下载', '下载中', '下载失败', '缓存失败',
    '该内容正在下载', '已删除本地文件', '已清理档案',
    // —— 文件夹相关对话框 ——
    '创建成功', '重命名成功', '新建文件夹的名称', '请输入文件夹名称',
    '确认删除', '确定', '取消', '保存',
    '选中的文件夹里没有可导出的缓存', '导出成功', '导出失败',
    // —— 删除 / 清理确认 ——
    '删除本地文件', '清理档案', '本地文件还在，先删除文件',
    '本地文件已删除', '确认删除该缓存吗', '删除后不可恢复',
    // —— 多选相关 ——
    '全选', '取消全选', '已选择 {0} 项', '删除所选',
    '确认删除所选的 {0} 个缓存吗',
    // —— 搜索 ——
    '搜索缓存', '没有找到匹配的缓存', '清除搜索',
    // —— 缓存音频页 ——
    '还没有缓存音频', '音频缓存完成', '正在缓存音频',
    // —— 下载视频 / 下载音频页 ——
    '还没有下载过视频', '还没有下载过音频', '重新下载',
    '按当时的画质 / 音质重新下载', '音频', '视频',
    // —— 通用状态 ——
    '加载中', '没有更多了', '出错了', '重试',
  ];

  final _downloadService = Get.find<DownloadService>();
  final _collectionService = Get.find<DownloadCollectionService>();
  final _controller = Get.put(DownloadPageController());
  late final _folderSelectController = Get.put(
    DownloadFolderSelectController(_controller),
  );
  /// 仅用来给下载进度条做重建通知。
  ///
  /// `ChangeNotifier.notifyListeners()` 是 protected，外部直接调用会触发
  /// invalid_use_of_protected_member / invalid_use_of_visible_for_testing_member。
  /// 用一层子类把它包成公开的 `notify()` 即可，语义不变。
  final _progress = _NotifyingChangeNotifier();

  late final TabController _tabController;
  int _tabIndex = 0;
  bool _isOpeningContinue = false;

  /// 缓存模块：0 = 缓存视频，1 = 缓存音频。
  /// 调用方显式指定时优先用它，否则沿用上次停留的模块。
  late int _cacheModule =
      widget.initialCacheModule ?? Pref.downloadCacheModule;
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
    // 预翻译：这一页几乎全部内容都是「点开才出现」的弹窗 / 菜单 ——
    // 缓存视频右侧 ⋮ 的十几个菜单项、删除确认框、新建/重命名文件夹、
    // 排序方式、多选操作、导出提示……它们此时一个都没渲染过，
    // 等用户点开才翻就会出现「先中文后跳日文」。这里一次性全部登记，
    // 走优先队列预热（见 UiTranslateService.precache）。
    UiTranslateService.precache(_prewarmStrings);
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
      _progress.notify();
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
          child: Text(uiTx('添加到文件夹'), style: const TextStyle(fontSize: 13)),
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
        child: Text(uiTx('添加到其他文件夹'), style: const TextStyle(fontSize: 13)),
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
                child: Text(uiTx('重命名'), style: const TextStyle(fontSize: 13)),
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
                  // 缓存视频那一页还有「全部视频 / 文件夹」二级 TabBar，
                  // 其余三页没有，所以高度要按当前模块给。
                  _cacheModule == 0 ? 46 + kTextTabBarHeight : 46,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 46,
                      // 横向可滚动：这四项译文在某些语言下会明显变长，固定 Row 会把
                      // 最右侧文字挤出屏幕且无法查看。改成横向滚动后放得下正常显示、
                      // 放不下可以左右滑。
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(right: 12),
                        child: Row(
                          children: [
                            const SizedBox(width: 12),
                            _moduleBtn(0, '缓存视频'),
                            const SizedBox(width: 8),
                            _moduleBtn(1, '缓存音频'),
                            const SizedBox(width: 8),
                            _moduleBtn(2, '下载视频'),
                            const SizedBox(width: 8),
                            _moduleBtn(3, '下载音频'),
                          ],
                        ),
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
          body: switch (_cacheModule) {
            // 1 = 缓存音频
            1 => _buildAudioTab(),
            // 2 = 下载视频，3 = 下载音频（原本是「下载情况」二级页里的两个页签，
            // 现在提到一级，直接复用同一套列表组件）
            2 => const LocalDownloadList(isAudio: false),
            3 => const LocalDownloadList(isAudio: true),
            // 0 = 缓存视频（内部还有「全部视频 / 文件夹」二级页签）
            _ => Stack(
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
          },
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
                    uiTxTight(task.title),
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
        setState(_audioSelected.clear);
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

/// 暴露 [ChangeNotifier.notifyListeners] 的私有包装：该类本身是 protected，
/// 外部直接调用会触发 analyze 的 invalid_use_of_* 提示。
final class _NotifyingChangeNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}
