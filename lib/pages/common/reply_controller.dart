import 'dart:async';

import 'package:PiliPlus/common/widgets/flutter/text_field/controller.dart';
import 'package:PiliPlus/grpc/bilibili/main/community/reply/v1.pb.dart'
    show MainListReply, ReplyInfo, SubjectControl, Mode;
import 'package:PiliPlus/grpc/bilibili/pagination.pb.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/reply.dart';
import 'package:PiliPlus/models/common/reply/reply_sort_type.dart';
import 'package:PiliPlus/pages/common/common_list_controller.dart';
import 'package:PiliPlus/pages/common/publish/publish_route.dart';
import 'package:PiliPlus/pages/video/reply_new/view.dart';
import 'package:PiliPlus/services/ui_translate/ui_translate_service.dart';
import 'package:PiliPlus/utils/connectivity_utils.dart';
import 'package:PiliPlus/utils/reply_prefetch.dart';
import 'package:PiliPlus/utils/feed_back.dart';
import 'package:PiliPlus/utils/reply_utils.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:material_ui/material_ui.dart';

abstract class ReplyController<R> extends CommonListController<R, ReplyInfo> {
  ReplyController({int count = -1}) : count = RxInt(count);

  late final RxInt count;

  late final Rx<ReplySortType> sortType;
  late Mode mode;

  final savedReplies = <Object, List<RichTextItem>?>{};

  Int64? upMid;
  Int64? cursorNext;
  SubjectControl? subjectControl;
  FeedPaginationReply? paginationReply;
  late bool hasUpTop = false;

  @override
  bool? get hasFooter => true;

  // comment antifraud
  late final _enableCommAntifraud = Pref.enableCommAntifraud;
  late final _biliSendCommAntifraud = Pref.biliSendCommAntifraud;
  bool get enableCommAntifraud =>
      _enableCommAntifraud || _biliSendCommAntifraud;
  dynamic get sourceId;

  /// D2.1 分页预取深度：WiFi 更深（6 项）、蜂窝更浅（2 项），
  /// 与蜂窝降采样一致，避免在流量网络上多拉一页评论。
  int prefetchDepth = 2;

  @override
  void onInit() {
    super.onInit();
    final cacheSortType = Pref.replySortType;
    sortType = cacheSortType.obs;
    mode = cacheSortType == .time ? Mode.MAIN_LIST_TIME : Mode.MAIN_LIST_HOT;
    ConnectivityUtils.isWiFi.then((isWiFi) {
      prefetchDepth = isWiFi ? 6 : 2;
    });
  }

  /// D1 首屏评论预取命中：命中返回预取结果，没命中返回 null。
  /// 子类在 customGetData 里先调它，把 [oid] 与 [type] 传进来。
  Future<LoadingState<R>?> prefetchedFirstPage(int oid, int type) async {
    if (cursorNext != null || paginationReply != null) {
      return null;
    }
    final cached = await ReplyPrefetch.takeFirstPage(
      oid: oid,
      type: type,
      mode: mode,
    );
    if (cached == null) {
      return null;
    }
    // 这里以前是 `Success(cached) as LoadingState<R>`：cached 的静态类型是
    // MainListReply?，构造出来的是 Success<MainListReply?>，运行期转不成
    // LoadingState<MainListReply>，于是拿到预取结果的瞬间抛类型错误——
    // 表现就是评论区「秒失败」，而且重试每次命中同一个缓存、每次都秒失败。
    // 类型对不上就当没命中，退回正常请求，绝不抛错。
    // 不能写成 `Success<R>(cached)`：cached 的静态类型是 MainListReply?，而 R 是
    // 子类声明的类型参数，Dart 不会把 MainListReply? 提升成 R（R 的上界是 Object?，
    // 不满足 `is` 提升要求 T <: S），于是这一行在 kernel_snapshot 阶段编译不过，
    // v3.3.3 的 APK 就是死在这里。先装进 Object? 再判类型，此时 R <: Object? 成立，
    // 提升可以正常发生。
    final Object? boxed = cached;
    if (boxed is! R) {
      return null;
    }
    return Success<R>(boxed);
  }

  @override
  void checkIsEnd(int length) {
    final count = this.count.value;
    if (count != -1 && length >= count) {
      isEnd = true;
    }
  }

  @override
  bool customHandleResponse(bool isRefresh, Success<R> response) {
    final data = response.response as MainListReply;
    cursorNext = data.cursor.next;
    paginationReply = data.paginationReply;
    count.value = data.subjectControl.count.toInt();
    if (isRefresh) {
      subjectControl = data.subjectControl;
      upMid = data.subjectControl.upMid;
      if (hasUpTop = data.hasUpTop()) {
        data.replies.insert(0, data.upTop);
      }
      if (subjectControl?.title == ReplySortType.select.desc) {
        sortType.value = .select;
      }
    }
    isEnd = data.cursor.isEnd;
    return false;
  }

  @override
  bool handleError(String? errMsg) {
    // D3.2 刷新失败保留上次数据，并给一条能被 AI 翻译的提示。
    // 不用服务端/网络层的原始错误串：那常常是给开发者看的英文或堆栈片段，
    // 用户看不懂，也翻译不了。
    if (loadingState.value case Success(:final response)) {
      if (response == null || response.isEmpty) {
        return false;
      }
      unawaited(_toastKeepLastData());
      return true;
    }
    return false;
  }

  Future<void> _toastKeepLastData() async {
    SmartDialog.showToast(
      await UiTranslateService.to.txAsync('评论刷新失败，已保留上次内容'),
    );
  }

  @override
  Future<void> onRefresh() {
    cursorNext = null;
    subjectControl = null;
    paginationReply = null;
    return super.onRefresh();
  }

  // 排序搜索评论
  void queryBySort() {
    if (isLoading) return;
    switch (sortType.value) {
      case ReplySortType.time:
        sortType.value = ReplySortType.hot;
        mode = Mode.MAIN_LIST_HOT;
        break;
      case ReplySortType.hot:
        sortType.value = ReplySortType.time;
        mode = Mode.MAIN_LIST_TIME;
        break;
      case ReplySortType.select:
        return;
    }
    feedBack();
    onReload();
  }

  (bool inputDisable, String? hint) get replyHint {
    String? hint;
    bool inputDisable = false;
    try {
      if (subjectControl case final subjectControl?) {
        inputDisable = subjectControl.inputDisable;
        if (subjectControl.hasRootText()) {
          final rootText = subjectControl.rootText;
          if (inputDisable) {
            SmartDialog.showToast(rootText);
          }
          if (rootText.contains('可发') || rootText.contains('可见')) {
            hint = rootText;
          }
        }
      }
    } catch (_) {}
    return (inputDisable, hint);
  }

  void onReply(
    ReplyInfo? replyItem, {
    int? oid,
    int? replyType,
  }) {
    if (loadingState.value case Error(:final errMsg, :final code)) {
      if (errMsg != null && (code == 12061 || code == 12002)) {
        SmartDialog.showToast(errMsg);
        return;
      }
    }

    assert(replyItem != null || (oid != null && replyType != null));

    final (bool inputDisable, String? hint) = replyHint;
    if (inputDisable) {
      return;
    }

    final key = oid ?? replyItem!.oid + replyItem.id;
    Get.key.currentState!
        .push(
          PublishRoute(
            pageBuilder: (buildContext, animation, secondaryAnimation) {
              return ReplyPage(
                hint: hint,
                oid: oid ?? replyItem!.oid.toInt(),
                root: oid != null ? 0 : replyItem!.id.toInt(),
                parent: oid != null ? 0 : replyItem!.id.toInt(),
                replyType: replyItem?.type.toInt() ?? replyType!,
                replyItem: replyItem,
                items: savedReplies[key],

                /// hd api deprecated
                // canUploadPic: canUploadPic,
                onSave: (reply) {
                  if (reply.isEmpty) {
                    savedReplies.remove(key);
                  } else {
                    savedReplies[key] = reply.toList();
                  }
                },
              );
            },
            settings: RouteSettings(arguments: Get.arguments),
          ),
        )
        .then(
          (replyInfo) {
            if (replyInfo is ReplyInfo) {
              savedReplies.remove(key);
              if (loadingState.value case Success(:final response)) {
                if (response == null) {
                  loadingState.value = Success([replyInfo]);
                } else {
                  if (oid != null) {
                    response.insert(hasUpTop ? 1 : 0, replyInfo);
                  } else {
                    replyItem!
                      ..count += 1
                      ..replies.add(replyInfo);
                  }
                  loadingState.refresh();
                }
              } else {
                loadingState.value = Success([replyInfo]);
              }
              count.value += 1;

              // check reply
              if (enableCommAntifraud) {
                onCheckReply(replyInfo, isManual: false);
              }
            }
          },
        );
  }

  void onRemove(int index, ReplyInfo item, int? subIndex) {
    if (subIndex == null) {
      loadingState.value.data!.removeAt(index);
    } else {
      item
        ..count -= 1
        ..replies.removeAt(subIndex);
    }
    count.value -= 1;
    loadingState.refresh();
  }

  void onCheckReply(ReplyInfo replyInfo, {bool isManual = true}) {
    ReplyUtils.onCheckReply(
      replyInfo: replyInfo,
      biliSendCommAntifraud: _biliSendCommAntifraud,
      sourceId: sourceId,
      isManual: isManual,
    );
  }

  Future<void> onToggleTop(
    ReplyInfo item,
    int index,
    oid,
    int type,
  ) async {
    bool isUpTop = item.replyControl.isUpTop;
    final res = await ReplyHttp.replyTop(
      oid: oid,
      type: type,
      rpid: item.id,
      isUpTop: isUpTop,
    );
    if (res.isSuccess) {
      item.replyControl.isUpTop = !isUpTop;
      if (!isUpTop && index != 0) {
        final list = loadingState.value.data!;
        list
          ..first.replyControl.isUpTop = false
          ..insert(0, list.removeAt(index));
      }
      loadingState.refresh();
      SmartDialog.showToast('${isUpTop ? '取消' : ''}置顶成功');
    } else {
      res.toast();
    }
  }

  @override
  void onClose() {
    savedReplies.clear();
    super.onClose();
  }
}
