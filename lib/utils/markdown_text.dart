/// Release 说明是 GitHub 的 **Markdown 原文**，直接塞进弹窗会把 `**`、`` ` ``、`###`
/// 这些排版符号原样显示出来，既难读、又会被送去翻译（白白拉长译文、还可能翻歪）。
///
/// 这里把 Markdown 压成**纯文本**：保留可读的内容与换行结构，去掉所有排版标记。
/// 处理顺序有讲究（行内代码要先于粗体/斜体，否则 `` `**x**` `` 会拆错）。
abstract final class MarkdownText {
  /// 把一段 GitHub Release 说明转成可直接展示的纯文本。
  static String toPlain(String md) {
    if (md.isEmpty) return md;

    var s = md;

    // 1) 代码块围栏 ```lang ... ``` → 只留内容（多行）
    s = s.replaceAll(RegExp(r'```[^\n]*\n?'), '');

    // 2) 行内代码 `code` → code（要在粗体之前，否则 `**` 在代码里会被误删）
    s = s.replaceAll(RegExp(r'`([^`]*)`'), r'$1');

    // 3) 图片 ![alt](url) → 丢掉（更新说明里的图片在纯文本弹窗没意义）
    s = s.replaceAll(RegExp(r'!\[[^\]]*\]\([^)]*\)'), '');
    // 4) 链接 [text](url) → text（若 text 为空则保留 url）
    s = s.replaceAllMapped(
      RegExp(r'\[([^\]]*)\]\(([^)]*)\)'),
      (m) => (m[1]?.trim().isNotEmpty ?? false) ? m[1]!.trim() : (m[2] ?? ''),
    );
    // 5) 裸链接 <https://...> → https://...
    s = s.replaceAll(RegExp(r'<((?:https?|mailto):[^>]+)>'), r'$1');

    // 6) 标题前缀 ### / ## / #
    s = s.replaceAll(RegExp(r'^\s{0,3}#{1,6}\s*', multiLine: true), '');

    // 7) 引用 > 与列表标记 - * + 以及有序列表 1.
    s = s.replaceAll(RegExp(r'^\s{0,3}>\s?', multiLine: true), '');
    s = s.replaceAll(RegExp(r'^\s{0,3}[-*+]\s+', multiLine: true), '');
    s = s.replaceAll(RegExp(r'^\s{0,3}\d+[.)]\s+', multiLine: true), '');

    // 8) 分隔线 --- / *** / ___
    s = s.replaceAll(RegExp(r'^\s{0,3}([-*_])\s*(?:\1\s*){2,}$', multiLine: true), '');

    // 9) 粗体 / 斜体 / 删除线（**x** __x__ *x* _x_ ~~x~~）
    s = s.replaceAll(RegExp(r'\*\*([^*]+)\*\*'), r'$1');
    s = s.replaceAll(RegExp(r'__([^_]+)__'), r'$1');
    s = s.replaceAll(RegExp(r'(?<![\w*])\*([^*\n]+)\*(?![\w*])'), r'$1');
    s = s.replaceAll(RegExp(r'(?<![\w_])_([^_\n]+)_(?![\w_])'), r'$1');
    s = s.replaceAll(RegExp(r'~~([^~]+)~~'), r'$1');

    // 10) 表格分隔行 |---|:--:|---| 丢掉，单元格竖线转成空格
    s = s.replaceAll(RegExp(r'^\s*\|?[\s:|-]+\|[\s:|-]*$', multiLine: true), '');
    s = s.replaceAll(RegExp(r'\|'), ' ');

    // 11) 折叠溢出的空行：3 行以上连续空行压成 1 个空行
    s = s.replaceAll(RegExp(r'\n{3,}'), '\n\n');

    // 12) 行尾空白与整体修剪
    s = s
        .split('\n')
        .map((l) => l.trimRight())
        .join('\n')
        .trim();

    return s;
  }

  /// 更新弹窗专用：在 [toPlain] 基础上再合并成适合弹窗宽度的短段落。
  ///
  /// 弹窗高度有限（280px），release note 太长时用户只能看到开头。
  /// 这里把连续的单行短句合并成一行，减少空白占位。
  static String toDialogText(String md) {
    final plain = toPlain(md);
    if (plain.isEmpty) return plain;
    final lines = plain.split('\n');
    final out = <String>[];
    for (final raw in lines) {
      final line = raw.trim();
      if (line.isEmpty) {
        if (out.isNotEmpty && out.last.isNotEmpty) out.add('');
        continue;
      }
      out.add(line);
    }
    while (out.isNotEmpty && out.last.isEmpty) {
      out.removeLast();
    }
    return out.join('\n');
  }
}
