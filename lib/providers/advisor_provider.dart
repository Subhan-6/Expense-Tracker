import 'package:flutter/foundation.dart';

import '../core/formatters.dart';
import '../data/repositories/settings_repository.dart';
import '../insights/spending_report.dart';
import '../services/ai_advisor_service.dart';

enum AdvisorStatus { idle, loading, success, error }

class AdvisorProvider extends ChangeNotifier {
  AdvisorProvider(this._settings, this._service);

  final SettingsRepository _settings;
  final AiAdvisorService _service;

  String? _apiKey;
  AdvisorStatus _status = AdvisorStatus.idle;
  String? _advice;
  String? _adviceMonthKey;
  String? _error;

  bool get hasKey => _apiKey != null && _apiKey!.isNotEmpty;
  bool get loading => _status == AdvisorStatus.loading;
  String? get error => _error;

  /// Advice is only returned for the month it was generated for.
  String? adviceFor(DateTime month) =>
      _adviceMonthKey == Fmt.monthKey(month) ? _advice : null;

  Future<void> init() async {
    _apiKey = await _settings.getApiKey();
    notifyListeners();
  }

  Future<void> saveKey(String key) async {
    final clean = key.trim();
    await _settings.saveApiKey(clean);
    _apiKey = clean;
    _error = null;
    _status = AdvisorStatus.idle;
    notifyListeners();
  }

  Future<void> removeKey() async {
    await _settings.clearApiKey();
    _apiKey = null;
    _advice = null;
    _adviceMonthKey = null;
    _error = null;
    _status = AdvisorStatus.idle;
    notifyListeners();
  }

  Future<void> requestAdvice(SpendingReport report) async {
    if (!hasKey || loading) return;
    _status = AdvisorStatus.loading;
    _error = null;
    notifyListeners();
    try {
      _advice = await _service.getAdvice(
        apiKey: _apiKey!,
        summary: report.toAiPayload(),
      );
      _adviceMonthKey = Fmt.monthKey(report.month);
      _status = AdvisorStatus.success;
    } on AdviceException catch (e) {
      _error = e.message;
      _status = AdvisorStatus.error;
    } catch (_) {
      _error = 'Could not reach the AI service. Check your internet connection.';
      _status = AdvisorStatus.error;
    }
    notifyListeners();
  }
}
