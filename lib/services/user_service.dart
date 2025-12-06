import '../models/user_model.dart';
import '../models/client_model.dart';
import '../models/coach_model.dart';
import '../exceptions/app_exceptions.dart';
import '../utils/result.dart';
import 'firestore_service.dart';

class UserService {
  final FirestoreService _firestoreService = FirestoreService();

  /// Get user by ID
  Future<Result<UserModel>> getUser(String userId) async {
    try {
      final data = await _firestoreService.getDocument('users/$userId');
      if (data == null) {
        return const Failure('User not found');
      }
      return Success(UserModel.fromJson(data));
    } catch (e) {
      return Failure('Failed to get user: $e');
    }
  }

  /// Stream user data
  Stream<UserModel?> streamUser(String userId) {
    return _firestoreService.streamDocument('users/$userId').map((data) {
      return data != null ? UserModel.fromJson(data) : null;
    });
  }

  /// Create user document
  Future<Result<void>> createUser(UserModel user) async {
    try {
      await _firestoreService.setDocument('users/${user.id}', user.toJson());
      return const Success(null);
    } catch (e) {
      return Failure('Failed to create user: $e');
    }
  }

  /// Update user
  Future<Result<void>> updateUser(UserModel user) async {
    try {
      await _firestoreService.updateDocument('users/${user.id}', user.toJson());
      return const Success(null);
    } catch (e) {
      return Failure('Failed to update user: $e');
    }
  }

  /// Get client by ID
  Future<Result<ClientModel>> getClient(String clientId) async {
    try {
      final data = await _firestoreService.getDocument('clients/$clientId');
      if (data == null) {
        return const Failure('Client not found');
      }
      return Success(ClientModel.fromJson(data));
    } catch (e) {
      return Failure('Failed to get client: $e');
    }
  }

  /// Stream client data
  Stream<ClientModel?> streamClient(String clientId) {
    return _firestoreService.streamDocument('clients/$clientId').map((data) {
      return data != null ? ClientModel.fromJson(data) : null;
    });
  }

  /// Get coach by ID
  Future<Result<CoachModel>> getCoach(String coachId) async {
    try {
      final data = await _firestoreService.getDocument('coaches/$coachId');
      if (data == null) {
        return const Failure('Coach not found');
      }
      return Success(CoachModel.fromJson(data));
    } catch (e) {
      return Failure('Failed to get coach: $e');
    }
  }

  /// Get all clients for a coach
  Future<Result<List<ClientModel>>> getClientList(String coachId) async {
    try {
      final dataList = await _firestoreService.queryCollection(
        'clients',
        whereField: 'coachId',
        whereValue: coachId,
      );
      final clients = dataList.map((data) => ClientModel.fromJson(data)).toList();
      return Success(clients);
    } catch (e) {
      return Failure('Failed to get client list: $e');
    }
  }

  /// Stream clients for a coach
  Stream<List<ClientModel>> streamClientList(String coachId) {
    return _firestoreService.streamQuery(
      'clients',
      whereField: 'coachId',
      whereValue: coachId,
    ).map((dataList) {
      return dataList.map((data) => ClientModel.fromJson(data)).toList();
    });
  }

  /// Link coach to client
  Future<Result<void>> linkCoachToClient(String clientId, String coachId) async {
    try {
      // Update client document
      await _firestoreService.updateDocument(
        'clients/$clientId',
        {'coachId': coachId},
      );

      // Add client to coach's clientIds array
      final coachData = await _firestoreService.getDocument('coaches/$coachId');
      if (coachData != null) {
        final coach = CoachModel.fromJson(coachData);
        final updatedClientIds = [...coach.clientIds, clientId];
        await _firestoreService.updateDocument(
          'coaches/$coachId',
          {'clientIds': updatedClientIds},
        );
      }

      return const Success(null);
    } catch (e) {
      return Failure('Failed to link coach to client: $e');
    }
  }

  /// Update client onboarding data
  Future<Result<void>> updateClientOnboarding(
    String clientId, {
    required bool onboardingCompleted,
    Map<String, dynamic>? demographics,
    Map<String, dynamic>? healthData,
    Map<String, dynamic>? lifestyleGoals,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'onboardingCompleted': onboardingCompleted,
      };

      if (demographics != null) {
        updateData['demographics'] = demographics;
      }
      if (healthData != null) {
        updateData['healthData'] = healthData;
      }
      if (lifestyleGoals != null) {
        updateData['lifestyleGoals'] = lifestyleGoals;
      }

      await _firestoreService.updateDocument('clients/$clientId', updateData);
      return const Success(null);
    } catch (e) {
      return Failure('Failed to update onboarding: $e');
    }
  }
}




