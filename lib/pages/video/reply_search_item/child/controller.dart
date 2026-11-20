import 'package:PiliPlus/grpc/bilibili/main/community/reply/v1.pb.dart'
    show
        SearchItemReply,
        SearchItem,
        SearchItem_Item,
        SearchItemType,
        VideoSearchItem_VideoItem;
import 'package:PiliPlus/grpc/reply.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/common/reply/reply_search_type.dart';
import 'package:PiliPlus/pages/common/common_list_controller.dart';
import 'package:PiliPlus/pages/common/search/keyword_variant_fetch.dart';
import 'package:PiliPlus/pages/video/reply_search_item/controller.dart';

class ReplySearchChildController
    extends CommonListController<SearchItemReply, SearchItem>
    with SearchKeywordResolver, KeywordVariantSearchMixin<SearchItemReply, SearchItem> {
  ReplySearchChildController(this.controller, this.searchType);

  final ReplySearchController controller;
  final ReplySearchType searchType;

  @override
  List<SearchItem>? getDataList(SearchItemReply response) {
    if (!response.cursor.hasNext) {
      isEnd = true;
    }
    return response.items;
  }

  @override
  String get searchText => controller.editingController.text;

  @override
  Future<String> primaryKeyword() => resolveSearchKeyword();

  @override
  Future<LoadingState<SearchItemReply>> fetchData(String keyword, int page) {
    return ReplyGrpc.searchItem(
      page: page,
      itemType: searchType == ReplySearchType.video
          ? SearchItemType.VIDEO
          : SearchItemType.ARTICLE,
      oid: controller.oid,
      type: controller.type,
      keyword: keyword,
    );
  }

  @override
  Future<LoadingState<SearchItemReply>> customGetData() =>
      fetchWithKeywordVariants(fetchData);

  @override
  List<SearchItem>? variantList(SearchItemReply response) => response.items;

  @override
  String? variantItemKey(SearchItem item) {
    if (item.url.isNotEmpty) return 'u${item.url}';
    if (item.whichItem() == SearchItem_Item.video) {
      final video = item.video;
      if (video.whichVideoItem() == VideoSearchItem_VideoItem.ugc) {
        return 'v${video.ugc.title}';
      }
      if (video.whichVideoItem() == VideoSearchItem_VideoItem.pgc) {
        return 'v${video.pgc.title}';
      }
      return null;
    }
    if (item.whichItem() == SearchItem_Item.article) {
      return 'a${item.article.title}';
    }
    return null;
  }
}
