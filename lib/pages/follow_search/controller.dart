import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/member.dart';
import 'package:PiliPlus/models_new/follow/data.dart';
import 'package:PiliPlus/models_new/follow/list.dart';
import 'package:PiliPlus/pages/common/search/common_search_controller.dart';

class FollowSearchController
    extends CommonSearchController<FollowData, FollowItemModel> {
  FollowSearchController(this.mid);
  final int mid;

  @override
  Future<LoadingState<FollowData>> fetchData(String keyword, int page) =>
      MemberHttp.getfollowSearch(
        mid: mid,
        ps: 20,
        pn: page,
        name: keyword,
      );

  @override
  List<FollowItemModel>? getDataList(FollowData response) {
    return response.list;
  }

  @override
  String? variantItemKey(FollowItemModel item) =>
      item.mid == null ? null : 'm${item.mid}';
}
