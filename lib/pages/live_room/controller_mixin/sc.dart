part of 'package:PiliPlus/pages/live_room/controller.dart';

mixin _LiveScMixin on GetxController {
  int get roomId;
  bool get isLogin;
  bool get isFullScreen;
  PlPlayerController get plPlayerController;
  void addDm(dynamic msg, [DanmakuContentItem<DanmakuExtra>? item]);
  void toastNotLogin();

  late final fsSC = Rxn<SuperChatItem>();
  late final RxList<SuperChatItem> superChatMsg = <SuperChatItem>[].obs;
  final superChatType = Pref.superChatType;
  late final showSuperChat = superChatType != SuperChatType.disable;
  final superChatTimeType = Pref.superChatTimeType;

  Future<void> getSuperChatMsg() async {
    final res = await LiveHttp.superChatMsg(roomId);
    if (res.dataOrNull?.list case final list? when list.isNotEmpty) {
      superChatMsg.addAll(list);
    }
  }

  void clearSC() {
    superChatMsg.removeWhere((e) => e.expired);
  }

  void handleSuperChatMessage(dynamic data) {
    final item = SuperChatItem.fromJson(data);
    superChatMsg.insert(0, item);
    if (plPlayerController.showDanmaku &&
        (isFullScreen || plPlayerController.isDesktopPip)) {
      fsSC.value = item.copyWith(
        endTime: math.min(
          item.endTime,
          DateTime.now().millisecondsSinceEpoch ~/ 1000 + 10,
        ),
      );
    }
    addDm(item);
  }

  void reportSC(SuperChatItem item) {
    if (!isLogin) {
      toastNotLogin();
      return;
    }
    autoWrapReportDialog(
      Get.context!,
      ban: false,
      ReportOptions.liveDanmakuReport,
      withContent: ReportOptions.liveDanmakuReportCheck,
      contentRequired: ReportOptions.liveDanmakuReportCheck,
      (reasonType, reasonDesc, banUid) {
        return LiveHttp.superChatReport(
          id: item.id,
          roomId: roomId,
          uid: item.uid,
          msg: item.message,
          reason: ReportOptions.liveDanmakuReport['']![reasonType]!,
          ts: item.ts,
          token: item.token,
        );
      },
    );
  }
}