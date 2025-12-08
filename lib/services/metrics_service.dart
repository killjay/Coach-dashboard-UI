import '../models/body_metrics_model.dart';
import '../models/water_log_model.dart';
import '../models/sleep_log_model.dart';
import '../models/steps_log_model.dart';
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

  /// Log steps
  Future<Result<StepsLogModel>> logSteps(StepsLogModel log) async {
    try {
      await _firestoreService.setDocument(
        'steps_logs/${log.id}',
        log.toJson(),
      );
      return Success(log);
    } catch (e) {
      return Failure('Failed to log steps: $e');
    }
  }

  /// Get steps log for a date
  Future<Result<StepsLogModel?>> getStepsLog(String clientId, DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      
      final dataList = await _firestoreService.queryCollection(
        'steps_logs',
        whereField: 'clientId',
        whereValue: clientId,
      );
      
      final logs = dataList.map((data) => StepsLogModel.fromJson(data)).toList();
      final dayLog = logs.firstWhere(
        (log) => log.date.isAfter(startOfDay) && log.date.isBefore(endOfDay),
        orElse: () => throw StateError('No log found'),
      );
      
      return Success(dayLog);
    } catch (e) {
      return Success(null);
    }
  }

  /// Get steps history
  Future<Result<List<StepsLogModel>>> getStepsHistory(
    String clientId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final dataList = await _firestoreService.queryCollection(
        'steps_logs',
        whereField: 'clientId',
        whereValue: clientId,
        orderBy: 'date',
        descending: true,
      );
      
      var logs = dataList.map((data) => StepsLogModel.fromJson(data)).toList();
      
      if (startDate != null) {
        logs = logs.where((log) => 
          log.date.isAfter(startDate.subtract(const Duration(days: 1))) || 
          log.date.isAtSameMomentAs(startDate)
        ).toList();
      }
      if (endDate != null) {
        logs = logs.where((log) => 
          log.date.isBefore(endDate.add(const Duration(days: 1))) || 
          log.date.isAtSameMomentAs(endDate)
        ).toList();
      }

      return Success(logs);
    } catch (e) {
      return Failure('Failed to get steps history: $e');
    }
  }

  /// Stream steps logs (real-time)
  Stream<List<StepsLogModel>> streamStepsLog(String clientId) {
    return _firestoreService.streamQuery(
      'steps_logs',
      whereField: 'clientId',
      whereValue: clientId,
      orderBy: 'date',
      descending: true,
    ).map((dataList) {
      return dataList.map((data) => StepsLogModel.fromJson(data)).toList();
    });
  }

  /// Get daily steps with goal
  Future<Result<Map<String, dynamic>>> getDailySteps(String clientId, DateTime date) async {
    try {
      final stepsLogResult = await getStepsLog(clientId, date);
      final stepsLog = stepsLogResult.dataOrNull;
      
      if (stepsLog != null) {
        return Success({
          'steps': stepsLog.steps,
          'goal': stepsLog.goal,
          'progress': stepsLog.progress,
        });
      }
      
      // Default goal if no log exists
      return Success({
        'steps': 0,
        'goal': 10000, // Default goal
        'progress': 0.0,
      });
    } catch (e) {
      return Failure('Failed to get daily steps: $e');
    }
  }

  /// Stream water logs (real-time)
  Stream<List<WaterLogModel>> streamWaterLogs(String clientId) {
    return _firestoreService.streamQuery(
      'water_logs',
      whereField: 'clientId',
      whereValue: clientId,
      orderBy: 'date',
      descending: true,
    ).map((dataList) {
      return dataList.map((data) => WaterLogModel.fromJson(data)).toList();
    });
  }

  /// Get or create daily water log
  Future<Result<WaterLogModel>> getOrCreateDailyWaterLog(String clientId, DateTime date, double goal) async {
    try {
      final logResult = await getWaterLog(clientId, date);
      final existingLog = logResult.dataOrNull;
      
      if (existingLog != null) {
        return Success(existingLog);
      }
      
      // Create new log
      final newLog = WaterLogModel(
        id: _firestoreService.generateId('water_logs'),
        clientId: clientId,
        date: date,
        amount: 0.0,
        goal: goal,
        loggedAt: DateTime.now(),
      );
      
      return Success(newLog);
    } catch (e) {
      return Failure('Failed to get or create water log: $e');
    }
  }

  /// Add water to existing log
  Future<Result<WaterLogModel>> addWaterToLog(String clientId, DateTime date, double amount) async {
    try {
      final logResult = await getWaterLog(clientId, date);
      final existingLog = logResult.dataOrNull;
      
      if (existingLog != null) {
        // Update existing log
        final updatedLog = WaterLogModel(
          id: existingLog.id,
          clientId: existingLog.clientId,
          date: existingLog.date,
          amount: existingLog.amount + amount,
          goal: existingLog.goal,
          loggedAt: DateTime.now(),
        );
        return await logWater(updatedLog);
      }
      
      // Create new log with default goal
      final newLog = WaterLogModel(
        id: _firestoreService.generateId('water_logs'),
        clientId: clientId,
        date: date,
        amount: amount,
        goal: 3500.0, // Default 3.5L
        loggedAt: DateTime.now(),
      );
      return await logWater(newLog);
    } catch (e) {
      return Failure('Failed to add water to log: $e');
    }
  }
}

