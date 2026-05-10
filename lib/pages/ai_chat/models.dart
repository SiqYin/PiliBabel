class ChatMessage {
  final String role; // 'user' | 'assistant' | 'system'
  String content;
  bool isStreaming;

  ChatMessage({
    required this.role,
    required this.content,
    this.isStreaming = false,
  });
}
