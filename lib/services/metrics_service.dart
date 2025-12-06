import '../models/body_metrics_model.dart';
import '../models/water_log_model.dart';
import '../models/sleep_log_model.dart';
import '../exceptions/app_exceptions.dart';
import '../utils/result.dart';
import 'firestore_service.dart';

class MetricsService {
  final FirestoreService _firestoreService = FirestoreService();

  /// Log body metrics
  Future<Result<BodyMetricsModel>> logMetrics(BodyMetricsModel metrics) async {
    try {
      await _firestoreService.setDocument(
        'body_metrics/${metrics.id}',
        metrics.toJson(),
      );
      return Success(metrics);
    } catch (e) {
      return Failure('Failed to log metrics: $e');
    }
  }

  /// Get metrics history
  Future<Result<List<BodyMetricsModel>>> getMetricsHistory(String clientId) async {
    try {
      final dataList = await _firestoreService.queryCollection(
        'body_metrics',
        whereField: 'clientId',
        whereValue: clientId,
        orderBy: 'date',
        descending: true,
      );
      final metrics = dataList.map((data) => BodyMetricsModel.fromJson(data)).toList();
      return Success(metrics);
    } catch (e) {
      return Failure('Failed to get metrics history: $e');
    }
  }

  /// Stream metrics (real-time)
  Stream<List<BodyMetricsModel>> streamMetrics(String clientId) {
    return _firestoreService.streamQuery(
      'body_metrics',
      whereField: 'clientId',
      whereValue: clientId,
      orderBy: 'date',
      descending: true,
    ).map((dataList) {
      return dataList.map((data) => BodyMetricsModel.fromJson(data)).toList();
    });
  }

  /// Get latest metrics
  Future<Result<BodyMetricsModel?>> getLatestMetrics(String clientId) async {
    try {
      final dataList = await _firestoreService.queryCollection(
        'body_metrics',
        whereField: 'clientId',
        whereValue: clientId,
        orderBy: 'date',
        descending: true,
        limit: 1,
      );
      
      if (dataList.isEmpty) {
        return const Success(null);
      }
      
      return Success(BodyMetricsModel.fromJson(dataList.first));
    } catch (e) {
      return Failure('Failed to get latest metrics: $e');
    }
  }

  /// Log water intake
  Future<Result<WaterLogModel>> logWater(WaterLogModel log) async {
    try {
      await _firestoreService.setDocument(
        'water_logs/${log.id}',
        log.toJson(),
      );
      return Success(log);
    } catch (e) {
      return Failure('Failed to log water: $e');
    }
  }

  /// Get water log for a date
  Future<Result<WaterLogModel?>> getWaterLog(String clientId, DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      
      final dataList = await _firestoreService.queryCollection(
        'water_logs',
        whereField: 'clientId',
        whereValue: clientId,
      );
      
      final logs = dataList.map((data) => WaterLogModel.fromJson(data)).toList();
      final dayLog = logs.firstWhere(
        (log) => log.date.isAfter(startOfDay) && log.date.isBefore(endOfDay),
        orElse: () => throw StateError('No log found'),
      );
      
      return Success(dayLog);
    } catch (e) {
      return Success(null);
    }
  }

  /// Log sleep
  Future<Result<SleepLogModel>> logSleep(SleepLogModel log) async {
    try {
      await _firestoreService.setDocument(
        'sleep_logs/${log.id}',
        log.toJson(),
      );
      return Success(log);
    } catch (e) {
      return Failure('Failed to log sleep: $e');
    }
  }

  /// Get sleep log for a date
  Future<Result<SleepLogModel?>> getSleepLog(String clientId, DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      
      final dataList = await _firestoreService.queryCollection(
        'sleep_logs',
        whereField: 'clientId',
        whereValue: clientId,
      );
      
      final logs = dataList.map((data) => SleepLogModel.fromJson(data)).toList();
      final dayLog = logs.firstWhere(
        (log) => log.date.isAfter(startOfDay) && log.date.isBefore(endOfDay),
        orElse: () => throw StateError('No log found'),
      );
      
      return Success(dayLog);
    } catch (e) {
      return Success(null);
    }
  }

  /// Calculate BMI from weight and height
  double? calculateBMI(double? weightKg, double? heightCm) {
    if (weightKg == null || heightCm == null) return null;
    if (heightCm == 0) return null;
    final heightM = heightCm / 100;
    return weightKg / (heightM * heightM);
  }
}

