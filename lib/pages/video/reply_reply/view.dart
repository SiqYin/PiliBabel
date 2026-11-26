import 'package:PiliPlus/services/ui_translate/ui_translate_service.dart';
import 'package:PiliPlus/common/skeleton/video_reply.dart';
import 'package:PiliPlus/common/sliver_single_child_delegate.dart';
import 'package:PiliPlus/common/style.dart';
import 'package:PiliPlus/common/widgets/colored_box_transition.dart';
import 'package:PiliPlus/common/widgets/dialog/dialog.dart';
import 'package:PiliPlus/common/widgets/flutter/refresh_indicator.dart';
import 'package:PiliPlus/common/widgets/loading_widget/http_error.dart';
import 'package:PiliPlus/common/widgets/scaffold/mini_scaffold.dart';
import 'package:PiliPlus/common/widgets/scaffold/simple_scaffold.dart';
import 'package:PiliPlus/common/widgets/simple_colored_box.dart';
import 'package:PiliPlus/common/widgets/sliver/sliver_pinned_header.dart';
import 'package:PiliPlus/common/widgets/view_safe_area.dart';
import 'package:PiliPlus/grpc/bilibili/main/community/reply/v1.pb.dart'
    show ReplyInfo;
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/pages/common/slide/common_slide_page.dart';
import 'package:PiliPlus/pages/video/reply/widgets/reply_item_grpc.dart';
import 'package:PiliPlus/pages/video/reply_reply/controller.dart';
import 'package:PiliPlus/pages/video/reply_reply/tree.dart';
import 'package:PiliPlus/utils/app_scheme.dart';
import 'package:PiliPlus/utils/extension/widget_ext.dart';
import 'package:PiliPlus/utils/num_utils.dart';
import 'package:PiliPlus/utils/parse_string.dart';
import 'package:PiliPlus/utils/utils.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:fixnum/fixnum.dart' show Int64;
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:material_ui/material_ui.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

class VideoReplyReplyPanel extends CommonSlidePage {
  const VideoReplyReplyPanel({
    super.key,
    super.enableSlide,
    this.id,
    required this.oid,
    required this.rpid,
    this.dialog,
    this.firstFloor,
    required this.isVideoDetail,
    required this.replyType,
    this.isNested = false,
    this.heroTag,
    this.upMid,
  });
  final int? id;
  final int oid;
  final int rpid;
  final int? dialog;
  final ReplyInfo? firstFloor;
  final bool isVideoDetail;
  final int replyType;
  final bool isNested;
  final String? heroTag;
  final Int64? upMid;

  @override
  State<VideoReplyReplyPanel> createState() => _VideoReplyReplyPanelState();

  static Future<void>? toReply({
    required int oid,
    required int rootId,
    String? rpIdStr,
    required int type,
    String? heroTag,
    Uri? uri,
  }) {
    final rpId = parseIntOrNull(rpIdStr);
    return Get.to(
      arguments: {
        'oid': oid,
        'rpid': rootId,
        'id': ?rpId,
        'type': type,
        'heroTag': heroTag,
        'enterUri': ?uri?.toString(), // save panel
      },
      () => SimpleScaffold(
        appBar: AppBar(
          title: Text(uiTx('评论详情')),
          actions: [
            IconButton(
              tooltip: uiTx('前往'),
              onPressed: uri == null
                  ? null
                  : () => PiliScheme.routePush(uri, businessId: type),
              icon: const Icon(Icons.open_in_browser),
            ),
          ],
        ),
        body: ViewSafeArea(
          child: VideoReplyReplyPanel(
            enableSlide: false,
            oid: oid,
            rpid: rootId,
            isVideoDetail: false,
            replyType: type,
            firstFloor: null,
            id: rpId,
            heroTag: heroTag,
          ),
        ).constraintWidth(),
      ),
    );
  }
}

class _VideoReplyReplyPanelState extends State<VideoReplyReplyPanel>
    with SingleTickerProviderStateMixin, CommonSlideMixin {
  late VideoReplyReplyController _controller;
  late final _tag = Utils.makeHeroTag('${widget.rpid}${widget.dialog}');
  Animation<Color?>? _colorAnimation;

  late final bool isDialogue = widget.dialog != null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _colorAnimation = null;
    final controller = PrimaryScrollController.of(context);
    _controller
      ..didChangeDependencies(context)
      ..nestedController = controller is ExtendedNestedScrollController
          ? controller
          : null;
  }

  @override
  void initState() {
    super.initState();
    _controller = Get.put(
      VideoReplyReplyController(
        hasRoot: widget.firstFloor != null,
        id: widget.id,
        oid: widget.oid,
        rpid: widget.rpid,
        dialog: widget.dialog,
        replyType: widget.replyType,
      ),
      tag: _tag,
    );
  }

  @override
  void dispose() {
    Get.delete<VideoReplyReplyController>(tag: _tag);
    super.dispose();
  }

  @override
  Widget buildPage(ThemeData theme) {
    Widget child() => enableSlide ? slideList(theme) : buildList(theme);
    return SimpleColoredBox(
      color: theme.canvasColor,
      child: MiniScaffold(
        body: widget.isVideoDetail
            ? Column(
                children: [
                  Container(
                    height: 45,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          width: 1,
                          color: theme.dividerColor.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.only(left: 12, right: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(isDialogue ? uiTx('对话列表') : uiTx('评论详情')),
                        IconButton(
                          tooltip: uiTx('关闭'),
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: Get.back,
                        ),
                      ],
                    ),
                  ),
                  Expanded(child: child()),
                ],
              )
            : child(),
      ),
    );
  }

  ReplyInfo? get firstFloor =>
      widget.firstFloor ?? _controller.firstFloor.value;

  ScrollController get scrollController =>
      _controller.nestedController ?? _controller.scrollController;

  @override
  Widget buildList(ThemeData theme) {
    return refreshIndicator(
      onRefresh: _controller.onRefresh,
      isClampingScrollPhysics: widget.isNested,
      child: CustomScrollView(
        key: ValueKey(scrollController.hashCode),
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          if (!isDialogue) ...[
            if ((widget.firstFloor ?? _controller.firstFloor.value)
                case final firstFloor?)
              _header(theme, firstFloor)
            else
              Obx(() {
                final firstFloor = _controller.firstFloor.value;
                if (firstFloor == null) {
                  return const SliverToBoxAdapter();
                }
                return _header(theme, firstFloor);
              }),
            _sortWidget(theme.colorScheme),
          ],
          Obx(
            () => _buildBody(theme.colorScheme, _controller.loadingState.value),
          ),
        ],
      ),
    );
  }

  Widget _header(ThemeData theme, ReplyInfo firstFloor) {
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: ReplyItemGrpc(
            replyItem: firstFloor,
            replyLevel: 2,
            needDivider: false,
            onReply: (replyItem) => _controller.onReply(replyItem, index: -1),
            upMid: widget.upMid ?? _controller.upMid,
            getTag: () => widget.heroTag,
            onCheckReply: (item) =>
                _controller.onCheckReply(item, isManual: true),
          ),
        ),
        SliverToBoxAdapter(
          child: Divider(
            height: 20,
            color: theme.dividerColor.withValues(alpha: 0.1),
            thickness: 6,
          ),
        ),
      ],
    );
  }

  Widget _sortWidget(ColorScheme colorScheme) {
    return SliverPinnedHeader(
      backgroundColor: colorScheme.surface,
      child: Padding(
        padding: const .fromLTRB(12, 2.5, 6, 2.5),
        child: Row(
          mainAxisAlignment: .spaceBetween,
          children: [
            Obx(
              () {
                final count = _controller.count.value;
                return count != -1
                    ? Text(uiTx('相关回复共${NumUtils.numFormat(count)}条'),
                        style: const TextStyle(fontSize: 13),
                      )
                    : const SizedBox.shrink();
              },
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Obx(
                  () => _controller.replyTree.value == null
                      ? IconButton(
                          visualDensity: VisualDensity.compact,
                          onPressed: () {
                            if (_controller.isEnd) {
                              _controller.buildTree();
                            } else {
                              showConfirmDialog(
                                context: context,
                                title: Text(uiTx('是否加载全部评论以显示线程化评论？')),
                                content: Text(
                                  uiTx('这将消耗一定流量\n且可能导致IP或账号风控'),
                                ),
                                onConfirm: _loadAllForTree,
                              );
                            }
                          },
                          icon: const Icon(
                            Icons.view_comfortable_outlined,
                            size: 22,
                          ),
                          color: colorScheme.outline,
                          tooltip: uiTx('线程化展示'),
                        )
                      : const SizedBox.shrink(),
                ),
                TextButton.icon(
                  style: Style.buttonStyle,
                  onPressed: _controller.queryBySort,
                  icon: Icon(Icons.sort, size: 16, color: colorScheme.secondary),
                  label: Obx(
                    () => Text(uiTx(_controller.sortType.value.label),
                      style: TextStyle(fontSize: 13, color: colorScheme.secondary),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
    ColorScheme colorScheme,
    LoadingState<List<ReplyInfo>?> loadingState,
  ) {

    return switch (loadingState) {
      Loading() => const SliverPrototypeExtentList(
        prototypeItem: VideoReplySkeleton(),
        delegate: SliverSingleChildDelegate(
          count: 8,
          child: VideoReplySkeleton(),
        ),
      ),
      Success(:final response!) =>
        _controller.replyTree.value == null
            ? _buildFlat(response, colorScheme)
            : _buildTree(_controller.replyTree.value!, colorScheme),
      Error(:final errMsg) => HttpError(
        errMsg: errMsg,
        onReload: _controller.onReload,
      ),
    };
  }

  Widget _buildFlat(List<ReplyInfo> response, ColorScheme colorScheme) {
    final jumpIndex = _controller.index.value;
    return SuperSliverList.builder(
      listController: _controller.listController,
      itemBuilder: (context, index) {
        if (index == response.length) {
          _controller.onLoadMore();
          return _buildFooter(context, colorScheme);
        }
        final child = _replyItem(context, response[index], index);
        return jumpIndex == index ? _jumpWrapper(colorScheme, child) : child;
      },
      itemCount: response.length + 1,
    );
  }

  Widget _buildTree(ReplyTree tree, ColorScheme colorScheme) {
    final jumpIndex = _controller.index.value;
    return SuperSliverList.builder(
      listController: _controller.listController,
      itemCount: tree.length + 1,
      itemBuilder: (context, index) {
        if (index == tree.length) {
          return _buildFooter(context, colorScheme);
        }
        final node = tree[index];
        final child = Padding(
          padding: EdgeInsets.only(left: node.depth * 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!node.isLeaf)
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: () => _controller.toggleCollapseTree(index),
                    icon: Icon(
                      node.collapsed > 0 ? Icons.add : Icons.remove,
                      size: 16,
                    ),
                  ),
                ),
              _replyItem(context, node.reply, index),
            ],
          ),
        );
        return jumpIndex == index ? _jumpWrapper(colorScheme, child) : child;
      },
    );
  }

  Widget _buildFooter(BuildContext context, ColorScheme colorScheme) {
    return Container(
      height: 125,
      alignment: Alignment.center,
      margin: .only(bottom: MediaQuery.viewPaddingOf(context).bottom),
      child: Text(
        uiTx(_controller.isEnd ? '没有更多了' : '加载中...'),
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 12, color: colorScheme.outline),
      ),
    );
  }

  Widget _jumpWrapper(ColorScheme colorScheme, Widget child) {
    return ColoredBoxTransition(
      color: _colorAnimation ??= _controller.animController.drive(
        ColorTween(
          begin: colorScheme.onInverseSurface,
          end: colorScheme.surface,
        ).chain(CurveTween(curve: const Interval(0.8, 1.0))),
      ),
      child: child,
    );
  }

  Future<void> _loadAllForTree() async {
    SmartDialog.showLoading(msg: uiTx('正在加载全部评论…'));
    try {
      var guard = 0;
      while (!_controller.isEnd && guard++ < 50) {
        _controller.onLoadMore();
        await Future<void>.delayed(const Duration(milliseconds: 600));
      }
      _controller.buildTree();
    } finally {
      SmartDialog.dismiss();
    }
  }

  Widget _replyItem(BuildContext context, ReplyInfo replyItem, int index) {
    return ReplyItemGrpc(
      replyItem: replyItem,
      replyLevel: isDialogue ? 3 : 2,
      onReply: (replyItem) => _controller.onReply(replyItem, index: index),
      onDelete: (item, subIndex) => _controller.onRemove(index, item, null),
      upMid: _controller.upMid,
      showDialogue: () => MiniScaffold.of(context).showBottomSheet(
        constraints: const BoxConstraints(),
        (context) => VideoReplyReplyPanel(
          oid: replyItem.oid.toInt(),
          rpid: replyItem.root.toInt(),
          dialog: replyItem.dialog.toInt(),
          replyType: widget.replyType,
          isVideoDetail: true,
          isNested: widget.isNested,
          heroTag: widget.heroTag,
        ),
      ),
      jumpToDialogue: () {
        if (!_controller.setIndexById(replyItem.parent)) {
          SmartDialog.showToast(uiTx('评论可能已被删除'));
        }
      },
      onCheckReply: (item) => _controller.onCheckReply(item, isManual: true),
      getTag: () => widget.heroTag,
    );
  }
}
