import '../models/workout_template_model.dart';
import '../models/assigned_workout_model.dart';
import '../models/workout_log_model.dart';
import '../exceptions/app_exceptions.dart';
import '../utils/result.dart';
import 'firestore_service.dart';

class WorkoutService {
  final FirestoreService _firestoreService = FirestoreService();

  /// Create workout template
  Future<Result<WorkoutTemplateModel>> createTemplate(WorkoutTemplateModel template) async {
    try {
      await _firestoreService.setDocument(
        'workout_templates/${template.id}',
        template.toJson(),
      );
      return Success(template);
    } catch (e) {
      return Failure('Failed to create template: $e');
    }
  }

  /// Get templates by coach
  Future<Result<List<WorkoutTemplateModel>>> getTemplates(String coachId) async {
    try {
      final dataList = await _firestoreService.queryCollection(
        'workout_templates',
        whereField: 'createdBy',
        whereValue: coachId,
        orderBy: 'createdAt',
        descending: true,
      );
      final templates = dataList.map((data) => WorkoutTemplateModel.fromJson(data)).toList();
      return Success(templates);
    } catch (e) {
      return Failure('Failed to get templates: $e');
    }
  }

  /// Get template by ID
  Future<Result<WorkoutTemplateModel>> getTemplate(String templateId) async {
    try {
      final data = await _firestoreService.getDocument('workout_templates/$templateId');
      if (data == null) {
        return const Failure('Template not found');
      }
      return Success(WorkoutTemplateModel.fromJson(data));
    } catch (e) {
      return Failure('Failed to get template: $e');
    }
  }

  /// Assign workout to client(s)
  Future<Result<void>> assignWorkout(AssignedWorkoutModel assignment) async {
    try {
      await _firestoreService.setDocument(
        'assigned_workouts/${assignment.id}',
        assignment.toJson(),
      );
      return const Success(null);
    } catch (e) {
      return Failure('Failed to assign workout: $e');
    }
  }

  /// Get assigned workouts for client
  Future<Result<List<AssignedWorkoutModel>>> getAssignedWorkouts(String clientId) async {
    try {
      final dataList = await _firestoreService.queryCollection(
        'assigned_workouts',
        whereField: 'clientId',
        whereValue: clientId,
        orderBy: 'startDate',
        descending: false,
      );
      final workouts = dataList.map((data) => AssignedWorkoutModel.fromJson(data)).toList();
      return Success(workouts);
    } catch (e) {
      return Failure('Failed to get assigned workouts: $e');
    }
  }

  /// Stream assigned workouts for client (real-time)
  Stream<List<AssignedWorkoutModel>> streamAssignedWorkouts(String clientId) {
    return _firestoreService.streamQuery(
      'assigned_workouts',
      whereField: 'clientId',
      whereValue: clientId,
      orderBy: 'startDate',
      descending: false,
    ).map((dataList) {
      return dataList.map((data) => AssignedWorkoutModel.fromJson(data)).toList();
    });
  }

  /// Log workout session
  Future<Result<WorkoutLogModel>> logWorkout(WorkoutLogModel log) async {
    try {
      await _firestoreService.setDocument(
        'workout_logs/${log.id}',
        log.toJson(),
      );

      // Update assigned workout status if completed
      if (log.completed) {
        await _firestoreService.updateDocument(
          'assigned_workouts/${log.assignedWorkoutId}',
          {'status': 'completed'},
        );
      }

      return Success(log);
    } catch (e) {
      return Failure('Failed to log workout: $e');
    }
  }

  /// Get workout history for client
  Future<Result<List<WorkoutLogModel>>> getWorkoutHistory(
    String clientId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // For complex queries, get all and filter in memory
      // In production, you'd want to add proper Firestore indexes
      final dataList = await _firestoreService.queryCollection(
        'workout_logs',
        whereField: 'clientId',
        whereValue: clientId,
        orderBy: 'date',
        descending: true,
      );
      
      var logs = dataList.map((data) => WorkoutLogModel.fromJson(data)).toList();
      
      // Filter by date range if provided
      if (startDate != null) {
        logs = logs.where((log) => log.date.isAfter(startDate) || log.date.isAtSameMomentAs(startDate)).toList();
      }
      if (endDate != null) {
        logs = logs.where((log) => log.date.isBefore(endDate) || log.date.isAtSameMomentAs(endDate)).toList();
      }

      return Success(logs);
    } catch (e) {
      return Failure('Failed to get workout history: $e');
    }
  }
}

