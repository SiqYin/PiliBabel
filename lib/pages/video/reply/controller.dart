import 'package:PiliPlus/grpc/bilibili/main/community/reply/v1.pb.dart'
    show MainListReply, ReplyInfo;
import 'package:PiliPlus/grpc/reply.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/common/video/video_type.dart';
import 'package:PiliPlus/pages/common/reply_controller.dart';
import 'package:PiliPlus/pages/video/controller.dart';
import 'package:PiliPlus/pages/video/reply/vote/reply_vote_mixin.dart';
import 'package:PiliPlus/utils/id_utils.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:get/get.dart';
import 'package:PiliPlus/services/ui_translate/ui_translate_service.dart';

class VideoReplyController extends ReplyController<MainListReply>
    with ReplyVoteMixin {
  VideoReplyController({
    required this.aid,
    required this.videoType,
    required this.heroTag,
  });
  int aid;
  final VideoType videoType;
  late final isPugv = videoType == VideoType.pugv;

  final String heroTag;
  late final videoCtr = Get.find<VideoDetailController>(tag: heroTag);

  // 是否正在进入应用内小窗
  bool isEnteringPip = false;

  @override
  dynamic get sourceId => IdUtils.av2bv(aid);

  @override
  List<ReplyInfo>? getDataList(MainListReply response) {
    return response.replies;
  }

  @override
  Future<LoadingState<MainListReply>> customGetData() async {
    // aid 是建控制器那一刻的快照。只有 bvid 的入口（分享链、外链跳转）此时
    // 详情还没回来，aid 还是 0；拿 0 去请求评论会被服务端直接判 -400 invalid oid，
    // 于是评论区永远停在「点击重试」，点重试还是同一个 0。
    // 这里每次都取一次详情控制器的实时值兜底，oid 仍非法就明确报错，不再白跑一趟。
    final liveAid = aid > 0 ? aid : videoCtr.aid;
    final oid = isPugv ? (videoCtr.epId ?? 0) : liveAid;
    if (oid <= 0) {
      return Error(await UiTranslateService.to.txAsync('评论加载失败：视频信息还没准备好'));
    }
    // D1：首屏命中评论预取就直接用，不再等一次完整往返
    final cached = await prefetchedFirstPage(oid, videoType.replyType);
    if (cached != null) {
      return cached;
    }
    return ReplyGrpc.mainList(
      oid: oid,
      type: videoType.replyType,
      mode: mode,
      cursorNext: cursorNext,
      offset: paginationReply?.nextOffset,
    );
  }

  @override
  void onClose() {
    if (kDebugMode) {
      print(
        '[PiliNara] VideoReplyController onClose called, isEnteringPip: $isEnteringPip',
      );
    }
    if (isEnteringPip) {
      return;
    }
    super.onClose();
  }
}
