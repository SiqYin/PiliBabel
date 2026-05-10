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

  late final String heroTag;
  late final VideoDetailController _videoCtl;

  static const _systemPrompt =
      '你是一个视频内容分析助手。用户会提供视频的字幕文本，你需要根据用户的要求对字幕内容进行分析。'
      '不可随意翻译内容，返回内容为中文，不可包含任何广告、推广、侮辱、诽谤等内容。'
      '如果字幕信息不足，可以参考视频简介，如果内容无效，你需要提醒我无法总结内容，让我自行观看视频。'
      '请务必保证内容的准确性，否则将会影响你的积分和信誉。'
      '回复中请尽可能在对应内容的开头给出引用具体时间点，请使用 [MM:SS] 或 [HH:MM:SS] 格式的时间戳。'
      '请使用 Markdown 格式回复。';

  @override
  void onInit() {
    super.onInit();
    heroTag = Get.arguments?['heroTag'] ?? '';
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
        info = '# $title\n';
      }
      if (desc != null && desc.isNotEmpty) {
        info += '> $desc\n';
      }
      if (info.isNotEmpty) info += '\n';
    } catch (_) {}
    return info;
  }

  /// Start analysis with a template prompt.
  Future<void> startAnalysis(String templatePrompt) async {
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

      messages.add(ChatMessage(role: 'user', content: contextContent));

      // Add placeholder for streaming response
      messages.add(
        ChatMessage(role: 'assistant', content: '', isStreaming: true),
      );

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
    messages.add(ChatMessage(role: 'user', content: content));
    messages.add(
      ChatMessage(role: 'assistant', content: '', isStreaming: true),
    );
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
        lastMsg.content += token;
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
