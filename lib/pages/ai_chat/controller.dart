import 'dart:async';

import 'package:PiliPlus/http/video.dart';
import 'package:PiliPlus/pages/ai_chat/models.dart';
import 'package:PiliPlus/pages/video/controller.dart';
import 'package:PiliPlus/pages/video/introduction/ugc/controller.dart';
import 'package:PiliPlus/services/ai_chat/ai_chat_service.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

class AiChatController extends GetxController {
  final messages = <ChatMessage>[].obs;
  final isAnalyzing = false.obs;
  final subtitleWarning = false.obs;

  final String heroTag;
  late final VideoDetailController _videoCtl;

  AiChatController({required this.heroTag});

  static const _systemPrompt =
      '你是一个视频内容分析助手。用户会提供视频的标题、简介和字幕内容，请根据用户的要求进行分析。'
      '要求：'
      '1. 回复语言为中文，使用 Markdown 格式。'
      '2. 在关键内容处标注时间戳，格式为 [MM:SS] 或 [HH:MM:SS]，便于用户跳转回看。'
      '3. 如果字幕信息不足，可参考视频简介补充分析；如果内容确实无法分析，提醒用户自行观看。';

  @override
  void onInit() {
    super.onInit();
    _videoCtl = Get.find<VideoDetailController>(tag: heroTag);
  }

  bool get hasSubtitles => _videoCtl.subtitles.isNotEmpty;

  String _buildVideoInfo() {
    String info = '';
    try {
      final videoDetail =
          Get.find<UgcIntroController>(tag: heroTag).videoDetail.value;
      final title = videoDetail.title;
      final desc = videoDetail.desc;
      if (title != null && title.isNotEmpty) {
        info = '视频标题：$title\n';
      }
      if (desc != null && desc.isNotEmpty) {
        info += '视频简介：$desc\n';
      }
      if (info.isNotEmpty) info += '\n';
    } catch (_) {}
    return info;
  }

  /// Start analysis with a template prompt.
  Future<void> startAnalysis(String templatePrompt, {String? templateName}) async {
    if (isAnalyzing.value) return;

    isAnalyzing.value = true;
    subtitleWarning.value = false;

    try {
      final videoInfo = _buildVideoInfo();
      String contextContent;

      if (hasSubtitles) {
        // Fetch subtitle body
        final subtitle = _videoCtl.subtitles.first;
        final body = await VideoHttp.fetchSubtitleBody(subtitle.subtitleUrl!);
        if (body == null || body.isEmpty) {
          SmartDialog.showToast('获取字幕数据失败');
          return;
        }
        final processed = VideoHttp.preprocessSubtitlesForAi(body);
        subtitleWarning.value = processed.isTooLong;
        contextContent =
            '$videoInfo## 字幕内容\n${processed.text}\n\n---\n$templatePrompt';
      } else {
        // No subtitles, only provide video info
        contextContent = '$videoInfo---\n$templatePrompt';
      }

      messages
        ..add(ChatMessage(
          role: 'user',
          content: contextContent,
          templateName: templateName,
        ))
        ..add(ChatMessage(role: 'assistant', content: '', isStreaming: true));

      await _streamResponse();
    } catch (e) {
      SmartDialog.showToast('分析失败: $e');
      _removeLastIfStreaming();
    } finally {
      isAnalyzing.value = false;
    }
  }

  /// Send a follow-up message.
  Future<void> sendFollowUp(String text) async {
    if (isAnalyzing.value || text.trim().isEmpty) return;

    // First message without subtitles: prepend video info as context
    final isFirst = messages.isEmpty;
    String content = text.trim();
    if (isFirst && !hasSubtitles) {
      final videoInfo = _buildVideoInfo();
      if (videoInfo.isNotEmpty) {
        content = '$videoInfo$content';
      }
    }
    messages
      ..add(ChatMessage(role: 'user', content: content))
      ..add(ChatMessage(role: 'assistant', content: '', isStreaming: true));
    isAnalyzing.value = true;

    try {
      await _streamResponse();
    } catch (e) {
      SmartDialog.showToast('请求失败: $e');
      _removeLastIfStreaming();
    } finally {
      isAnalyzing.value = false;
    }
  }

  Future<void> _streamResponse() async {
    final chatMessages = [
      {'role': 'system', 'content': _systemPrompt},
      ...messages
          .where((m) => !m.isStreaming || m.content.isNotEmpty)
          .map((m) => {'role': m.role, 'content': m.content}),
    ];

    final lastMsg = messages.last;
    try {
      await for (final token in AiChatService.streamChat(
        messages: chatMessages,
      )) {
        lastMsg.appendContent(token);
        messages.refresh();
      }
    } finally {
      lastMsg.isStreaming = false;
      messages.refresh();
    }
  }

  void _removeLastIfStreaming() {
    if (messages.isNotEmpty && messages.last.isStreaming) {
      messages.removeLast();
    }
  }

  void clearMessages() {
    messages.clear();
    subtitleWarning.value = false;
  }
}
