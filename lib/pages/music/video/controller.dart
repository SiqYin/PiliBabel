import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/music.dart';
import 'package:PiliPlus/models_new/music/bgm_detail.dart';
import 'package:PiliPlus/models_new/music/bgm_recommend_list.dart';
import 'package:PiliPlus/pages/common/common_list_controller.dart';
import 'package:PiliPlus/services/ui_translate/ui_translate_service.dart';
import 'package:PiliPlus/utils/zh_search_compat.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

typedef MusicRecommendArgs = ({String id, MusicDetail item});

class MusicRecommendController
    extends CommonListController<List<BgmRecommend>?, BgmRecommend> {
  late final String musicId;
  late final MusicDetail musicDetail;

  final Rx<MusicRecommendOrderType> order =
      MusicRecommendOrderType.defaultOrder.obs;
  List<BgmRecommend>? originalList;

  final isSearchMode = false.obs;
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();

  @override
  void onInit() {
    super.onInit();
    final MusicRecommendArgs args = Get.arguments;
    musicId = args.id;
    musicDetail = args.item;
    searchController.addListener(_onSearchChanged);
    queryData();
  }

  /// 回译候选词（列表显示的是译文标题，用户照着看到的字打）。
  /// translateQuery 内部有缓存与并发去重，算完重算一次过滤即可。
  String? _translatedCandidate;
  String? _translatedFor;

  void _onSearchChanged() {
    applySortAndFilter();
    _resolveTranslatedCandidate();
  }

  Future<void> _resolveTranslatedCandidate() async {
    final raw = searchController.text.trim();
    if (raw.isEmpty || !Get.isRegistered<UiTranslateService>()) return;
    final translated = await UiTranslateService.to.translateQuery(raw);
    if (translated == null ||
        translated.isEmpty ||
        searchController.text.trim() != raw) {
      return;
    }
    _translatedCandidate = translated;
    _translatedFor = raw;
    applySortAndFilter();
  }

  @override
  void onClose() {
    searchController.dispose();
    searchFocusNode.dispose();
    super.onClose();
  }

  @override
  void checkIsEnd(int length) {
    isEnd = true;
  }

  @override
  Future<LoadingState<List<BgmRecommend>?>> customGetData() =>
      MusicHttp.bgmRecommend(musicId);

  @override
  bool customHandleResponse(
      bool isRefresh, Success<List<BgmRecommend>?> response) {
    if (response.response != null) {
      originalList = List.from(response.response!);
      isEnd = true;
      applySortAndFilter();
    } else {
      loadingState.value = const Success(null);
    }
    return true;
  }

  void applySortAndFilter() {
    if (originalList == null) return;
    
    List<BgmRecommend> filtered = originalList!;
    final keyword = searchController.text.trim();
    if (keyword.isNotEmpty) {
      // 候选词：原词 + 界面语言→中文的回译；命中带简繁归一。
      final candidates = <String>{keyword};
      if (_translatedFor == keyword && _translatedCandidate != null) {
        candidates.add(_translatedCandidate!);
      }
      filtered = filtered
          .where(
            (item) => candidates.any(
              (text) =>
                  zhCompatContains(item.title ?? '', text) ||
                  zhCompatContains(item.upNickName ?? '', text),
            ),
          )
          .toList();
    }
    
    if (order.value != MusicRecommendOrderType.defaultOrder) {
      filtered = List.from(filtered);
      filtered.sort((a, b) {
        switch (order.value) {
          case MusicRecommendOrderType.play:
            return (b.play ?? 0).compareTo(a.play ?? 0);
          case MusicRecommendOrderType.danmu:
            return (b.danmu ?? 0).compareTo(a.danmu ?? 0);
          case MusicRecommendOrderType.duration:
            return (b.duration ?? 0).compareTo(a.duration ?? 0);
          case MusicRecommendOrderType.defaultOrder:
            return 0;
        }
      });
    }
    
    loadingState.value = Success(filtered);
  }
}
