import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/search.dart';
import 'package:PiliPlus/models_new/dynamic/dyn_topic_pub_search/data.dart';
import 'package:PiliPlus/models_new/dynamic/dyn_topic_top/topic_item.dart';
import 'package:PiliPlus/pages/common/common_list_controller.dart';
import 'package:PiliPlus/pages/common/search/keyword_variant_fetch.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class SelectTopicController
    extends CommonListController<TopicPubSearchData, TopicItem>
    with SearchKeywordResolver, KeywordVariantSearchMixin<TopicPubSearchData, TopicItem> {
  final focusNode = FocusNode();
  final controller = TextEditingController();

  final RxBool enableClear = false.obs;

  @override
  void onInit() {
    super.onInit();
    queryData();
  }

  @override
  List<TopicItem>? getDataList(TopicPubSearchData response) {
    if (response.pageInfo?.hasMore == false) {
      isEnd = true;
    }
    return response.topicItems;
  }

  @override
  String get searchText => controller.text;

  @override
  Future<String> primaryKeyword() => resolveSearchKeyword();

  @override
  Future<LoadingState<TopicPubSearchData>> fetchData(
          String keyword, int page) =>
      SearchHttp.topicPubSearch(
        keywords: keyword,
        pageNum: page,
      );

  @override
  Future<LoadingState<TopicPubSearchData>> customGetData() =>
      fetchWithKeywordVariants(fetchData);

  @override
  List<TopicItem>? variantList(TopicPubSearchData response) =>
      response.topicItems;

  @override
  String? variantItemKey(TopicItem item) => 't${item.id}';

  @override
  void onClose() {
    focusNode.dispose();
    controller.dispose();
    super.onClose();
  }
}
