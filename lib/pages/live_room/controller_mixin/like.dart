part of 'package:PiliPlus/pages/live_room/controller.dart';

mixin _LiveLikeMixin on GetxController {
  int get roomId;
  int get mid;
  bool get isLogin;
  Rxn<RoomInfoH5Data> get roomInfoH5;

  final RxInt likeClickTime = 0.obs;
  Timer? likeClickTimer;

  void cancelLikeTimer() {
    likeClickTimer?.cancel();
    likeClickTimer = null;
  }

  void onLikeTapDown(_) {
    cancelLikeTimer();
    likeClickTime.value++;
  }

  void onLikeTapUp([_]) {
    likeClickTimer ??= Timer(const Duration(milliseconds: 800), onLike);
  }

  Future<void> onLike() async {
    if (!isLogin) {
      likeClickTime.value = 0;
      return;
    }
    final res = await LiveHttp.liveLikeReport(
      clickTime: likeClickTime.value,
      roomId: roomId,
      uid: mid,
      anchorId: roomInfoH5.value?.roomInfo?.uid,
    );
    if (res.isSuccess) {
      SmartDialog.showToast(uiTx('点赞成功'));
    } else {
      res.toast();
    }
    likeClickTime.value = 0;
  }
}