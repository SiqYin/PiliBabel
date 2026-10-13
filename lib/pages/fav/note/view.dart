import 'package:PiliPlus/services/ui_translate/ui_translate_service.dart';
import 'package:PiliPlus/pages/fav/note/child_view.dart';
import 'package:PiliPlus/pages/fav/note/controller.dart';
import 'package:PiliPlus/utils/extension/scroll_controller_ext.dart';
import 'package:get/get.dart';
import 'package:material_ui/material_ui.dart';

class FavNotePage extends StatefulWidget {
  const FavNotePage({super.key});

  @override
  State<FavNotePage> createState() => _FavNotePageState();
}

class _FavNotePageState extends State<FavNotePage>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TabBar(
                overlayColor: const WidgetStatePropertyAll(Colors.transparent),
                splashFactory: NoSplash.splashFactory,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                controller: _tabController,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                dividerHeight: 0,
                indicatorWeight: 0,
                indicatorPadding: const EdgeInsets.symmetric(
                  horizontal: 3,
                  vertical: 8,
                ),
                indicator: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelStyle:
                    TabBarTheme.of(
                      context,
                    ).labelStyle?.copyWith(fontSize: 14) ??
                    const TextStyle(fontSize: 14),
                labelColor: theme.colorScheme.onSecondaryContainer,
                unselectedLabelColor: theme.colorScheme.outline,
                tabs: [
                  Tab(text: uiTx('未发布笔记')),
                  Tab(text: uiTx('公开笔记')),
                ],
                onTap: (index) {
                  try {
                    if (!_tab