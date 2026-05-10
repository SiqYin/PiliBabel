import 'dart:async';
import 'dart:convert';

import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:dio/dio.dart';

class AiPromptTemplate {
  String name;
  String prompt;

  AiPromptTemplate({required this.name, required this.prompt});

  Map<String, dynamic> toJson() => {'name': name, 'prompt': prompt};

  factory AiPromptTemplate.fromJson(Map<String, dynamic> json) =>
      AiPromptTemplate(name: json['name'] ?? '', prompt: json['prompt'] ?? '');
}

class AiChatService {
  static Dio? _dio;

  static Dio get _client {
    if (_dio != null) return _dio!;
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(minutes: 10),
    ));
    return _dio!;
  }

  static void resetClient() {
    _dio?.close();
    _dio = null;
  }

  static Map<String, String> _headers() {
    final apiKey = Pref.aiApiKey;
    return {
      'Content-Type': 'application/json',
      if (apiKey.isNotEmpty) 'Authorization': 'Bearer $apiKey',
    };
  }

  static String _baseUrl() {
    var url = Pref.aiApiUrl.trimRight();
    if (url.endsWith('/')) url = url.substring(0, url.length - 1);
    if (url.endsWith('/v1')) url = url.substring(0, url.length - 3);
    return url;
  }

  /// Fetch model list from /v1/models
  static Future<List<String>> fetchModels() async {
    final baseUrl = _baseUrl();
    if (baseUrl.isEmpty) throw Exception('请先配置 API 地址');
    final res = await _client.get(
      '$baseUrl/v1/models',
      options: Options(headers: _headers()),
    );
    final data = res.data;
    if (data is Map && data['data'] is List) {
      return (data['data'] as List)
          .map((e) => e['id']?.toString() ?? '')
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return [];
  }

  /// Stream chat completion from /v1/chat/completions
  /// Returns a stream of content strings (each token/chunk)
  static Stream<String> streamChat({
    required List<Map<String, String>> messages,
    String? model,
  }) async* {
    final baseUrl = _baseUrl();
    if (baseUrl.isEmpty) throw Exception('请先配置 API 地址');
    final useModel = model ?? Pref.aiModel;
    if (useModel.isEmpty) throw Exception('请先选择模型');

    final response = await _client.post<ResponseBody>(
      '$baseUrl/v1/chat/completions',
      data: jsonEncode({
        'model': useModel,
        'messages': messages,
        'stream': true,
      }),
      options: Options(
        headers: _headers(),
        responseType: ResponseType.stream,
      ),
    );

    final stream = response.data!.stream;
    final buffer = StringBuffer();

    await for (final chunk in stream) {
      buffer.write(utf8.decode(chunk));
      final lines = buffer.toString().split('\n');
      // Keep the last incomplete line in the buffer
      buffer
        ..clear()
        ..write(lines.removeLast());
      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.isEmpty || !trimmed.startsWith('data:')) continue;
        final data = trimmed.substring(5).trim();
        if (data == '[DONE]') return;
        try {
          final json = jsonDecode(data) as Map<String, dynamic>;
          final choices = json['choices'] as List?;
          if (choices != null && choices.isNotEmpty) {
            final delta = choices[0]['delta'] as Map<String, dynamic>?;
            final content = delta?['content'] as String?;
            if (content != null) {
              yield content;
            }
          }
        } catch (_) {
          // skip malformed chunks
        }
      }
    }
  }

  // --- Template CRUD ---

  static List<AiPromptTemplate> getTemplates() {
    final raw = Pref.aiPromptTemplates;
    if (raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => AiPromptTemplate.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static void saveTemplates(List<AiPromptTemplate> templates) {
    Pref.aiPromptTemplates = jsonEncode(templates.map((e) => e.toJson()).toList());
  }
}
