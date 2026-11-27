part of 'package:PiliPlus/pages/live_room/controller.dart';

mixin _LiveBlockMixin on GetxController {
  int get roomId;
  Account get heartbeat;
  late final List<String> _keywordList = [];
  late final Set<int> _shieldUids = {};

  Future<void> _fetchBlockRules() async {
    final res = await LiveHttp.getLiveInfoByUser(roomId);
    if (res case Success()) {
      if (!heartbeat.isLogin) return;
      final shieldInfo = res.dataOrNull?.shieldInfo;
      if (shieldInfo == null) return;
      if (shieldInfo.keywordList case final keywordList?) {
        _keywordList.assignAll(keywordList);
      }
      if (shieldInfo.shieldUserList case final shieldUserList?) {
        _shieldUids.assignAll(shieldUserList.map((e) => e.uid));
      }
    }
  }

  void updateBlockRules(List<String> keywords, Iterable<int> uids) {
    _keywordList.assignAll(keywords);
    _shieldUids.assignAll(uids);
  }

  bool isBlocked(String text, Object uid) {
    return _keywordList.any(text.contains) || _shieldUids.contains(uid);
  }
}
