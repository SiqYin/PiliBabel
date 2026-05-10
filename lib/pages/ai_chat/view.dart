import 'package:PiliPlus/pages/ai_chat/controller.dart';
import 'package:PiliPlus/pages/common/slide/common_slide_page.dart';
import 'package:PiliPlus/pages/video/controller.dart';
import 'package:PiliPlus/services/ai_chat/ai_chat_service.dart';
import 'package:PiliPlus/utils/duration_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_markdown_plus_latex/flutter_markdown_plus_latex.dart';
import 'package:get/get.dart';

class AiChatPage extends CommonSlidePage {
  const AiChatPage({super.key});

  @override
  State<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends State<AiChatPage>
    with SingleTickerProviderStateMixin, CommonSlideMixin {
  late final AiChatController chatCtl;
  final _inputCtl = TextEditingController();
  final _scrollCtl = ScrollController();
  late List<AiPromptTemplate> _templates;

  @override
  void initState() {
    super.initState();
    chatCtl = Get.put(AiChatController(), tag: 'aiChat');
    _templates = AiChatService.getTemplates();
  }

  @override
  void dispose() {
    _inputCtl.dispose();
    _scrollCtl.dispose();
    Get.delete<AiChatController>(tag: 'aiChat');
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollCtl.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollCtl.hasClients) {
          _scrollCtl.animateTo(
            _scrollCtl.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget buildPage(ThemeData theme) {
    return Material(
      color: theme.colorScheme.surface,
      child: Column(
        children: [
          // Drag handle
          GestureDetector(
            onTap: Get.back,
            child: SizedBox(
              height: 35,
              child: Center(
                child: Container(
                  width: 32,
                  height: 3,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: const BorderRadius.all(Radius.circular(3)),
                  ),
                ),
              ),
            ),
          ),
          // Template selection + analyze button
          _buildTemplateBar(theme),
          Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.1)),
          // Warning banner
          Obx(() {
            if (!chatCtl.subtitleWarning.value) return const SizedBox.shrink();
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              color: theme.colorScheme.errorContainer,
              child: Text(
                '字幕文本较长，分析结果可能不够完整',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onErrorContainer,
                ),
              ),
            );
          }),
          // Chat messages
          Expanded(
            child: enableSlide ? slideList(theme) : _buildMessageList(theme),
          ),
          // Input bar
          _buildInputBar(theme),
        ],
      ),
    );
  }

  Widget _buildTemplateBar(ThemeData theme) {
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          Expanded(
            child: _templates.isEmpty
                ? Center(
                    child: Text(
                      '暂无模板，请在设置中添加',
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  )
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _templates.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final t = _templates[index];
                      return Center(
                        child: Obx(() {
                          final analyzing = chatCtl.isAnalyzing.value;
                          final noSubtitle = !chatCtl.hasSubtitles;
                          return ActionChip(
                            label: Text(
                              t.name,
                              style: TextStyle(
                                fontSize: 13,
                                color: noSubtitle
                                    ? theme.colorScheme.outline
                                    : null,
                              ),
                            ),
                            onPressed: (analyzing || noSubtitle)
                                ? null
                                : () => chatCtl.startAnalysis(t.prompt),
                          );
                        }),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(ThemeData theme) {
    return Obx(() {
      final msgs = chatCtl.messages;
      if (msgs.isEmpty) {
        return Center(
          child: Text(
            chatCtl.hasSubtitles ? '选择模板开始分析' : '输入问题开始对话',
            style: TextStyle(color: theme.colorScheme.outline),
          ),
        );
      }
      // Auto-scroll on new messages
      chatCtl.messages.length; // trigger observation
      _scrollToBottom();

      return ListView.builder(
        controller: _scrollCtl,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: msgs.length,
        itemBuilder: (context, index) {
          final msg = msgs[index];
          if (msg.role == 'user') {
            return _buildUserMessage(msg.content, theme);
          }
          return _buildAssistantMessage(msg, theme);
        },
      );
    });
  }

  Widget _buildUserMessage(String content, ThemeData theme) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.8,
        ),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(4),
          ),
        ),
        child: Text(
          content,
          style: TextStyle(
            fontSize: 14,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
      ),
    );
  }

  Widget _buildAssistantMessage(dynamic msg, ThemeData theme) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.85,
        ),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: msg.content.isEmpty && msg.isStreaming
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.colorScheme.primary,
                ),
              )
            : MarkdownBody(
                data: _preprocessTimestamps(msg.content),
                selectable: true,
                blockSyntaxes: [LatexBlockSyntax()],
                inlineSyntaxes: [LatexInlineSyntax()],
                builders: {
                  'latex': LatexElementBuilder(),
                },
                onTapLink: (text, href, title) {
                  if (href != null && href.startsWith('timestamp://')) {
                    _seekToTimestamp(href);
                  }
                },
                styleSheet: MarkdownStyleSheet(
                  p: TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  code: TextStyle(
                    fontSize: 13,
                    color: theme.colorScheme.onSurfaceVariant,
                    backgroundColor: theme.colorScheme.surfaceContainerHigh,
                  ),
                  codeblockDecoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
      ),
    );
  }

  static final _timestampReg = RegExp(r'\[(\d{1,2}:\d{2}(?::\d{2})?)\]');

  /// Convert [MM:SS] / [HH:MM:SS] to clickable markdown links
  String _preprocessTimestamps(String text) {
    return text.replaceAllMapped(_timestampReg, (match) {
      final ts = match.group(1)!;
      final seconds = DurationUtils.parseDuration(ts);
      return '[$ts](timestamp://$seconds)';
    });
  }

  void _seekToTimestamp(String href) {
    final seconds = int.tryParse(href.replaceFirst('timestamp://', ''));
    if (seconds == null) return;
    try {
      final heroTag = Get.arguments?['heroTag'] ?? '';
      final videoCtl = Get.find<VideoDetailController>(tag: heroTag);
      final duration = videoCtl.plPlayerController.duration.value;
      if (duration.inSeconds > 0 && seconds > duration.inSeconds) return;
      videoCtl.plPlayerController.seekTo(
        Duration(seconds: seconds),
        isSeek: false,
      );
    } catch (_) {}
  }

  Widget _buildInputBar(ThemeData theme) {
    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 8,
        top: 8,
        bottom: MediaQuery.viewPaddingOf(context).bottom + 8,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.dividerColor.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _inputCtl,
              maxLines: 4,
              minLines: 1,
              textInputAction: TextInputAction.send,
              decoration: InputDecoration(
                hintText: '输入追问内容...',
                hintStyle: TextStyle(color: theme.colorScheme.outline),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                isDense: true,
              ),
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  chatCtl.sendFollowUp(value);
                  _inputCtl.clear();
                }
              },
            ),
          ),
          const SizedBox(width: 4),
          Obx(() => IconButton(
                onPressed: chatCtl.isAnalyzing.value
                    ? null
                    : () {
                        final text = _inputCtl.text;
                        if (text.trim().isNotEmpty) {
                          chatCtl.sendFollowUp(text);
                          _inputCtl.clear();
                        }
                      },
                icon: const Icon(Icons.send),
              )),
        ],
      ),
    );
  }

  @override
  Widget buildList(ThemeData theme) {
    return _buildMessageList(theme);
  }
}
