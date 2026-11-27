part of 'package:PiliPlus/pages/live_room/controller.dart';

mixin _LiveDataMixin on GetxController {
  late int roomId;
  int? ruid;
  DanmakuController<DanmakuExtra>? danmakuController;
  PlPlayerController plPlayerController = PlPlayerController.getInstance(
    isLive: true,
  );

  final isLoaded = false.obs;
  final roomInfoH5 = Rxn<RoomInfoH5Data>();

  int? currentQn = PlatformUtils.isMobile ? null : Pref.liveQuality;
  final currentQnDesc = ''.obs;
  final RxBool isPortrait = false.obs;
  late List<({int code, String desc})> acceptQnList = [];

  late final bool isLogin;
  late final int mid;
  late final Account heartbeat;

  String? videoUrl;
  bool? isPlaying;
  late bool isFullScreen = false;
}