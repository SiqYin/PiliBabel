import 'dart:io' show Platform;

import 'package:PiliPlus/common/widgets/scaffold/mini_scaffold.dart';
import 'package:PiliPlus/common/widgets/scaffold/simple_scaffold.dart';
import 'package:PiliPlus/pages/webview/view.dart';
import 'package:PiliPlus/services/ui_translate/ui_translate_service.dart';
import 'package:desktop_webview_window/desktop_webview_window.dart' as dww;
import 'package:get/get.dart';
import 'package:material_ui/material_ui.dart';

/// 专栏（文章）投稿。
///
/// B站的APP 端**没有**创建文章的 gRPC 接口，社区权威文档
/// （bilibili-API-collect）里 article 分类也只有一个读接口
/// `x/article/viewinfo`，没有 create/publish。唯一真正的投稿 API 是
/// 开放平台的 `member.bilibili.com/arcopen/fn/article/add`，但那需要企业资质
/// 与 `ATC_BASE` 权限申请，个人开发者拿不到。
///
/// 所以走 Web 后台 `member.bilibili.com/article/publish`，用项目已有的
/// WebView 承载：登录态由 `LoginUtils.setWebCookie()` 注入（遍历
/// `Accounts.main.cookieJar` 把 SESSDATA / bili_jct 逐个写进 webview），
/// 上传的风控校验由用户在页面里手动过（WebView 已开 JS，滑块可交互）。
///
/// 与「视频笔记」是同一套基建，参考 `pages/video/note/view.dart`。
class ArticlePublishPage extends StatefulWidget {
  const ArticlePublishPage({super.key});

  /// 专栏投稿的 Web 后台入口。
  static const String publishUrl =
      'https://member.bilibili.com/article/publish';

  /// 打开投稿页。
  ///
  /// [onPublished] 在检测到提交成功时回调，参数是新文章的 cvid。
  static Future<void> toArticlePublishPage({
    void Function(int cvid)? onPublished,
  }) {
    return Get.to(
      () => ArticlePublishPage(onPublished: onPublished),
      routeName: '/articlePublish',
    );
  }

  final void Function(int cvid)? onPublished;

  @override
  State<ArticlePublishPage> createState() => _ArticlePublishPageState();
}

class _ArticlePublishPageState extends State<ArticlePublishPage> {
  dww.Webview? _linuxWebview;
  bool _isOpening = false;

  Future<void> _open() async {
    if (_isOpening) return;
    // Linux 桌面端走多窗口 webview（Cookie 注入 + 独立窗口），
    // 其余平台用应用内 bottom sheet，与视频笔记完全一致。
    if (Platform.isLinux) {
      _isOpening = true;
      try {
        final webview = await WebviewPage.openLinux(
          url: ArticlePublishPage.publishUrl,
          title: uiTx('专栏投稿'),
          // 投稿页没有 oid；传 0 只是为了满足签名，非 note 场景不会用到。
          oid: 0,
          onClose: () => _linuxWebview = null,
        );
        _linuxWebview = webview;
      } finally {
        _isOpening = false;
      }
      return;
    }
    // 与「视频笔记」完全一致：WebviewPage 自带 Scaffold，用 MiniScaffold 的
    // bottom sheet 承载而不是嵌套 Scaffold。
    MiniScaffold.of(context).showBottomSheet(
      constraints: const BoxConstraints(),
      (context) => WebviewPage(
        url: ArticlePublishPage.publishUrl,
        title: uiTx('专栏投稿'),
        onArticlePublished: widget.onPublished,
      ),
    );
  }

  @override
  void dispose() {
    _linuxWebview?.close();
    _linuxWebview = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SimpleScaffold(
      appBar: AppBar(title: Text(uiTx('专栏投稿'))),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.edit_note,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                uiTx('在 B 站专栏编辑器里完成投稿'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                uiTx('投稿会跳转到 B 站官方创作后台，需要你自行登录并完成必要的安全验证；提交后稿件会进入审核。'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _isOpening ? null : _open,
                child: Text(uiTx('打开投稿页面')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
