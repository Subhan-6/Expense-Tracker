import 'dart:convert';

import 'package:http/http.dart' as http;

class AdviceException implements Exception {
  const AdviceException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Sends an aggregated spending summary to the Claude Messages API and
/// returns plain-text advice. The user supplies their own API key.
class AiAdvisorService {
  AiAdvisorService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static final Uri _endpoint =
      Uri.parse('https://api.anthropic.com/v1/messages');
  static const String _model = 'claude-haiku-5-5';

  static const String _system =
      'You are a careful personal-finance coach inside an expense tracker app. '
      'The user is in Pakistan and all amounts are in Pakistani rupees (Rs). '
      'Use ONLY the numbers in the JSON provided; never invent figures or assume facts that are not in the data. '
      'Start with a one-sentence summary of the month. '
      'Then give 5 short, specific, actionable suggestions ordered by impact, each on its own line starting with a number. '
      'Mention category names and rupee amounts. '
      'If the month is not finished, base the advice on the projected figures. '
      'Reply in plain text only: no markdown, no asterisks, no headings. Keep the whole reply under 180 words.';

  Future<String> getAdvice({
    required String apiKey,
    required Map<String, Object?> summary,
  }) async {
    final response = await _client
        .post(
          _endpoint,
          headers: {
            'content-type': 'application/json',
            'x-api-key': apiKey,
            'anthropic-version': '2023-06-01',
          },
          body: jsonEncode({
            'model': _model,
            'max_tokens': 800,
            'system': _system,
            'messages': [
              {
                'role': 'user',
                'content':
                    'Here is my spending summary as JSON:\n${jsonEncode(summary)}\n\nPlease analyse it and advise me how to save more.',
              },
            ],
          }),
        )
        .timeout(const Duration(seconds: 45));

    final data = _tryDecode(response.bodyBytes);

    if (response.statusCode == 200 && data != null) {
      final content = data['content'];
      if (content is List) {
        final text = content
            .whereType<Map>()
            .where((block) => block['type'] == 'text')
            .map((block) => block['text'])
            .join('\n')
            .trim();
        if (text.isNotEmpty) return text;
      }
      throw const AdviceException(
          'The AI returned an empty answer. Please try again.');
    }
    throw AdviceException(_errorMessage(response.statusCode, data));
  }

  Map<String, dynamic>? _tryDecode(List<int> bytes) {
    try {
      final decoded = jsonDecode(utf8.decode(bytes));
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  String _errorMessage(int status, Map<String, dynamic>? data) {
    switch (status) {
      case 401:
        return 'Invalid API key. Check it and try again.';
      case 403:
        return 'This API key is not allowed to use the service.';
      case 429:
        return 'Too many requests. Wait a minute and try again.';
    }
    if (status >= 500) {
      return 'The AI service is busy right now. Try again shortly.';
    }
    final apiMessage = data?['error']?['message'];
    if (apiMessage is String && apiMessage.isNotEmpty) return apiMessage;
    return 'Request failed (code $status).';
  }
}
