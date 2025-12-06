import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/body_metrics_model.dart';
import '../models/water_log_model.dart';
import '../models/sleep_log_model.dart';
import '../services/metrics_service.dart';

class MetricsProvider with ChangeNotifier {
  final MetricsService _metricsService = MetricsService();
  
  List<BodyMetricsModel> _bodyMetrics = [];
  List<WaterLogModel> _waterLogs = [];
  List<SleepLogModel> _sleepLogs = [];
  bool _isLoading = false;
  StreamSubscription? _metricsSubscription;

  List<BodyMetricsModel> get bodyMetrics => _bodyMetrics;
  List<WaterLogModel> get waterLogs => _waterLogs;
  List<SleepLogModel> get sleepLogs => _sleepLogs;
  bool get isLoading => _isLoading;

  /// Load metrics history
  Future<void> loadMetricsHistory(String clientId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await _metricsService.getMetricsHistory(clientId);
      if (result.isSuccess) {
        _bodyMetrics = result.dataOrNull ?? [];
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Subscribe to metrics (real-time)
  void subscribeToMetrics(String clientId) {
    _metricsSubscription?.cancel();
    _metricsSubscription = _metricsService.streamMetrics(clientId).listen((metrics) {
      _bodyMetrics = metrics;
      notifyListeners();
    });
  }

  /// Log metrics
  Future<void> logMetrics(BodyMetricsModel metrics) async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await _metricsService.logMetrics(metrics);
      if (result.isSuccess) {
        _bodyMetrics.insert(0, metrics);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Log water
  Future<void> logWater(WaterLogModel log) async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await _metricsService.logWater(log);
      if (result.isSuccess) {
        _waterLogs.insert(0, log);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Log sleep
  Future<void> logSleep(SleepLogModel log) async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await _metricsService.logSleep(log);
      if (result.isSuccess) {
        _sleepLogs.insert(0, log);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _metricsSubscription?.cancel();
    super.dispose();
  }
}




