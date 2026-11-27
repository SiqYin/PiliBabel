part of 'package:PiliPlus/pages/live_room/controller.dart';

mixin _LiveMedalMixin on GetxController, _LiveDataMixin {
  final Rxn<FansMedalPanelData> fansMedalData = Rxn();
  final Rxn<UinfoMedal> wearingMedal = Rxn();
  late bool hasMedal = false;
  final medal = Rxn<UinfoMedal>();
  final RxBool fansMedalLoading = false.obs;
  final Rxn<String> fansMedalError = Rxn();
  bool _fansMedalStale = false;
  Future<void>? _fansMedalReq;
  int _fansMedalPage = 1;
  bool _fansMedalLoadingMore = false;
  final RxBool fansMedalHasMore = false.obs;

  Object? get medalTargetId => ruid ?? roomInfoH5.value?.roomInfo?.uid;

  Future<bool> getUserMedal() async {
    if (isClosed) return false;
    final res = await LiveHttp.userMedalInfo(uid: mid, upId: ruid!);
    if (res case Success(:final response)) {
      _handleMedalInfo(response, isInit: true);
      return true;
    }
    return false;
  }

  void _handleMedalInfo(info.Medal response, {bool isInit = false}) {
    hasMedal = response.hasMedal;
    final currShow = response.currShow;
    if (isInit && Pref.autoWearMedal) {
      final lookupV2 = response.lookupV2;
      final currWeared = response.currWearedV2;
      if (lookupV2 != null && lookupV2.ruid != currWeared?.ruid) {
        _autoWearMedal(currShow, lookupV2);
        return;
      }
    }
    medal.value = currShow;
  }

  Future<void> _autoWearMedal(UinfoMedal? currShow, UinfoMedal lookupV2) async {
    var id = lookupV2.id;
    if (id == null || id == 0) {
      final realLookupV2 = (await LiveHttp.userMedalInfo(
        uid: mid,
        upId: ruid!,
      )).dataOrNull?.lookupV2;
      if (isClosed) return;
      id = realLookupV2?.id;
      if (realLookupV2 == null || id == null || id == 0) {
        medal.value = currShow;
        return;
      }
      lookupV2 = realLookupV2;
    }
    final res = await LiveHttp.wearFansMedal(medalId: id);
    if (isClosed) return;
    medal.value = res.isSuccess ? lookupV2 : currShow;
  }

  Future<void> loadFansMedal({bool force = false}) async {
    if (!isLogin) return;
    if (_fansMedalReq != null) return _fansMedalReq;
    if (!force && !_fansMedalStale && fansMedalData.value != null) return;
    final targetId = medalTargetId;
    if (targetId == null) return;

    fansMedalLoading.value = true;
    _fansMedalReq = _doLoadFansMedal(targetId: targetId);
    try {
      await _fansMedalReq;
    } finally {
      fansMedalLoading.value = false;
      _fansMedalReq = null;
    }
  }

  Future<void> _doLoadFansMedal({
    required Object targetId,
  }) async {
    final res = await LiveHttp.fansMedalPanel(
      roomId: roomId,
      targetId: targetId,
      page: 1,
    );
    if (res case Success(:final response)) {
      fansMedalData.value = response;
      _fansMedalPage = 1;
      _updateFansMedalHasMore(response);
      _updateWearingMedal(response);
      _fansMedalStale = false;
      fansMedalError.value = null;
    } else {
      fansMedalError.value = res.toString();
    }
  }

  void _updateFansMedalHasMore(FansMedalPanelData data) {
    final itemCount = (data.specialList?.length ?? 0) + (data.list?.length ?? 0);
    fansMedalHasMore.value = _calcHasMore(data, itemCount);
  }

  bool _calcHasMore(FansMedalPanelData data, int loadedCount) {
    if (data.hasMore != true) return false;
    if (data.nextPage == null || data.nextPage! <= _fansMedalPage) return false;
    if (data.totalNumber != null && loadedCount >= data.totalNumber!) {
      return false;
    }
    if (_fansMedalPage >= 20) return false;
    return true;
  }

  void _updateWearingMedal(FansMedalPanelData data) {
    final allItems = [
      ...?data.specialList,
      ...?data.list,
    ];
    final wearing = allItems.cast<FansMedalItem?>().firstWhere(
      (item) => item?.medal?.wearingStatus == 1,
      orElse: () => null,
    );
    wearingMedal.value = wearing?.uinfoMedal;
  }

  void markFansMedalStale() {
    _fansMedalStale = true;
  }

  Future<void> loadMoreFansMedal() async {
    if (_fansMedalLoadingMore) return;
    if (_fansMedalReq != null) return;
    if (!fansMedalHasMore.value) return;
    final targetId = medalTargetId;
    if (targetId == null) return;

    _fansMedalLoadingMore = true;
    final nextPage = _fansMedalPage + 1;
    final res = await LiveHttp.fansMedalPanel(
      roomId: roomId,
      targetId: targetId,
      page: nextPage,
    );
    if (res case Success(:final response)) {
      final data = fansMedalData.value;
      if (data != null) {
        final existingIds = <int>{};
        for (final item in [...?data.specialList, ...?data.list]) {
          if (item.medal?.medalId case final id?) existingIds.add(id);
        }
        final newList = <FansMedalItem>[];
        for (final item in (response.list ?? <FansMedalItem>[])) {
          if (item.medal?.medalId case final id?) {
            if (!existingIds.contains(id)) {
              newList.add(item);
              existingIds.add(id);
            }
          } else {
            newList.add(item);
          }
        }
        if (newList.isEmpty) {
          fansMedalHasMore.value = false;
          _fansMedalLoadingMore = false;
          return;
        }
        data
          ..list = [...?data.list, ...newList]
          ..hasMore = response.hasMore
          ..nextPage = response.nextPage;
        _fansMedalPage = nextPage;
        final itemCount = (data.specialList?.length ?? 0) +
            (data.list?.length ?? 0);
        fansMedalHasMore.value = _calcHasMore(data, itemCount);
        fansMedalData.refresh();
      }
    } else {
      res.toast();
    }
    _fansMedalLoadingMore = false;
  }

  Future<bool> wearFansMedal(FansMedalItem item) async {
    final targetId = medalTargetId;
    if (targetId == null) return false;
    final medalId = item.medal?.medalId;
    if (medalId == null) return false;

    final res = await LiveHttp.fansMedalWear(
      medalId: medalId,
      targetId: targetId,
    );
    if (res.isSuccess) {
      _applyWearStatus(medalId, 1);
      wearingMedal.value = item.uinfoMedal;
      _fansMedalStale = true;
      SmartDialog.showToast(uiTxP('已佩戴 {0}', [item.medal?.medalName ?? '']));
      return true;
    } else {
      res.toast();
      return false;
    }
  }

  Future<bool> takeOffFansMedal(FansMedalItem item) async {
    final targetId = medalTargetId;
    if (targetId == null) return false;
    final medalId = item.medal?.medalId;
    if (medalId == null) return false;

    final res = await LiveHttp.fansMedalTakeOff(
      medalId: medalId,
      targetId: targetId,
    );
    if (res.isSuccess) {
      _applyWearStatus(medalId, 0);
      wearingMedal.value = null;
      _fansMedalStale = true;
      SmartDialog.showToast(uiTx('已取消佩戴'));
      return true;
    } else {
      res.toast();
      return false;
    }
  }

  void _applyWearStatus(int medalId, int status) {
    final data = fansMedalData.value;
    if (data == null) return;
    for (final item in [...?data.specialList, ...?data.list]) {
      if (item.medal?.medalId == medalId) {
        item.medal?.wearingStatus = status;
      } else {
        item.medal?.wearingStatus = 0;
      }
    }
    fansMedalData.refresh();
  }
}