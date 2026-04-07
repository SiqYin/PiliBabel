import 'package:PiliPlus/common/widgets/appbar/appbar.dart';
import 'package:PiliPlus/common/widgets/dialog/dialog.dart';
import 'package:PiliPlus/common/widgets/flutter/pop_scope.dart';
import 'package:PiliPlus/common/widgets/loading_widget/http_error.dart';
import 'package:PiliPlus/models_new/download/download_collection.dart';
import 'package:PiliPlus/pages/download/controller.dart';
import 'package:PiliPlus/pages/download/detail/widgets/item.dart';
import 'package:PiliPlus/pages/download/folder/view.dart';
import 'package:PiliPlus/pages/download/folder_manage/view.dart';
import 'package:PiliPlus/pages/download/search/view.dart';
import 'package:PiliPlus/pages/download/sort/view.dart';
import 'package:PiliPlus/pages/download/widgets/folder_card.dart';
import 'package:PiliPlus/pages/download/widgets/folder_dialog.dart';
import 'package:PiliPlus/services/download/download_collection_service.dart';
import 'package:PiliPlus/services/download/download_service.dart';
import 'package:PiliPlus/utils/extension/iterable_ext.dart' show IterableExt;
import 'package:PiliPlus/utils/grid.dart';
import 'package:PiliPlus/utils/storage.dart';
import 'package:flutter/material.dart'
    hide SliverGridDelegateWithMaxCrossAxisExtent;
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

enum _DownloadTab {
  videos('全部视频'),
  folders('文件夹');

  final String label;
  const _DownloadTab(this.label);
}

enum _DownloadSortAction {
  manual,
  reset,
}

class DownloadPage extends StatefulWidget {
  const DownloadPage({super.key});

  @override
  State<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage>
    with SingleTickerProviderStateMixin {
  final _downloadService = Get.find<DownloadService>();
  final _collectionService = Get.find<DownloadCollectionService>();
  final _controller = Get.put(DownloadPageController());
  final _progress = ChangeNotifier();

  late final TabController _tabController;
  late final RxInt _tabIndex = 0.obs;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _DownloadTab.values.length, vsync: this)
      ..addListener(_handleTabChanged);
  }

  void _handleTabChanged() {
    if (_tabController.indexIsChanging) {
      return;
    }
    _tabIndex.value = _tabController.index;
    if (_tabController.index != 0 && _controller.enableMultiSelect.value) {
      _controller.handleSelect();
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
      title: '新建文件夹',
      initialValue: _collectionService.buildDefaultFolderTitle(),
    );
    if (title == null) {
      return;
    }
    await _collectionService.createFolder(title);
    SmartDialog.showToast('创建成功');
  }

  Future<void> _renameFolder(DownloadFolder folder) async {
    final title = await showDownloadFolderNameDialog(
      context: context,
      title: '重命名文件夹',
      initialValue: folder.title,
    );
    if (title == null || title == folder.title) {
      return;
    }
    await _collectionService.renameFolder(folder.id, title);
    SmartDialog.showToast('重命名成功');
  }

  Future<void> _deleteFolder(DownloadFolder folder) async {
    showConfirmDialog(
      context: context,
      title: const Text('确定删除该文件夹？'),
      content: const Text('只会删除文件夹关联，不会删除本地缓存文件。'),
      onConfirm: () async {
        await _collectionService.deleteFolder(folder.id);
      },
    );
  }

  Future<void> _showFolderActions(DownloadFolder folder) async {
    if (!mounted) {
      return;
    }
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        clipBehavior: Clip.hardEdge,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              dense: true,
              onTap: () {
                Get.back();
                _renameFolder(folder);
              },
              title: const Text('重命名', style: TextStyle(fontSize: 14)),
            ),
            ListTile(
              dense: true,
              onTap: () {
                Get.back();
                _deleteFolder(folder);
              },
              title: Text(
                '删除',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(dialogContext).colorScheme.error,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addSelectedToFolders() async {
    final folderIds = await showDownloadFolderPickerDialog(
      context: context,
      collectionService: _collectionService,
      title: '添加到文件夹',
    );
    if (folderIds == null || folderIds.isEmpty) {
      return;
    }
    await _collectionService.addVideosToFolders(
      _controller.allChecked.map((item) => item.cid),
      folderIds,
    );
    _controller.handleSelect();
    SmartDialog.showToast('已添加到文件夹');
  }

  Future<void> _openAllSortPage() async {
    if (_controller.allVideos.isEmpty) {
      return;
    }
    await Get.to(
      DownloadVideoSortPage(
        title: '排序: 全部视频',
        entries: _controller.allVideos,
        onSave: _collectionService.saveAllVideoOrder,
      ),
    );
  }

  Future<void> _resetAllSort() async {
    await _collectionService.resetAllVideoOrder();
    SmartDialog.showToast('已按缓存时间显示');
  }

  Future<void> _openFolderManagePage() async {
    await Get.to(
      DownloadFolderManagePage(collectionService: _collectionService),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentTab = _DownloadTab.values[_tabIndex.value];
      final isVideoTab = currentTab == _DownloadTab.videos;
      final enableMultiSelect =
          isVideoTab && _controller.enableMultiSelect.value;
      return popScope(
        canPop: !enableMultiSelect,
        onPopInvokedWithResult: (didPop, result) {
          if (enableMultiSelect) {
            _controller.handleSelect();
          }
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: MultiSelectAppBarWidget(
            ctr: _controller,
            visible: enableMultiSelect,
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
                onPressed: () async {
                  final allChecked = _controller.allChecked.toSet();
                  _controller.handleSelect();
                  final res = await Future.wait(
                    allChecked.map(
                      (entry) => _downloadService.downloadDanmaku(
                        entry: entry,
                        isUpdate: true,
                      ),
                    ),
                  );
                  SmartDialog.showToast(
                    res.every((item) => item) ? '更新成功' : '更新失败',
                  );
                },
                child: Text(
                  '更新',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
                onPressed:
                    _controller.checkedCount == 0 ? null : _addSelectedToFolders,
                child: const Text('添加到'),
              ),
            ],
            child: AppBar(
              title: const Text('离线缓存'),
              actions: [
                if (isVideoTab) ...[
                  IconButton(
                    tooltip: '搜索',
                    onPressed: () async {
                      await _downloadService.waitForInitialization;
                      if (!mounted) {
                        return;
                      }
                      Get.to(DownloadSearchPage(progress: _progress));
                    },
                    icon: const Icon(Icons.search),
                  ),
                  IconButton(
                    tooltip: '多选',
                    onPressed: () {
                      if (_controller.enableMultiSelect.value) {
                        _controller.handleSelect();
                      } else {
                        _controller.enableMultiSelect.value = true;
                      }
                    },
                    icon: const Icon(Icons.edit_note),
                  ),
                  PopupMenuButton<_DownloadSortAction>(
                    tooltip: '排序',
                    onSelected: (value) {
                      if (value == _DownloadSortAction.manual) {
                        _openAllSortPage();
                      } else {
                        _resetAllSort();
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: _DownloadSortAction.manual,
                        child: Text('手动排序'),
                      ),
                      PopupMenuItem(
                        value: _DownloadSortAction.reset,
                        child: Text('按缓存时间'),
                      ),
                    ],
                    icon: const Icon(Icons.sort),
                  ),
                ] else ...[
                  IconButton(
                    tooltip: '新建文件夹',
                    onPressed: _createFolder,
                    icon: const Icon(Icons.create_new_folder_outlined),
                  ),
                  IconButton(
                    tooltip: '编辑文件夹',
                    onPressed: _openFolderManagePage,
                    icon: const Icon(Icons.sort),
                  ),
                ],
                const SizedBox(width: 6),
              ],
              bottom: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                tabs: _DownloadTab.values
                    .map((item) => Tab(text: item.label))
                    .toList(),
              ),
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildAllVideosTab(),
              _buildFoldersTab(),
            ],
          ),
        ),
      );
    });
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
            return SliverMainAxisGroup(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.only(left: 12, bottom: 7),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      '正在缓存 (${_downloadService.waitDownloadQueue.length})',
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
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
                ),
              ],
            );
          }),
          Obx(() {
            if (_controller.allVideos.isEmpty) {
              if (_downloadService.waitDownloadQueue.isNotEmpty) {
                return const SliverToBoxAdapter();
              }
              return const SliverFillRemaining(
                hasScrollBody: false,
                child: HttpError(),
              );
            }
            return SliverMainAxisGroup(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.only(
                    left: 12,
                    bottom: 7,
                    top: _downloadService.waitDownloadQueue.isEmpty ? 0 : 7,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Text('全部视频 (${_controller.allVideos.length})'),
                  ),
                ),
                SliverGrid.builder(
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
                        await _downloadService.deleteDownload(
                          entry: entry,
                          removeList: true,
                        );
                        GStorage.watchProgress.delete(entry.cid.toString());
                      },
                      controller: _controller,
                      playContext: const DownloadVideoPlayContext.all(),
                    );
                  },
                ),
              ],
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
                      const Text('还没有文件夹'),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: _createFolder,
                        icon: const Icon(Icons.create_new_folder_outlined),
                        label: const Text('新建文件夹'),
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
                    onTap: () => Get.to(
                      DownloadFolderPage(folderId: folder.id),
                    ),
                    onLongPress: () => _showFolderActions(folder),
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
