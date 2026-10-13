import 'package:PiliPlus/services/ui_translate/ui_translate_service.dart';
import 'package:PiliPlus/common/widgets/keep_alive_wrapper.dart';
import 'package:PiliPlus/common/widgets/scroll_physics.dart'
    show tabBarScrollPhysics;
import 'package:PiliPlus/common/widgets/selection_text.dart';
import 'package:PiliPlus/common/widgets/stat/stat.dart';
import 'package:PiliPlus/models/common/stat_type.dart';
import 'package:PiliPlus/models_new/pgc/pgc_info_model/result.dart';
import 'package:PiliPlus/models_new/video/video_tag/data.dart';
import 'package:PiliPlus/pages/common/slide/common_slide_page.dart';
import 'package:PiliPlus/pages/pgc_review/view.dart';
import 'package:PiliPlus/pages/search/widgets/search_text.dart';
import 'package:PiliPlus/utils/extension/scroll_controller_ext.dart';
import 'package:PiliPlus/utils/utils.dart';
import 'package:get/get.dart';
import 'package:material_ui/material_ui.dart';

class PgcIntroPanel extends CommonSlidePage {
  final PgcInfoModel item;
  final List<VideoTagItem>? videoTags;

  const PgcIntroPanel({
    super.key,
    required this.item,
    super.enableSlide,
    this.videoTags,
  });

  @override
  State<PgcIntroPanel> createState() => _IntroDetailState();
}

class _IntroDetailState extends State<PgcIntroPanel>
    with TickerProviderStateMixin, CommonSlideMixin {
  late final ScrollController _controller;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget buildPage(ThemeData theme) {
    return Material(
      color: theme.colorScheme.surface,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TabBar(
                  controller: _tabController,
                  dividerHeight: 0,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  dividerColor: Colors.transparent,
                  tabs: [
                    Tab(text: uiTx('详情')),
                    Tab(text: uiTx('点评')),
                  ],
                  onTap: (index) {
                    if (!_tabController.indexIsCha